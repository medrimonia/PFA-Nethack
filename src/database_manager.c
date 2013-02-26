#include <fcntl.h>
#include <semaphore.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#include <sqlite3.h>

#include "database_manager.h"
// for ifdef
#include "game_statistics.h"
// for nh_getenv
#ifdef NETHACK_ACCESS
#include "hack.h"
#endif

#define DEFAULT_DATABASE_PATH "pfa.db"

#define REQUEST_SIZE 400
#define SEM_NAME_SIZE 200

// SPECIFIC STRUCTURES

struct column_descriptor{
	const char * name;
	const char * type;
};

typedef struct column_descriptor * column_descriptor_p;

struct table_descriptor{
	column_descriptor_p * columns;
	int nb_columns;
	const char * table_name;
};

typedef struct table_descriptor * table_descriptor_p;

struct get_result{
	char ** result;
	int num_rows;
	int num_cols;
	char * err_msg;
};

typedef struct get_result * get_result_p;

// GLOBAL VARIABLES

sqlite3 * db = NULL;
sem_t * sem = NULL;

table_descriptor_p mode_table = NULL;
table_descriptor_p sdoor_discovery_table = NULL;
table_descriptor_p sdoors_table = NULL;
table_descriptor_p scorr_discovery_table = NULL;
table_descriptor_p scorrs_table = NULL;

get_result_p new_get_result(){
	get_result_p new = malloc(sizeof(struct get_result));
	new->result = NULL;
	new->num_rows = 0;
	new->num_cols = 0;
	new->err_msg = NULL;
	return new;
}

void free_get_result(get_result_p r){
	sqlite3_free_table(r->result);
	sqlite3_free(r->err_msg);
	free(r);
}

// The result must be free by the receiver
get_result_p get_request(const char * request){
	
	get_result_p r = new_get_result();
	
	sqlite3_get_table(db,
	                  request,
	                  &r->result,
	                  &r->num_rows,
	                  &r->num_cols,
	                  &r->err_msg);
	return r;
}

void initialize_table_descriptor(const char * table_name,
                                 table_descriptor_p * td_p){
	(*td_p) = malloc(sizeof(struct column_descriptor));
	table_descriptor_p td = *td_p;

	if (strcmp(table_name,"games") == 0){
		td->nb_columns = 13;
	}
	else if (strcmp(table_name,"sdoor_discovery") == 0){
		td->nb_columns = 6;
	}
	else if (strcmp(table_name,"sdoors") == 0){
		td->nb_columns = 5;
	}
	else if (strcmp(table_name,"scorr_discovery") == 0){
		td->nb_columns = 6;
	}
	else if (strcmp(table_name,"scorrs") == 0){
		td->nb_columns = 5;
	}
	
	td->columns = malloc(td->nb_columns * sizeof(column_descriptor_p));
	int i;
	for (i = 0; i < td->nb_columns; i++){
		td->columns[i] = malloc(sizeof(struct column_descriptor));
	}
	
	int col_no = 0;
	td->columns[col_no]->name = "id";
	td->columns[col_no]->type = "int";
	col_no++;

	if (strcmp(table_name,"games") == 0){
#define DATABASE_FIELD(fName, cType, sqlType) \
  td->columns[col_no]->name = #fName;         \
  td->columns[col_no]->type = #sqlType;       \
  col_no++;
#include "games.def"
	}
	else if (strcmp(table_name,"sdoor_discovery") == 0){
#define DATABASE_FIELD(fName, cType, sqlType, sqlParam) \
  td->columns[col_no]->name = #fName;                   \
  td->columns[col_no]->type = #sqlType " " sqlParam;    \
  col_no++;
  #include "sdoor_discovery.def"
	}
	else if (strcmp(table_name,"sdoors") == 0){
#define DATABASE_FIELD(fName, cType, sqlType, sqlParam) \
  td->columns[col_no]->name = #fName;                   \
  td->columns[col_no]->type = #sqlType " " sqlParam;    \
  col_no++;
#include "sdoors.def"
	}
	else if (strcmp(table_name,"scorr_discovery") == 0){
#define DATABASE_FIELD(fName, cType, sqlType, sqlParams) \
  td->columns[col_no]->name = #fName;                    \
  td->columns[col_no]->type = #sqlType " " sqlParams;    \
  col_no++;
#include "scorr_discovery.def"
	}
	else if (strcmp(table_name,"scorrs") == 0){
#define DATABASE_FIELD(fName, cType, sqlType, sqlParams) \
  td->columns[col_no]->name = #fName;                    \
  td->columns[col_no]->type = #sqlType " " sqlParams;    \
  col_no++;
#include "scorrs.def"
	}
  
}

