#include "game_statistics.h"

#include "database_manager.h"

#ifdef NETHACK_ACCESS
#include "hack.h"
#else
#include <stdlib.h>
#endif

#define DEFAULT_MAX_MOVES 20000

int nb_sdoors = 0;
int nb_sdoors_found = 0;

int nb_scorrs = 0;
int nb_scorrs_found = 0;

int nb_squares_reached = 0;
int nb_squares_reachable = 0;

int max_moves = -1;

void gs_init(){
	char * str;

	str = nh_getenv("NH_MAX_MOVES");
	if (str == NULL)
		max_moves = DEFAULT_MAX_MOVES;
	else
		max_moves = atoi(str);
}

#ifndef NETHACK_ACCESS
void make_random_stats(){
	nb_sdoors = rand() % 20;
  nb_sdoors_found = rand() % 20;
  nb_scorrs = rand() % 20;
  nb_scorrs_found = rand() % 20;
  nb_squares_reached = rand() % 20;
  nb_squares_reachable = rand() % 20;
}
#endif

#ifdef NETHACK_ACCESS
static char visited_square [MAXDUNGEON][MAXLEVEL][COLNO][ROWNO];
#endif

void statistic_add_sdoor(){
	nb_sdoors++;
}

void statistic_add_scorr(){
	nb_scorrs++;
}

void statistic_add_sdoor_discovery(){
	nb_sdoors_found++;
}

void statistic_add_scorr_discovery(){
	nb_scorrs_found++;
}

void update_nb_sdoors() {
#ifdef NETHACK_ACCESS
	int col;
	int row;
	for (col = 0; col < COLNO; col++){
	  for (row = 0; row < ROWNO; row++){
	  if (levl[col][row].typ == SDOOR)
	    nb_sdoors++;
	  }
	}
#endif
}

void update_nb_scorrs() {
#ifdef NETHACK_ACCESS
	int col;
	int row;
	for (col = 0; col < COLNO; col++){
	  for (row = 0; row < ROWNO; row++){
	  if (levl[col][row].typ == SCORR)
	    nb_scorrs++;
	  }
	}
#endif
}

void update_reachable_squares(){
#ifdef NETHACK_ACCESS
	int c;
	int r;
	for (c = 0; c < COLNO ; c++){
		for (r = 0; r < ROWNO ; r++){
			if (ACCESSIBLE(levl[c][r].typ)) // see rm.h:33
				nb_squares_reachable++;
		}
	}
#endif
}

void update_reached_squares(){
#ifdef NETHACK_ACCESS
	if (!visited_square[u.uz.dnum][u.uz.dlevel][u.ux][u.uy]){
		visited_square[u.uz.dnum][u.uz.dlevel][u.ux][u.uy] = 1;
		nb_squares_reached++;
	}
#endif
}

int get_nb_sdoors() {
	return nb_sdoors;
}

int get_nb_sdoors_found(){
	return nb_sdoors_found;
}

int get_nb_scorrs() {
	return nb_scorrs;
}

int get_nb_scorrs_found(){
	return nb_scorrs_found;
}

int get_nb_squares_reachable(){
	return nb_squares_reachable;
}

int get_nb_squares_reached(){
	return nb_squares_reached;
}

void gs_submit_game(){
	init_db_manager();
	game_result_p gr = create_actual_game_result("seek_secret");
	add_game_result(gr);
	destroy_game_result(gr);
	close_db_manager();
}

void gs_end_game_if_needed(){
	if (moves >= max_moves){
		terminate(EXIT_SUCCESS);
	}
}
