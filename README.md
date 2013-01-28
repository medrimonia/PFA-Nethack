PFA-Nethack
===========

Nethack-3.4.3 can be downloaded, installed and patched for mods with the
nh-setup.sh script.

The folder 'interface-perl' contains the perl interface. It has it's own README
which explains how to use it.

The folder 'patches' contains some patches that disable hunger,
monsters or other features of nethack. nh-setup.sh will ask you if you want to
use them before compiling.

The folder 'java\_starter\_package' contains the source code of a bot written
in java, a script called build\_starter\_package.sh builds a Bot.jar file.

The folder 'include' contains the headers of the used in addition to the basic
nethack version.

The folder 'src' contains the implementation of the additionnal functionalities
provided by our PFA.


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

Once the game is properly started and the map is shown, it's possible to launch 
the bot.

	java -jar java_starter_package/Bot.jar


## Full example

First, cd into the project's root directory and execute the nh-setup.sh script

	$ ./nh-setup.sh
	nethack-343-src.tgz not found, automatically download it now? [Y/n]y

	-- download --
	
	Extracting... 
	Running NetHack's setup script... 
	Copying Makefiles.
	patching file nethack-3.4.3/Makefile
	patching file nethack-3.4.3/include/unixconf.h
	patching file nethack-3.4.3/src/Makefile
	Applying patches...
	Apply disable-hunger.patch? [Y/n]y         <--- patches you want to apply
	patching file nethack-3.4.3/src/eat.c
	Apply disable-monsters.patch? [Y/n]n

	-- compilation --

	************************************************
	Nethack run script installed in nethack-3.4.3/    <--- where to find the game


NetHack is now compiled with the desired patches. Let us build the java bot:

	$ cd java_starter_package/
	$ ./build_starter_package.sh

This will create a Bot.jar file. The last step is to setup the interface (please read the README in the interface-perl directory) and run it with the patched NetHack. From the root directory:

	$ perl interface-perl/interface.pl nethack-3.4.3/nethack

You now have to choose the adventurer's characteristics and skip the intro by pressing return a few times. When the map is finaly shown, you may start the bot (or play the game from the keyboard: useful if the bot gets stuck or to enter the #quit command to end the game). To launch the bot, run in a new terminal window :

	$ java -jar java_starter_package/Bot.jar

	
## Further development

If you wish to develop something for this project, please checkout the branch
"dev" before. Once on this branch, you can create another branch to write your
own code. You may want sometimes to merge your branch with the branch "dev" so
that other contributors can test your code. Then, once everything is ready and
tested, "dev" can be merged with master.

