#!/bin/bash

BOT[0]="diffusion"
BOT_PATH[0]="bots/diffusion/Bot.jar"
BOT_CMD[0]="java -Djava.library.path=`locate libunix-java.so | xargs dirname` -jar"
BOT[1]="java sp"
BOT_PATH[1]="bots/java_sp/Bot.jar"
BOT_CMD[1]="java -Djava.library.path=`locate libunix-java.so | xargs dirname` -jar"
#BOT[2]="python sp"
#BOT_PATH[2]="bots/python_sp/bot.py"
#BOT_CMD[2]="python"


MAX_MOVES[0]=500
MAX_MOVES[1]=1000
MAX_MOVES[2]=2000
MAX_MOVES[3]=5000
MAX_MOVES[4]=10000

NB_GAMES=25

DATABASE="/tmp/complete_data.db"

BASEDIR=$(pwd)

DIR="$( cd "$( dirname "$0" )" && pwd )/.."
cd $DIR

for ((i = 0; i < ${#BOT[@]}; i++))
do
    for ((j = 0; j < ${#MAX_MOVES[@]}; j++))
    do
        echo "Doing games for '${BOT[$i]}' with '${MAX_MOVES[$j]}' moves"
        scripts/game_runner.sh -g $NB_GAMES        \
                               -m ${MAX_MOVES[$j]} \
                               -b "${BOT[$i]}"     \
                               -p ${BOT_PATH[$i]}  \
                               -c "${BOT_CMD[$i]}" \
                               -d $DATABASE
    done
done

cd $BASEDIR