int init_db_manager(){
	char * db_name = NULL;
#ifdef NETHACK_ACCESS
	db_name = nh_getenv("NH_DATABASE_PATH");
#endif
	if (db_name == NULL) db_name = DEFAULT_DATABASE_PATH;

	// initialize table descriptor for games
	initialize_table_descriptor("games", &mode_table);
	// initialize table descriptor for sdoor discovery
	initialize_table_descriptor("sdoor_discovery", &sdoor_discovery_table);
	// initialize table descriptor for sdoors
	initialize_table_descriptor("sdoors", &sdoors_table);
	// initialize table descriptor for scorr discovery
	initialize_table_descriptor("scorr_discovery", &scorr_discovery_table);
	// initialize table descriptor for scorrs
	initialize_table_descriptor("scorrs", &scorrs_table);

	int result;

	// Opening database
	result = sqlite3_open_v2(db_name,
	                         &db,
	                         SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE,
	                         NULL);
	if(result){// Database opening has failed
		fprintf(stderr,
		        "CRITICAL_ERROR: Failed to open the database : %s\n",
		        sqlite3_errmsg(db));
		exit(EXIT_FAILURE);
	}

	/* Foreign key constraints must be activated after each connection
	 * according to : http://www.sqlite.org/foreignkeys.html#fk_enable
	 * This allow us to be sure that an insert with an invalid game won't happen
	 */
	char * err_msg;
	sqlite3_exec(db, "PRAGMA foreign_keys = ON;", NULL, NULL, &err_msg);
	if (err_msg != NULL){//error treatment
		fprintf(stderr, "Failed to create the specified table\n");
		fprintf(stderr, "Error : %s\n", err_msg);
		sqlite3_free(err_msg);
	}
	// Getting the semaphore name
  // found on http://stupefydeveloper.blogspot.ch/2009/02/linux-key-for-semopenshmopen.html
	// semaphore name can't contain / anywhere, basically, here we get basename
	char * basename;
	char * next = db_name;
	do{
		basename = next;
		printf("basename : %s\n", basename);
		if (next[0] == '/')
			next = strstr(next + 1,"/");
		else
			next = strstr(next,"/");
	}while (next != NULL);
	// Initializing database semaphore
	char sem_name[SEM_NAME_SIZE];
	sprintf(sem_name, "/%s.lock", basename);
	printf("semaphore name : '%s'\n", sem_name);
	sem = sem_open(sem_name , O_CREAT, 0666, 1);
	if (sem == SEM_FAILED){
		perror("Error : Can't open nor create the database semaphore");
		exit(EXIT_FAILURE);
	}

	return 0;
}

void free_table_descriptor(table_descriptor_p td){
	int i;
	for (i = 0; i < td->nb_columns; i++)
		free(td->columns[i]);
	free(td->columns);
	free(td);
}

bool exist_table(const char * table_name){
	char request[REQUEST_SIZE];

	sprintf(request,
	        "SELECT name FROM sqlite_master WHERE type='table' AND name='%s';",
	        table_name);
	get_result_p r;

	r = get_request(request);
	
	if (r->err_msg != NULL){//error treatment
		fprintf(stderr, "Failed to get the specified table\n");
		fprintf(stderr, "Error : %s\n", r->err_msg);
		sqlite3_free(r->err_msg);
		return false;
	}

	bool exists = false;
	if (r->num_rows > 0)
		exists = true;
	
	free_get_result(r);

	return exists;
}

