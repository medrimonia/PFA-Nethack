/* This header concerns the implementation of the database manager,
 * the whole idea behind this module is to ensure that the client doesn't need
 * to keep in mind all the details specific to the database implementation.
 *
 * Some ideas have still to be respected if the client wants performances
 * and/or multi-processes easy support : 
 * - All Inserts should be done together (avoid isolated inserts)
 * - Multiple insert should be enclosed in a transaction
 * - The database manager should be initialized as late as possible
 * - The database manager should be closed as soon as possible
 */

#ifndef DATABASE_MANAGER_H
#define DATABASE_MANAGER_H

#include <stdbool.h>

#include "game_result.h"

/* Create or open the database with the default name
 * On success : return 0
 * On failure : print an error message and exit
 */
int init_db_manager();

/* Insert the game given as parameter in the database
 * On success : return the id of the game inserted 
 * On failure : Print an error message and return -1
 */
int add_game(game_result_p e);

/* Add the specified game details to the current database
 * On success : return 0
 * On failure : print an error message and return -1
 */
int add_game_details(game_result_p e);

/* In current game entry, update the db_time field with the value received by
 * get_db_time in game_statistics.
 * On success : return 0
 * On failure : print an error message and return -1
 */
int update_db_time();

/* Start a transaction with the database.
 * It should always be called before calling an add_game_result when multiple
 * processes might access to the same database, because it avoids to have
 * busy database errors. (Using a semaphore to ensure critical section)
 * This function call may block if another process is using the database
 * The time elapsed between start_transaction and commit_transaction should
 * be as short as possible.
 * Additionally to the semaphore handling, transaction allows multiple
 * inserts to be a lot faster. (cf sqlite3 faq and doc)
 * Only a dozen of transaction can be done by second.
 * Nested start_transaction must absolutely be avoided
 *
 * WARNING : Comportment hasn't been tested if database is used simultaneously
 *           with another API.
 */
void start_transaction();

/* Validate the transaction started by start_transaction and allows other
 * processes using the same API to start their transaction.
 */
void commit_transaction();

/* Free all resources associated to the database manager
 * On success : return 0
 * On failure : print an error message and return 1
 */
int close_db_manager();

#endif
