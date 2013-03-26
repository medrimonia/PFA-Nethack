#include <stdlib.h>
#include <stdio.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

#include <sqlite3.h>

#include "database_manager.h"
#include "game_statistics.h"

int main(void){

	fork();
	// Initializing random generator
	srand(time(NULL));

	//gs_init should be called implicitly

	gs_submit_game();

	gs_terminate();
	wait(NULL);
	return 0;
}
