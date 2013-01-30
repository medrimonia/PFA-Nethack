#include "middleman.h"
#include "game_statistics.h"

void pfa_init()
{
	// do things when the game is initializing

	// middleman stuff
	mm_init();

	// game statistics stuff
	update_nb_sdoors();
	update_nb_scorrs();
	update_reachable_squares();
}

void pfa_newloop()
{
	// do things when a new game loop starts

	// middleman stuff
	mm_send_update();

	// game statistics stuff
	update_reached_squares();
}

void pfa_end()
{
	// do things when the game ends

	// middleman
	mm_cleanup();

	// game statistics
}
