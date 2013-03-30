#include "pfamain.h"

#include "middleman.h"
#include "game_statistics.h"

#include "extern.h" // from nethack

# if defined(__APPLE__) || defined(BSD) || defined(LINUX) || defined(ULTRIX) || defined(CYGWIN32)
#include <sys/time.h>
#endif

void
pfa_setrandom(void)
{
	char * seed_s = nh_getenv("NH_SEED");
	int seed;
	if (seed_s == NULL) {
#ifdef RANDOM	/* srandom() from sys/share/random.c */
		seed = time((time_t *)0);
	}
	else {
		seed = atoi(seed_s);
	}
	srandom((unsigned int) seed);
#else
# if defined(__APPLE__) || defined(BSD) || defined(LINUX) || defined(ULTRIX) || defined(CYGWIN32) /* system srandom() */
#  if defined(BSD) && !defined(POSIX_TYPES)
#   if defined(SUNOS4)
		(void)
#   endif
			seed = time((long *)0);
#  else
			struct timeval tv;
			gettimeofday(&tv, NULL);
			seed = (int) tv.tv_sec + (tv.tv_usec/10000)*1000000;
#  endif
		}
		else {
			seed = atoi(seed_s);
		}
		srandom(seed);
# else
#  ifdef UNIX	/* system srand48() */
		seed = time((time_t *)0);
	}
	else {
		seed = atoi(seed_s);
	}
	srand48((long) seed);
#  else		/* poor quality system routine */
		seed = time((time_t *)0);
	}
	else {
		seed = atoi(seed_s);
	}
	srand(seed);
#  endif
# endif
#endif
	gs_set_seed(seed);
}

void pfa_init()
{
	// do things when the game is initializing

	// middleman stuff

	// game statistics stuff
	gs_init();
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
	gs_end_game_if_needed();
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

void pfa_new_level_reached(){
	gs_new_level();
}

void pfa_add_sdoor(int line, int column){
	statistic_add_sdoor(line, column);
}

void pfa_scorr_discovery(int line, int column){
	statistic_add_scorr_discovery(line, column);
}

void pfa_sdoor_discovery(int line, int column){
	statistic_add_sdoor_discovery(line, column);
}
