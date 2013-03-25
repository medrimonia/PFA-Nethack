SCRIPTS
=======

All the script presented here are supposed to work with the modified version
of nethack. There's mainly two categories : scripts running games massively and
scripts generating graph from a database.

## Script running games

Before running those scripts, make sure that the Bot used files are up to date.

### Game Runner
The script _game\_runner.sh_ has been created to run massive games with one bot.
It will launch a certain number of games and insert the results in a database.

In order to allow multiple executions of game runner to run simultaneously, and
also to allow developers to recompile bots and nethack while a script is
running, all necessary datas are copied to a new folder in _/tmp/_.

Example :
```
./game_runner -g 10 -m 2000 -d new_database.db
```

This script takes the following parameters :
* -g <nb>     : The number of games to play
	* _Default : 10_
* -m <nb>     : The maximum number of moves allowed for the bot
 	* _Default : 200_
* -p <path>   : The path to the Bot main file
	* _Default : "bots/java_sp/Bot.jar"_
* -c <cmd>    : The command used to launch the Bot
	* _Default : "java -Djava.library.path=`locate libunix-java.so | xargs dirname` -jar"_
* -b <string> : The Bot name
	* _Default : "java sp"_
* -d <path>   : Define the path to the database where results will be inserted
	* _Default : "/tmp/test.db"_
* -l          : Activate the logger
	* _Default : Desactivated_
* -r          : Activate the replay
	* _Default : Desactivated_

### Data Builder
The script _data\_builder.sh_ is mainly designed to be hand modified, it will
simply use the game runner to run games with different bots and different
max_moves allowed.
The main use is to easily feed a database with a lot of games and then compare
bots performances, taking max_moves into account.

## Script creating Graphs

The main line of those scripts is to take a database as parameter and to
generate graphs with gnuplot. Temporary files will be used sometimes, all the
files created will be created in the folder containing the database.

All those scripts might need modifications if bot's name changes or if
modifications are done to the database.

It is highly recommended that the folder containing the database contain only
graphs and the database when running those scripts.

### 2d doors graph
This script generate graphs with the number of secret doors for each line/col.

### 3d doors graph
This script open a gnuplot view, showing the number of secret doors found for
each location.

### 2d scorr graph
This script generate graphs with the number of secret corridors for each
line/col.

### 3d scorr graph
This script open a gnuplot view, showing the number of secret corridors found
for each location.

### Impulses graph
This script will produce bar-graphs for each bot, number of move and field. This
will create a folder for each bot in the database provided

### Move graph
This script will produce graphs comparing the performance of the bots according
to the number of moves allowed for each field of comparison