// TODO include table_name in table_descriptor
void create_table(table_descriptor_p td, const char * table_name){
	char request[REQUEST_SIZE];

	int index = 0;
	index += sprintf(request,
	                 "create table %s (id integer primary key autoincrement, ",
	                 table_name);
	
	int i = 1;
	while(true){
		index += sprintf(request + index,
		                 "%s %s",
		                 td->columns[i]->name,
		                 td->columns[i]->type);
		i++;
		if ( i >= td->nb_columns)
			break;
		index += sprintf(request + index, ", ");
	}
	
	index += sprintf(request + index,
	                 ")");

	//printf("Request : %s\n", request);
	
	char * err_msg;

	sqlite3_exec(db,
	             request,
	             NULL,
	             NULL,
	             &err_msg);
	
	if (err_msg != NULL){//error treatment
		fprintf(stderr, "Failed to create the specified table\n");
		fprintf(stderr, "Error : %s\n", err_msg);
		sqlite3_free(err_msg);
	}
}

int add_game(game_result_p gr){
	add_game_details(gr);
	return sqlite3_last_insert_rowid(db);
}

int add_game_details(game_result_p gr){
	//TODO just test inside, must be cleared
	char request[REQUEST_SIZE];

	table_descriptor_p td;
	if (strcmp(gr_get_table(gr),"sdoor_discovery") == 0)
		td = sdoor_discovery_table;
	else if (strcmp(gr_get_table(gr),"sdoors") == 0)
		td = sdoors_table;
	else if (strcmp(gr_get_table(gr),"scorrs") == 0)
		td = scorrs_table;
	else if (strcmp(gr_get_table(gr),"scorr_discovery") == 0)
		td = scorr_discovery_table;
	else
		td = mode_table;

	if (!exist_table(gr_get_table(gr)))
		create_table(td, gr_get_table(gr));
	
	int index = 0;
	
	index += sprintf(request, "insert into %s ( ", gr_get_table(gr));

	//ID is automatically choosen from
	int i = 1;

	// printing columns name
	while(true){
		index += sprintf(request + index, "%s", gr_get_property_name(gr, i));
		i++;
		if (i >= gr_get_nb_properties(gr))
			break;
		index += sprintf(request + index, ", ");
	}
	
	index += sprintf(request + index, ") values ( ");

	// not using id value
	i=1;

	// printing columns values
	while(true){
		if (gr_is_property_text(gr,i))
			index += sprintf(request + index, "'%s'", gr_get_property_value(gr, i));
		else
			index += sprintf(request + index, "%s", gr_get_property_value(gr, i));
		i++;
		if (i >= gr_get_nb_properties(gr))
			break;
		index += sprintf(request + index, ", ");
	}
	
	index += sprintf(request + index, ")");
	
	//printf("REQUEST: %s\n", request);

	char * err_msg;

	sqlite3_exec(db,
	             request,
	             NULL,
	             NULL,
	             &err_msg);

	if (err_msg != NULL){//error treatment
		fprintf(stderr, "Failed to insert the game\n");
		fprintf(stderr, "Error : %s\n", err_msg);
		sqlite3_free(err_msg);
	}

	return 0;
}

void start_transaction(){
	sem_wait(sem);
	sqlite3_exec(db, "BEGIN", 0, 0, 0);
}

void commit_transaction(){
	sqlite3_exec(db, "COMMIT", 0, 0, 0);
	sem_post(sem);
}


int close_db_manager(){
	int result = sqlite3_close(db);
	if(result){
		// Database closing has failed
		// According to the sqlite3 doc, close should be tried again later
		fprintf(stderr,
		        "Failed to close the database : %s\n",
		        sqlite3_errmsg(db));
		return 1;
	}
	free_table_descriptor(sdoor_discovery_table);
	free_table_descriptor(sdoors_table);
	free_table_descriptor(scorr_discovery_table);
	free_table_descriptor(scorrs_table);
	free_table_descriptor(mode_table);
	//printf("Database closed\n");
	return 0;
}
