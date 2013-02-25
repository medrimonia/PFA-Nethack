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

/* Start a transaction with the database.
 * It should always be called before calling an add_game_result when multiple
 * processes might access to the same database, because it avoids to have
 * busy database errors. (Using a semaphore to ensure critical section)
 * This function call may block if another process is using the database
 * The time elapsed between start_transaction and commit_transaction should
 * be as short as possible.
 * Additionnally to the semaphore handling, transaction allows multiple
 * inserts to be a lot faster. (cf sqlite3 faq and doc)
 * Only a dozen of transaction can be done by second.
 * Nested start_transaction must absolutly be avoided
 */
void start_transaction();

/* Validate the transaction started by start_transaction*/
void commit_transaction();

/* Free all ressources associated to the database manager
 * return 0 on success
 * print an error message and return 1 on error
 */
int close_db_manager();

#endif
