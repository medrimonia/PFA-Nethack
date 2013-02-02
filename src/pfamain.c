#include "middleman.h"
#include "game_statistics.h"

#include "extern.h" // from nethack

void pfa_init()
{
	// do things when the game is initializing

	// middleman stuff

	// game statistics stuff
	update_nb_sdoors();
	update_nb_scorrs();
	update_reachable_squares();
}

void pfa_newloop()
{
	// do things when a new game loop starts

	// middleman stuff

	// game statistics stuff
	update_reached_squares();
}

void pfa_end()
{
	// do things when the game ends

	// game statistics
	gs_submit_game();

	// middleman
	mm_cleanup();

	// nethack stuff
	clearlocks();
}
