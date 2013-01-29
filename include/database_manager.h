#ifndef DATABASE_MANAGER_H
#define DATABASE_MANAGER_H

#include <stdbool.h>

struct database_entry{
	char * mode;
	int nb_sdoors;
	int nb_sdoors_discovered;
	int nb_scorrs;
	int nb_scorrs_discovered;
};

typedef struct database_entry * database_entry_p;


/* Create or open the database with the default name
 * return 0 on success
 * print an error message and exit on error
 */
int init_db_manager();

bool exist_table(const char * table_name);

void create_table(const char * table_name);

/* Add the specified entry to the current database
 */
int add_entry(database_entry_p e);

/* Free all ressources associated to the database manager
 * return 0 on success
 * print an error message and return 1 on error
 */
int close_db_manager();

#endif
