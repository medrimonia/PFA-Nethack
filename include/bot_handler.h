#ifndef BOT_HANDLER_H
#define BOT_HANDLER_H

/* This module must allow two main options
 * - Translate structured informations to a message following the rules
 *   specified by the protocol available on the wiki of the PFA-Nethack
 *   project on github.
 * - Translate high-level orders received from the bot to a set of atomic
 *   actions of nethack.
 */

/* - Launch the server
 * - Wait for a connection from the bot
 * - Initialize the communication with the bot by sending the seed
 * Return :
 * 0 if everything worked as intended
 * 1 if an error has occured
 */
int initialize_server(int bot_seed);


/* Transmit the current game status to the bot.
 * This function use the getters specified in middle_man.h in order to
 * get the informations needed.
 * Return :
 * 0 if everything worked as intended
 * 1 if an error has occured
 */
int broadcast_turn();

/* - get the last action broadcasted by the bot
 * - translate the action in atomic actions as nethack specifies them
 * - apply the action to the kernel using the write_char function specified
 *   in middle_man.h
 * if the action specified cannot be applied (moving into a wall, trying to
 * open a wall, ...) an error message is thrown to the bot and as result of
 * the function.
 * Return :
 * 0 if everything worked as intended
 * 1 if an error has occured
 */
int apply_bot_action();

#endif
