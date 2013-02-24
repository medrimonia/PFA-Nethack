#ifndef DATABASE_MANAGER_H
#define DATABASE_MANAGER_H

#include <stdbool.h>

#include "game_result.h"

/* Create or open the database with the default name
 * return 0 on success
 * print an error message and exit on error
 */
int init_db_manager();

/* Add the specified game result to the current database
 */
int add_game_result(game_result_p e);

/* Start a transaction with the database */
void start_transaction();

/* Validate the transaction started before */
void commit_transaction();

/* Free all ressources associated to the database manager
 * return 0 on success
 * print an error message and return 1 on error
 */
int close_db_manager();

#endif
