#include <string.h>
#include <sys/time.h>

#include "game_statistics.h"

#include "database_manager.h"

#ifdef NETHACK_ACCESS
#include "hack.h"
#else
#include <stdlib.h>
#endif

#define DEFAULT_MAX_MOVES 20000
#define DEFAULT_BOT_NAME "unknown"
#define DEFAULT_MODE_NAME "seek_secret"

int nb_sdoors = 0;
int nb_sdoors_found = 0;

int nb_scorrs = 0;
int nb_scorrs_found = 0;

int nb_squares_explored = 0;
int nb_squares_reachable = 0;

int last_discovery_turn = -1;

int last_door_line = -1;
int last_door_column = -1;
int last_door_level = -1;

int last_scorr_line = -1;
int last_scorr_column = -1;
int last_scorr_level = -1;

int max_moves = -1;
int seed;

struct timeval start;

char * bot_name = NULL;
char * mode_name = NULL;

void gs_init(){
	gettimeofday(&start, NULL);

	char * str = NULL;

#ifdef NETHACK_ACCESS
	str = nh_getenv("NH_MAX_MOVES");
#endif
	if (str == NULL)
		max_moves = DEFAULT_MAX_MOVES;
	else
		max_moves = atoi(str);

#ifdef NETHACK_ACCESS
	str = nh_getenv("NH_BOT_NAME");
#endif
	if (str == NULL)
		bot_name = strdup(DEFAULT_BOT_NAME);
	else
		bot_name = strdup(str);

#ifdef NETHACK_ACCESS
	str = nh_getenv("NH_MODE_NAME");
#endif
	if (str == NULL)
		mode_name = strdup(DEFAULT_MODE_NAME);
	else
		mode_name = strdup(str);

	// Must be done only once all game statistics has been properly initialized
	init_db_manager();
}

void gs_terminate(){
	free(bot_name);
	free(mode_name);
}

#ifndef NETHACK_ACCESS
void make_random_stats(){
	nb_sdoors = rand() % 10;
  nb_sdoors_found = rand() % 10;
  nb_scorrs = rand() % 5;
  nb_scorrs_found = rand() % 5;
  nb_squares_explored = rand() % 400;
  nb_squares_reachable = rand() % 400;
  seed = rand();
	max_moves = (rand() % 20) * 1000;
}

void make_random_door_discovery(){
	last_discovery_turn = rand() % 1000;
	last_door_line = rand() % 21;
	last_door_column = rand() % 80;
}

void make_random_door(){
	last_door_line = rand() % 21;
	last_door_column = rand() % 80;
}

void make_random_scorr_discovery(){
	last_discovery_turn = rand() % 1000;
	last_scorr_line = rand() % 21;
	last_scorr_column = rand() % 80;
}

void make_random_scorr(){
	last_scorr_line = rand() % 21;
	last_scorr_column = rand() % 80;
}
#endif

#ifdef NETHACK_ACCESS
static char visited_square [MAXDUNGEON][MAXLEVEL][COLNO][ROWNO];
#endif

void statistic_add_sdoor(int line, int column){
	last_door_line = line;
	last_door_column = column;
	nb_sdoors++;
	game_result_p d = create_door_result();
	add_game_result(d);
}

void statistic_add_scorr(int line, int column){
	last_scorr_line = line;
	last_scorr_column = column;
	nb_scorrs++;
	game_result_p r = create_scorr_result();
	add_game_result(r);
}

void statistic_add_sdoor_discovery(int line, int column){
	last_door_line = line;
	last_door_column = column;
#ifdef NETHACK_ACCESS
	last_discovery_turn = moves;
#endif
	nb_sdoors_found++;
	game_result_p dd = create_door_discovery_result();
	add_game_result(dd);
}

void statistic_add_scorr_discovery(int line, int column){
	last_scorr_line = line;
	last_scorr_column = column;
#ifdef NETHACK_ACCESS
	last_discovery_turn = moves;
#endif
	nb_scorrs_found++;
	game_result_p sd = create_scorr_discovery_result();
	add_game_result(sd);
}

void update_nb_sdoors() {
#ifdef NETHACK_ACCESS
	int col;
	int row;
	for (col = 0; col < COLNO; col++){
	  for (row = 0; row < ROWNO; row++){
			if (levl[col][row].typ == SDOOR){
				last_door_line = row;
				last_door_column = col;
				nb_sdoors++;
				game_result_p d = create_door_result();
				add_game_result(d);
			}
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
			if (levl[col][row].typ == SCORR){
				last_scorr_line = row;
				last_scorr_column = col;
				nb_scorrs++;
				game_result_p r = create_scorr_result();
				add_game_result(r);
			}
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
		nb_squares_explored++;
	}
#endif
}

void gs_set_seed(int s){
	seed = s;
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

int get_nb_squares_explored(){
	return nb_squares_explored;
}

int get_max_moves(){
	return max_moves;
}

const char * get_bot_name(){
	return bot_name;
}

const char * get_mode_name(){
	return mode_name;
}

int get_seed(){
	return seed;
}

int get_discovery_turn(){
	return last_discovery_turn;
}

int get_door_line(){
	return last_door_line;
}

int get_door_column(){
	return last_door_column;
}

int get_door_level(){
	return last_door_level;
}

int get_scorr_line(){
	return last_scorr_line;
}

int get_scorr_column(){
	return last_scorr_column;
}

int get_scorr_level(){
	return last_scorr_level;
}

int get_processing_time(){
	struct timeval actual;
	gettimeofday(&actual, NULL);
	struct timeval result;
	timersub(&actual, &start, &result);
	return result.tv_sec * 1000 + result.tv_usec / 1000;
}

void gs_submit_game(){
	game_result_p gr = create_actual_game_result("seek_secret");
	add_game_result(gr);
	destroy_game_result(gr);
	close_db_manager();
	free(bot_name);
	free(mode_name);
}

#ifdef NETHACK_ACCESS
void gs_end_game_if_needed(){
	if (moves >= max_moves){
		terminate(EXIT_SUCCESS);
	}
}
#endif
