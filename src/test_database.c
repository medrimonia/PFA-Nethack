#include <stdlib.h>
#include <stdio.h>
#include <time.h>

#include <sqlite3.h>

#include "database_manager.h"
#include "game_statistics.h"

int main(int argc, char ** argv){
	// Initializing random generator
	srand(time(NULL));
	//gs_init call init_db_manager
	gs_init();

	// check if a table named seek_secret exists
	if (exist_table("seek_secret")){
		//printf("Seek_secret table found\n");
	}
	/*else{
		printf("Creating seek_secret table\n");
		create_table("seek_secret");
		}*/
	
	//Try to insert a game
	/*game_result_p gr = create_actual_game_result("seek_secret");
	int i;
	for (i = 0; i < 6; i++){
		gr_set_property_int_value(gr, i, i + 1);
	}
	add_game_result(gr);*/

	//Try to insert a random game
	game_result_p gr = create_actual_game_result("seek_secret");
	add_game_result(gr);

	//Try to insert a door discovery
	game_result_p dd = create_door_discovery_result();
	add_game_result(dd);

	make_random_door();
	//Try to insert a door discovery
	game_result_p d = create_door_result();
	add_game_result(d);

	destroy_game_result(d);
	destroy_game_result(dd);
	destroy_game_result(gr);
	close_db_manager();
	return 0;
}
