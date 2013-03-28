/** 
 * @file game_result.h
 *
 * This header is about game_result, all kind of data can be contained in a
 * game_result, internal changes to the source file game_result.c are needed
 * in order to ensure the possibility to stock other kind of datas.
 *
 * Using this kind of game_result allows to add games (i.e. with the
 * database_manager) in a generic way, iterating over properties, getting both
 * name and value.
 *
 * Properties all have :
 * - A name
 * - A value (values can be set with ints but all getters return const char *)
 * - An indication about if the value is text or not
 *
 * The text value is used because when inserting on database, text values must
 * be defined between simple quotes.
 */
#ifndef GAME_RESULT_H
#define GAME_RESULT_H

#include <stdbool.h>

typedef struct game_result * game_result_p;

/** 
 * @brief The number and the names of properties will be set according to the
 * table specified.
 *
 * Table names should be chosen between those available according to the
 * source file.  
 * Table content is not freed on delete.
 */
game_result_p new_game_result(const char * table);

/** 
 * @brief Create a new game_result struct, fill it with the data provided by
 * game_statistics in nethack and then return a pointer on it.
 */
game_result_p create_actual_game_result(const char * table);

/**
 * @brief Create a new game_result struct, fill it with the data about last
 * sdoor discovery, provided by game_statistics, and then return a pointer on
 * it.
 */
game_result_p create_sdoor_discovery_result();

/** 
 * @brief Create a new game_result struct, fill it with the data about last
 * sdoor, provided by game_statistics, and then return a pointer on it.
 */
game_result_p create_sdoor_result();

/** 
 * @brief Create a new game_result struct, fill it with the data about last
 * scorr discovery, provided by game_statistics, and then return a pointer on
 * it.
 */
game_result_p create_scorr_discovery_result();

/**
 * @brief Create a new game_result struct, fill it with the data about last
 * scorr, provided by game_statistics, and then return a pointer on it.
 */
game_result_p create_scorr_result();

/**
 * @brief Free all the property values, but not property names neither table.
 */
void destroy_game_result(game_result_p gr);

/**
 * If an old value is found, value is overwritten by the given
 * parameter.
 */
void gr_set_property_name(game_result_p gr,
                          int index,
                          char * name);

/**
 * If an old value is found, it's freed before being overwritten.
 */
void gr_set_property_value(game_result_p gr,
                           int index,
                           const char * value,
                           bool is_text);

/** 
 * If an old value is found, it's freed before being overwritten.
 */
void gr_set_property_integer_value(game_result_p gr,
                                   int index,
                                   int value);

/**
 * If an old value is found, it's freed before being overwritten.
 */
void gr_set_property_text_value(game_result_p gr,
                                int index,
                                const char * value);


const char * gr_get_property_name(game_result_p gr,
                                  int index);

const char * gr_get_property_value(game_result_p gr,
                                   int index);

/**
 * @brief Return true if the property should be considered as text.
 */
bool gr_is_property_text(game_result_p gr,
                         int index);

/**
 * @brief Return the name of the destination table of the specified game
 * result
 */
const char * gr_get_table(game_result_p gr);

/** 
 * @brief Return the number of properties in the specified game result.
 */
int gr_get_nb_properties(game_result_p gr);

#endif
