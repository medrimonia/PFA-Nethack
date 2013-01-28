#include <stdio.h>
#include <stdlib.h>

#include <sqlite3.h>

#include "database_manager.h"

#define DATABASE_NAME "pfa.db"

sqlite3 * db = NULL;

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
