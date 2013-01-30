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
	
	//Try to insert a game
	game_result_p gr = create_actual_game_result("seek_secret");
	for (int i = 0; i < 6; i++){
		gr_set_property_int_value(gr, i, i + 1);
	}
	add_game_result(gr);

	//Try to insert a random game
	gr = create_actual_game_result("seek_secret");
	add_game_result(gr);

	destroy_game_result(gr);
	close_db_manager();
	return 0;
}
