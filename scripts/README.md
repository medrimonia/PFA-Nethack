SCRIPTS
=======

All the script presented here are supposed to work with the modified version
of nethack. There's mainly two categories : scripts running games massively and
scripts generating graph from a database.

## Script running games

### Game Runner
The script _game\_runner.sh_ has been created to run massive games with one bot.
It will launch a certain number of games and insert the results in a database.

Example :
```
./game_runner -g 10 -m 2000 -d new_database.db
```

This script takes the following parameters :
* -g <nb>   : The number of games to play _Default : 10_
* -m <nb>   : The maximum number of moves allowed for the bot _Default : 20_
* -p <path> : The path to the Bot main file _Default : "java_starter_package/Bot.jar"
* -