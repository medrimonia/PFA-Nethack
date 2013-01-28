#ifndef DATABASE_MANAGER_H
#define DATABASE_MANAGER_H

/* Create or open the database with the default name
 * return 0 on success
 * print an error message and exit on error
 */
int init_db_manager();

/* Free all ressources associated to the database manager
 * return 0 on success
 * print an error message and return 1 on error
 */
int close_db_manager();

#endif
