#include <stdio.h>
#include <stdlib.h>

#include <sqlite3.h>

#include "database_manager.h"

#define DATABASE_NAME "pfa.db"

#define REQUEST_SIZE 200

sqlite3 * db = NULL;

struct get_result{
	char ** result;
	int num_rows;
	int num_cols;
	char * err_msg;
};

typedef struct get_result * get_result_p;

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

// It seems that this is needed
//int fake_callback

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

int init_db_manager(){
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
	printf("Database opened\n");
	return 0;
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

	sprintf(request,
					"create table %s",
					table_name);
	
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

int add_entry(database_entry_p e){
	//TODO just test inside, must be cleared
	char request[REQUEST_SIZE];

	sprintf(request,"select * from %s", e->mode);

	get_result_p r = get_request(request);
	
	if (r->err_msg != NULL){//error treatment
		fprintf(stderr, "Failed to get the specified table\n");
		fprintf(stderr, "Error : %s\n", r->err_msg);
		sqlite3_free(r->err_msg);
	}
	
	free_get_result(r);
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
	printf("Database closed\n");
	return 0;
}
