#include <stdlib.h>
#include <stdio.h>
#include <time.h>

#include <sqlite3.h>

#include "database_manager.h"
#include "game_statistics.h"

int main(int argc, char ** argv){
	// Initializing random generator
	srand(time(NULL));

	//gs_init should be called implicitly

	gs_submit_game();

	gs_terminate();
	return 0;
}
