PFA-Nethack
===========

Nethack-3.4.3 can be downloaded, installed and patched for mods with the
nh-setup.sh script.

The folder 'collected_data' contains some games databases and some graphs
illustrating their content.

The folder 'architecture' contains more informations about the architecture and
the database used to store all the games details.

The folder 'install' contains some patches needed to work with this modified
version of nethack, those patches are mainly adding hooks in the game. A
modified version of nethack's Makefile is also contained in this folder,
ensuring that the files from the PFA will be used.

The folder 'patches' contains some patches that disable hunger, monsters or
other features of nethack. Those patches are mainly modifying the game
experience but aren't needed to run bots (even if the bots performance are
strongly increased by their application).

The folder 'bots' contains all the bots developped during the project

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

