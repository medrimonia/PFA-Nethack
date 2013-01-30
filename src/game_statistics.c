#include "game_statistics.h"

#include "hack.h"

int nb_sdoors = 0;
int nb_sdoors_found = 0;

int nb_scorrs = 0;
int nb_scorrs_found = 0;

int nb_squares_reached = 0;
int nb_squares_reachable = 0;

static char visited_square [MAXDUNGEON][MAXLEVEL][COLNO][ROWNO];

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
	int col;
	int row;
	for (col = 0; col < COLNO; col++){
	  for (row = 0; row < ROWNO; row++){
	  if (levl[col][row].typ == SDOOR)
	    nb_sdoors++;
	  }
	}
}

void update_nb_scorrs() {
	int col;
	int row;
	for (col = 0; col < COLNO; col++){
	  for (row = 0; row < ROWNO; row++){
	  if (levl[col][row].typ == SCORR)
	    nb_scorrs++;
	  }
	}
}

void update_reachable_squares(){
	int c;
	int r;
	for (c = 0; c < COLNO ; c++){
		for (r = 0; r < ROWNO ; r++){
			if (levl[c][r].typ > 12) // see rm.h:33
				nb_squares_reachable++;
		}
	}
}

void update_reached_squares(){
	if (!visited_square[u.uz.dnum][u.uz.dlevel][u.ux][u.uy]){
		visited_square[u.uz.dnum][u.uz.dlevel][u.ux][u.uy] = 1;
		nb_squares_reached++;
	}


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
