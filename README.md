PFA-Nethack
===========

Nethack-3.4.3 can be downloaded and installed applying patches (or not) with the
nh-setup.sh script.

The folder 'interface-perl' contains code allowing to launch nethack in a
modified version, allowing the use of bot. It contains it's own README.

The folder 'patches' contains some patches allowing to disable hunger or other
features of nethack.

The folder 'java_starter_package' contains the source code of a bot, a script
called build_starter_package.sh build a runnable jar which contains the bot.

## Compiling
It's necessary to run the script nh-setup.sh in order to build the nethack
binary with patches

The bot must be build by using the appropriated script.

The perl module doesn't need to be compiled, but some dependencies are needed.
(refer to the appropriate README)

## Running a game
The module perl need to be launched first, it will launch it's own nethack game:
>>> perl interface-perl/interface.pl <nethack_binary_path>

Neither the bot nor the interface handle the game beginning actually, you have
to choose the character and press enter once or twice in order to skip the
initial message before starting the bot.
Once the game is properly started, it's possible to launch the bot.
>>> java -jar java_starter_package.jar