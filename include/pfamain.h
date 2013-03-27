#ifndef PFAMAIN_H
#define PFAMAIN_H

void pfa_init();
void pfa_newloop();
void pfa_end();

/**
 * @brief This function initialize the random number generator for NetHack.
 *
 * The seed used for the initialization is taken from an environment variable.
 * If the variable is not specified, initialization is done based on the
 * number of seconds and milliseconds since Epoch.
 */
void pfa_setrandom();

/**
 * @brief This function is called each time the player enters on a new NetHack
 * level (it is not called when the player return on a previously reached
 * level)
 */
void pfa_new_level_reached();

/**
 * @brief This function is called only when a secret door is added after a new
 * level has been reached, it is not called for every secret door created when
 * making a new level.
 */
void pfa_add_sdoor(int line, int column);

/**
 * @brief This function is called every time a secret corridor is discovered,
 * line and column specifies the position of the previously secret corridor
 */
void pfa_scorr_discovery(int line, int column);

/**
 * @brief This function is called every time a secret door is discovered,
 * line and column specifies the position of the previously secret door
 */
void pfa_sdoor_discovery(int line, int column);

#endif
