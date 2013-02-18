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

#define MAX_SDOORS 200
#define MAX_SDOORS_DISCOVERY 200
#define MAX_SCORRS 200
#define MAX_SCORRS_DISCOVERY 200

// The variable moves is used sometimes in the game
#ifndef NETHACK_ACCESS
int moves = 0;
#endif

int actual_sdoor = 0;
int nb_sdoors = 0;
int actual_sdoor_discovery = 0;
int nb_sdoors_found = 0;

int actual_scorr = 0;
int nb_scorrs = 0;
int actual_scorr_discovery = 0;
int nb_scorrs_found = 0;

int nb_squares_explored = 0;
int nb_squares_reachable = 0;

int last_discovery_turn = -1;

struct location{
	int line;
	int column;
	int level;
};
struct discovery{
	int discovery_turn;
	int line;
	int column;
	int level;
};

struct location * sdoors;
struct location * scorrs;
struct discovery * sdoors_discovery;
struct discovery * scorrs_discovery;

int max_moves = -1;
int seed;

struct timeval start;

char * bot_name = NULL;
char * mode_name = NULL;

bool gs_initialized = false;

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

	sdoors = malloc(MAX_SDOORS * sizeof(struct location));
	scorrs = malloc(MAX_SCORRS * sizeof(struct location));
	sdoors_discovery = malloc(MAX_SDOORS_DISCOVERY * sizeof(struct discovery));
	scorrs_discovery = malloc(MAX_SCORRS_DISCOVERY * sizeof(struct discovery));

	// Must be done only once all game statistics has been properly initialized
	init_db_manager();
}

void gs_terminate(){
	free(sdoors);
	free(scorrs);
	free(sdoors_discovery);
	free(scorrs_discovery);
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
	moves = rand() % 1000;
	int line = rand() % 21;
	int column = rand() % 80;
	statistic_add_sdoor_discovery(line,column);
}

void make_random_door(){
	int line = rand() % 21;
	int column = rand() % 80;
	statistic_add_sdoor(line, column);
}

void make_random_scorr_discovery(){
	moves = rand() % 1000;
	int line = rand() % 21;
	int column = rand() % 80;
	statistic_add_scorr_discovery(line, column);
}

void make_random_scorr(){
	int line = rand() % 21;
	int column = rand() % 80;
	statistic_add_scorr(line, column);
}
#endif

#ifdef NETHACK_ACCESS
static char visited_square [MAXDUNGEON][MAXLEVEL][COLNO][ROWNO];
#endif

void statistic_add_sdoor(int line, int column){
	sdoors[nb_sdoors].line = line;
	sdoors[nb_sdoors].column = column;
	nb_sdoors++;
}

void statistic_add_scorr(int line, int column){
	scorrs[nb_scorrs].line = line;
	scorrs[nb_scorrs].column = column;
	nb_scorrs++;
}

void statistic_add_sdoor_discovery(int line, int column){
	sdoors_discovery[nb_sdoors_found].line = line;
	sdoors_discovery[nb_sdoors_found].column = column;
	sdoors_discovery[nb_sdoors_found].discovery_turn = moves;
	nb_sdoors_found++;
}

void statistic_add_scorr_discovery(int line, int column){
	scorrs_discovery[nb_scorrs_found].line = line;
	scorrs_discovery[nb_scorrs_found].column = column;
	scorrs_discovery[nb_scorrs_found].discovery_turn = moves;
	nb_scorrs_found++;
}

void update_nb_sdoors() {
#ifdef NETHACK_ACCESS
	int col;
	int row;
	for (col = 0; col < COLNO; col++){
	  for (row = 0; row < ROWNO; row++){
			if (levl[col][row].typ == SDOOR){
				statistic.add_sdoor(row, col);
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
				statistic.add_scorr(row, col);
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

int get_scorr_discovery_turn(){
	return scorrs_discovery[actual_scorr_discovery].discovery_turn;
}

int get_scorr_discovery_level(){
	return scorrs_discovery[actual_scorr_discovery].discovery_turn;
}

int get_scorr_level(){
	return scorrs[actual_scorr].level;
}

int get_scorr_discovery_line(){
	return scorrs_discovery[actual_scorr_discovery].line;
}

int get_scorr_line(){
	return scorrs[actual_scorr].line;
}

int get_scorr_discovery_column(){
	return scorrs_discovery[actual_scorr_discovery].column;
}

int get_scorr_column(){
	return scorrs[actual_scorr].column;
}

int get_door_discovery_turn(){
	return sdoors_discovery[actual_sdoor_discovery].discovery_turn;
}

int get_door_discovery_level(){
	return sdoors_discovery[actual_sdoor_discovery].discovery_turn;
}

int get_door_level(){
	return sdoors[actual_sdoor].level;
}

int get_door_discovery_line(){
	return sdoors_discovery[actual_sdoor_discovery].line;
}

int get_door_line(){
	return sdoors[actual_sdoor].line;
}

int get_door_discovery_column(){
	return sdoors_discovery[actual_sdoor_discovery].column;
}

int get_door_column(){
	return sdoors[actual_sdoor].column;
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
