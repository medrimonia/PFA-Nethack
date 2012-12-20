PFA-Nethack
===========

Nethack-3.4.3 can be downloaded, installed and patched for mods with the
nh-setup.sh script.

The folder 'interface-perl' contains the perl interface. It has it's own README
which explains how to use it.

The folder 'patches' contains some patches allowing to disable hunger,
monsters or other features of nethack.

The folder 'java\_starter\_package' contains the source code of a bot written
in java, a script called build\_starter\_package.sh builds a Bot.jar file.


## Compiling

It's necessary to run the script nh-setup.sh in order to build the nethack
binary with patches

The bot must be built by using the appropriate script.

The perl interface requires some dependencies in order to run
(refer to the appropriate README).


## Running a game

The interface needs to be started first, from the root directory :

	perl interface-perl/interface.pl path/to/nethack

Neither the bot nor the interface handle the game start automatically, you have
to choose the character class and press enter once or twice in order to skip the
initial message before starting the bot.

Once the game is properly started and the map is shown, it's possible to launch the bot.

	java -jar java_starter_package/Bot.jar
