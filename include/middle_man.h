#ifndef MIDDLE_MAN_H
#define MIDDLE_MAN_H

#include "winprocs.h" /* name should be updated or
											 * Makefile should include the src folder */

/* This module must fulfill two main functionnalities
 * - Intercept communications between kernel nethack and the choosen output
 *   - Build a map model with every information needed
 *   - Send the information needed to the bot_handler once the kernel is
 *     waiting for the next action.
 *   - Broadcast all informations to the real window_procs
 *     (wintty,QT, etc...)
 * - Receive informations from the bot
 *   - Disabling information reception from the real window_procs
 *   - Enabling information reception from the bot_handler
 */

/* Starts the middle_man with the specified windowprocs as real window_procs
 * Return :
 * The middle_man window_procs address if everything worked as intended
 * null if an error has occured
 */
struct window_procs * install_middle_man(struct window_procs * windowprocs);

/* Getter on the visible map 
 * Should reflect what a user would see on a tty 
 * Returns : the screen char representing the tile at x y, eg @.|-+# */
int get_glyph(int x,int y);

/* Return the height of the map */
int get_map_height();

/* Return the width of the map */
int get_map_width();

/* Return the current dungeon level */
int get_dungeon_level();

/* Return the output seen by the user after the last action */
const char * get_last_action_result();

/* Add the specified char to the nethack kernel input */
void write_char(char c);

#endif
