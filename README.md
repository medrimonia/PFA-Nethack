PFA-Nethack
===========

Nethack-3.4.3 can be downloaded, installed and patched for mods with the
nh-setup.sh script.

The folder 'collected_data' contains some games databases and some graphs
illustrating their content.

The folder 'database_details' contains more informations about the database used
to store all the games details.

The folder 'install' contains some patches needed to work with this modified
version of nethack, those patches are mainly adding hooks in the game. A
modified version of nethack's Makefile is also contained in this folder,
ensuring that the files from the PFA will be used.

The folder 'patches' contains some patches that disable hunger, monsters or
other features of nethack. Those patches are mainly modifying the game
experience but aren't needed to run bots (even if the bots performance are
strongly increased by their application).

The folder 'java\_starter\_package' contains the source code of a bot written
in java, a script called build\_starter\_package.sh builds a Bot.jar file.

The folder 'diffusion\_bot' contains the source code of a bot written in java,
all kind of informations about this bot are gathered in this folder.

The folder 'pythonsp' contains the source code of a bot written in python,
more details about this bot can be found in the appropriate folder.

The folder 'special_bot' contains the source code of a bot written in python, it
is particularly designed for finding a door in a single room of 10*10 squares.

The folder 'include' contains the headers of the used in addition to the basic
nethack version.

The folder 'src' contains the implementation of the additionnal functionalities
provided by our PFA.

The folder 'scripts' contains scripts allowing to run several games, to generate
graphs or other utilities based on our programs. Every script is described in
'scripts/README.md'

The folder 'viewer' contains a program called `viewer.pl` which can show
replays of games played by bots.


## Used package

Here's the list of the packages required for the provided bots programmed in Java
* libunixsocket-java _The package might also be named libmatthew-java_
* libsqlite3


## Compiling

It's necessary to run the script nh-setup.sh in order to build the nethack
binary with patches.

Some bots need to be built by using the appropriate script.

The perl modules viewer and dummy_client require some dependencies in order to
run (refer to the appropriate README).


## Further development

If you wish to develop something for this project, please checkout the branch
"dev" before. Once on this branch, you can create another branch to write your
own code. You may want sometimes to merge your branch with the branch "dev" so
that other contributors can test your code. Then, once everything is ready and
tested, "dev" can be merged with master.

