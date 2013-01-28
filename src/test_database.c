#include <sqlite3.h>

#include "database_manager.h"

int main(int argc, char ** argv){
	// Basic test started
	init_db_manager();
	close_db_manager();
	return 0;
}
