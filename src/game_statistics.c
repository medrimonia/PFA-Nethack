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

/* All game details are saved in arrays before game_end, this allows
 * to add all details in a single transaction once the game is finished.
 * The maximal capacity of this arrays is defined here.
 */
#define MAX_SDOORS 200
#define MAX_SDOORS_DISCOVERY 200
#define MAX_SCORRS 200
#define MAX_SCORRS_DISCOVERY 200

int get_current_level(){
#ifdef NETHACK_ACCESS
	return u.uz.dlevel;
#else
	return -1;
#endif
}

// The variable moves is used sometimes in the game
#ifndef NETHACK_ACCESS
/* moves variable is declared in hack.h, if this file is not used for
 * compilation, it is still needed in game_statistics.
 */
int moves = 0;
#endif

// Struct used for saving informations about the games

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
// Global Variables initializations

// Contains the deepest level reached
int level_reached = 1;

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

int game_id = -1;
int last_discovery_turn = -1;

int db_time = -1;// in ms

// Data Storing
struct location * sdoors[MAX_SDOORS];
struct location * scorrs[MAX_SCORRS];
struct discovery * sdoors_discovery[MAX_SDOORS_DISCOVERY];
struct discovery * scorrs_discovery[MAX_SCORRS_DISCOVERY];

int max_moves = -1;
int seed = -1;

// Used to calculate db_time 
struct timeval start;

char * bot_name = NULL;
char * mode_name = NULL;

// Using a lazy-mechanism
bool gs_initialized = false;

void gs_init(){
	if (gs_initialized)
		return;
	gs_initialized = true;
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

#ifndef NETHACK_ACCESS
	make_random_stats();
#endif
}

void gs_terminate(){
	free(bot_name);
	free(mode_name);
	gs_initialized = false;
}

void gs_new_level(){
	level_reached++;
	update_reachable_squares();
	update_nb_sdoors();
	update_nb_scorrs();
}

#ifndef NETHACK_ACCESS
void make_random_stats(){
	int i;
	int nb_sdoors = rand() % 10 + 1;
	for (i = 0; i < nb_sdoors; i++)
		make_random_door();
	int nb_sdoors_found = rand() % 10 + 1;
	for (i = 0; i < nb_sdoors_found; i++)
		make_random_door_discovery();
	int nb_scorrs = rand() % 5 + 1;
	for (i = 0; i < nb_scorrs; i++)
		make_random_scorr();
	int nb_scorrs_found = rand() % 5 + 1;
	for (i = 0; i < nb_scorrs_found; i++)
		make_random_scorr_discovery();
	nb_squares_explored = rand() % 400 + 1;
	nb_squares_reachable = rand() % 400 + 1;
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
	if (!gs_initialized) gs_init();
	sdoors[nb_sdoors].line = line;
	sdoors[nb_sdoors].column = column;
	sdoors[nb_sdoors].level = get_current_level();
	nb_sdoors++;
}

void statistic_add_scorr(int line, int column){
	if (!gs_initialized) gs_init();
	scorrs[nb_scorrs].line = line;
	scorrs[nb_scorrs].column = column;
	scorrs[nb_scorrs].level = get_current_level();
	nb_scorrs++;
}

void statistic_add_sdoor_discovery(int line, int column){
	if (!gs_initialized) gs_init();
	sdoors_discovery[nb_sdoors_found].line = line;
	sdoors_discovery[nb_sdoors_found].column = column;
	sdoors_discovery[nb_sdoors_found].discovery_turn = moves;
	sdoors_discovery[nb_sdoors_found].level = get_current_level();
	nb_sdoors_found++;
}

void statistic_add_scorr_discovery(int line, int column){
	if (!gs_initialized) gs_init();
	scorrs_discovery[nb_scorrs_found].line = line;
	scorrs_discovery[nb_scorrs_found].column = column;
	scorrs_discovery[nb_scorrs_found].discovery_turn = moves;
	scorrs_discovery[nb_scorrs_found].level = get_current_level();
	nb_scorrs_found++;
}

void update_nb_sdoors() {
	if (!gs_initialized) gs_init();
#ifdef NETHACK_ACCESS
	int col;
	int row;
	for (col = 0; col < COLNO; col++){
	  for (row = 0; row < ROWNO; row++){
			if (levl[col][row].typ == SDOOR){
				statistic_add_sdoor(row, col);
			}
	  }
	}
#endif
}

