#ifndef GAME_STATISTICS_H
#define GAME_STATISTICS_H

// Comment if there's no access to nethack files
// This is used typically for test outside of nethack kernel
//#define NETHACK_ACCESS

/* Initialize the game statistic module */
void gs_init();

/* Free all the ressources dedicated to the game statistic module */
void gs_terminate();

#ifndef NETHACK_ACCESS
/* srand initialization is not provided by game_statistics, it should be done
 * by the caller.
 */
void make_random_stats();
void make_random_door_discovery();
void make_random_door();
void make_random_scorr_discovery();
void make_random_scorr();

#endif

/* Add a door to the number of secret doors that can be found. This function
 * must be called for the doors which haven't been added in an update_nb_sdoor()
 */
void statistic_add_sdoor();

/* Shall be called once by secret door discovery */
void statistic_add_sdoor_discovery();

/* Add a door to the number of secret corridors that can be found. This function
 * must be called for the secret corridors which haven't been added in an
 * update_nb_sdoor()
 */
void statistic_add_scorr();

/* Shall be called once by secret corridor discovery */
void statistic_add_scorr_discovery();

/* Must be called each time a new level is reached, but not twice for the same
 * level. */
void update_nb_sdoors();

/* Must be called each time a new level is reached, but not twice for the same
 * level. */
void update_nb_scorrs();

/* Must be called each time a new level is reached, but not twice for the same
 * level. */
void update_reachable_squares();

/* Must be called at least once each time a new square is reached (might be
 * called more than once on the same square)
 */
void update_reached_squares();

/* Shall be called when a seed is used to set game random */
void gs_set_seed(int);

/* Return the number of secret doors reachable in all the level reached. */
int get_nb_sdoors();

/* Return the number of secret doors found during the game. */
int get_nb_sdoors_found();

/* Return the number of secret corridors reachable in all the level reached.
 */
int get_nb_scorrs();

/* Return the number of secret corridors found during the game. */
int get_nb_scorrs_found();

/* Return the number of squares reachable in all the level discovered. */
int get_nb_squares_reachable();

/* Return the number of square explored during the game. */
int get_nb_squares_explored();

/* Return the maximal number of moves allowed in this game. */
int get_max_moves();

int get_door_discovery_turn();
int get_door_line();
int get_door_column();
int get_door_level();
int get_door_discovery_line();
int get_door_discovery_column();
int get_door_discovery_level();

int get_scorr_discovery_turn();
int get_scorr_line();
int get_scorr_column();
int get_scorr_level();
int get_scorr_discovery_line();
int get_scorr_discovery_column();
int get_scorr_discovery_level();

/* Return the name of the bot playing this game */
const char * get_bot_name();

/* Return the name of the mode used in this game */
const char * get_mode_name();

/* Return time (in ms) since beginning of the game */
int get_processing_time();

/* Return the game seed. */
int get_seed();

/* Add result of current game to database */
void gs_submit_game();

#endif
