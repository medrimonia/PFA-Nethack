#ifndef GAME_RESULT_H
#define GAME_RESULT_H

typedef struct game_result * game_result_p;

/* The number and the names of properties will be set according to the mode
 * specfied.
 * mode content is not free on delete
 */
game_result_p new_game_result(const char * mode);

/* Create a new game_result struct, fill it with the data provided by
 * game_statistics in nethack and then return a pointer on it
 */
game_result_p create_actual_game_result(const char * mode);

/* Free all the property values, but not property names neither mode */
void destroy_game_result(game_result_p gr);

// If an old value is found, it's overwritten
void gr_set_property_name(game_result_p gr,
													int index,
													char * name);

// if an old value is found, it's free
void gr_set_property_value(game_result_p gr,
													 int index,
													 char * value);

// if an old value is found, it's free
void gr_set_property_int_value(game_result_p gr,
															 int index,
															 int value);


const char * gr_get_property_name(game_result_p gr,
																	int index);

const char * gr_get_property_value(game_result_p gr,
																	 int index);

const char * gr_get_mode(game_result_p gr);

int gr_get_nb_properties(game_result_p gr);

#endif