void update_nb_scorrs() {
	if (!gs_initialized) gs_init();
#ifdef NETHACK_ACCESS
	int col;
	int row;
	for (col = 0; col < COLNO; col++){
		for (row = 0; row < ROWNO; row++){
			if (levl[col][row].typ == SCORR){
				statistic_add_scorr(row, col);
			}
		}
	}
#endif
}

void update_reachable_squares(){
	if (!gs_initialized) gs_init();
#ifdef NETHACK_ACCESS
	int c;
	int r;
	for (c = 0; c < COLNO ; c++){
		for (r = 0; r < ROWNO ; r++){
			if (ACCESSIBLE(levl[c][r].typ) ||
			    levl[c][r].typ == SDOOR    ||
			    levl[c][r].typ == SCORR) // see rm.h:33
				nb_squares_reachable++;
		}
	}
#endif
}

void update_reached_squares(){
	if (!gs_initialized) gs_init();
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

int get_used_moves(){
	return moves;
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

int get_scd_turn(){
	return scorrs_discovery[actual_scorr_discovery].discovery_turn;
}

int get_scd_level(){
	return scorrs_discovery[actual_scorr_discovery].level;
}

int get_sc_level(){
	return scorrs[actual_scorr].level;
}

int get_scd_line(){
	return scorrs_discovery[actual_scorr_discovery].line;
}

int get_sc_line(){
	return scorrs[actual_scorr].line;
}

int get_scd_column(){
	return scorrs_discovery[actual_scorr_discovery].column;
}

int get_sc_column(){
	return scorrs[actual_scorr].column;
}

int get_sdd_turn(){
	return sdoors_discovery[actual_sdoor_discovery].discovery_turn;
}

int get_sdd_level(){
	return sdoors_discovery[actual_sdoor_discovery].level;
}

int get_sd_level(){
	return sdoors[actual_sdoor].level;
}

int get_sdd_line(){
	return sdoors_discovery[actual_sdoor_discovery].line;
}

int get_sd_line(){
	return sdoors[actual_sdoor].line;
}

int get_sdd_column(){
	return sdoors_discovery[actual_sdoor_discovery].column;
}

int get_sd_column(){
	return sdoors[actual_sdoor].column;
}

int get_nethack_time(){
	return mm_total_time() - mm_bot_time();
}

int get_bot_time(){
	return mm_bot_time();
}

int get_db_time(){
	return db_time;
}

int get_processing_time(){
	struct timeval actual;
	gettimeofday(&actual, NULL);
	struct timeval result;
	timersub(&actual, &start, &result);
	return result.tv_sec * 1000 + result.tv_usec / 1000;
}

int get_level_reached(){
	return level_reached;
}

int get_game_id(){
	return game_id;
}

void gs_submit_game(){
	struct timeval start;
	struct timeval end;
	struct timeval result;
	gettimeofday(&start, NULL);

	if (!gs_initialized) gs_init();
	init_db_manager();

	start_transaction();

	// Publishing global game result
	game_result_p gr = create_actual_game_result("games");
	game_id = add_game(gr);
	destroy_game_result(gr);
	// Publishing sdoor result
	for (actual_sdoor = 0; actual_sdoor < nb_sdoors; actual_sdoor++){
		game_result_p d = create_sdoor_result();
		add_game_details(d);
		destroy_game_result(d);
	}
	// Publishing scorr result
	for (actual_scorr = 0; actual_scorr < nb_scorrs; actual_scorr++){
		game_result_p c = create_scorr_result();
		add_game_details(c);
		destroy_game_result(c);
	}
	// Publishing sdoor_discovery result
	for (actual_sdoor_discovery = 0;
	     actual_sdoor_discovery < nb_sdoors_found;
	     actual_sdoor_discovery++){
		game_result_p dd = create_sdoor_discovery_result();
		add_game_details(dd);
		destroy_game_result(dd);
	}
	// Publishing scorr_discovery result
	for (actual_scorr_discovery = 0;
	     actual_scorr_discovery < nb_scorrs_found;
	     actual_scorr_discovery++){
		game_result_p cd = create_scorr_discovery_result();
		add_game_details(cd);
		destroy_game_result(cd);
	}

	gettimeofday(&end, NULL);
	timersub(&end, &start, &result);
	db_time = result.tv_sec * 1000 + result.tv_usec / 1000;

	// Time do not take into account transaction time, but it would imply to do
	// another transaction, that's why it's not so accurate
	update_db_time();

	commit_transaction();

	close_db_manager();
}

#ifdef NETHACK_ACCESS
void gs_end_game_if_needed(){
	if (moves >= max_moves){
		terminate(EXIT_SUCCESS);
	}
}
#endif
