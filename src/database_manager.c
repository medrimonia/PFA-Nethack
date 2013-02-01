#include <stdio.h>
#include <stdlib.h>

#include <sqlite3.h>

#include "database_manager.h"

#define DATABASE_NAME "pfa.db"

#define REQUEST_SIZE 400
#define NB_COLUMNS 7

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

table_descriptor_p table_descriptor = NULL;

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

void initialize_table_descriptor(){
	
	table_descriptor = malloc(sizeof(struct column_descriptor));
	table_descriptor->nb_columns = NB_COLUMNS;
	
	table_descriptor->columns = malloc(table_descriptor->nb_columns *
																		 sizeof(column_descriptor_p));
	int i;
	for (i = 0; i < table_descriptor->nb_columns; i++){
		table_descriptor->columns[i] = malloc(sizeof(struct column_descriptor));
	}
	table_descriptor->columns[0]->name = "id";
	table_descriptor->columns[0]->type = "int";
	table_descriptor->columns[1]->name = "nb_squares_explored";
	table_descriptor->columns[1]->type = "int";
	table_descriptor->columns[2]->name = "nb_squares_reachable";
	table_descriptor->columns[2]->type = "int";
	table_descriptor->columns[3]->name = "nb_sdoors_found";
	table_descriptor->columns[3]->type = "int";
	table_descriptor->columns[4]->name = "nb_sdoors_reachable";
	table_descriptor->columns[4]->type = "int";
	table_descriptor->columns[5]->name = "nb_scorrs_found";
	table_descriptor->columns[5]->type = "int";
	table_descriptor->columns[6]->name = "nb_scorrs_reachable";
	table_descriptor->columns[6]->type = "int";
}

int init_db_manager(){

	initialize_table_descriptor();

	int result;

	result = sqlite3_open_v2(DATABASE_NAME,
													 &db,
													 SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE,
													 NULL);
	if(result){// Database opening has failed
		fprintf(stderr,
						"CRITICAL_ERROR: Failed to open the database : %s\n",
						sqlite3_errmsg(db));
		exit(EXIT_FAILURE);
	}
	return 0;
}

void free_table_descriptor(){
	int i;
	for (i = 0; i < table_descriptor->nb_columns; i++)
		free(table_descriptor->columns[i]);
	free(table_descriptor->columns);
	free(table_descriptor);
}

bool exist_table(const char * table_name){
	char request[REQUEST_SIZE];

	sprintf(request,
					"SELECT name FROM sqlite_master WHERE type='table' AND name='%s';",
					table_name);

	get_result_p r = get_request(request);
	
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

void create_table(const char * table_name){
	char request[REQUEST_SIZE];

	int index = 0;
	index += sprintf(request,
									 "create table %s (id int primary key, ",
									 table_name);
	
	int i = 1;
	while(true){
		index += sprintf(request + index,
										 "%s %s",
										 table_descriptor->columns[i]->name,
										 table_descriptor->columns[i]->type);
		i++;
		if ( i >= table_descriptor->nb_columns)
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

int add_game_result(game_result_p gr){
	//TODO just test inside, must be cleared
	char request[REQUEST_SIZE];

	if (!exist_table(gr_get_mode(gr)))
		create_table(gr_get_mode(gr));
			
	
	int index = 0;
	
	index += sprintf(request, "insert into %s ( ", gr_get_mode(gr));

	int i = 0;

	// printing columns name
	while(true){
		index += sprintf(request + index, "%s", gr_get_property_name(gr, i));
		i++;
		if (i >= gr_get_nb_properties(gr))
			break;
		index += sprintf(request + index, ", ");
	}
	
	index += sprintf(request + index, ") values ( ");

	i=0;

	// printing columns values
	while(true){
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
	free_table_descriptor(table_descriptor);
	//printf("Database closed\n");
	return 0;
}
