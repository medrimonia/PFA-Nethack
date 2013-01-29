#include <stdlib.h>
#include <stdio.h>

#include <sqlite3.h>

#include "database_manager.h"

int main(int argc, char ** argv){
	init_db_manager();

	// check if a table named seek_secret exists
	if (exist_table("seek_secret")){
		printf("Seek_secret table found\n");
	}
	else{
		printf("Creating seek_secret table\n");
		create_table("seek_secret");
	}

	close_db_manager();
	return 0;
}
