#!/bin/bash

#default options
NH_MAX_MOVES=200
NH_BOT_NAME="java sp"
NH_MM_LOGGING=0
NH_MM_REPLAY=0
NH_DATABASE_PATH="/tmp/test.db"
NB_GAMES=10
BOT_PATH="java_starter_package/Bot.jar"
BOT_CMD="java -Djava.library.path=`locate libunix-java.so | xargs dirname` -jar"

usage() {
	echo "Usage: $0 [options]"
	echo "Options:"
	echo -e "\t-h          Display this help"
	echo -e "\t-g <nb>     The number of games to play"
	echo -e "\t            (Default $NB_GAMES)"
	echo -e "\t-m <nb>     The maximum number of moves allowed for the bot"
	echo -e "\t            (Default $NH_MAX_MOVES)"
	echo -e "\t-p <path>   The path to the Bot main file"
	echo -e "\t            (Default \"$BOT_PATH\")"
	echo -e "\t-c <cmd>    The command used to launch the Bot"
	echo -e "\t            (Default \"$BOT_CMD\")"
	echo -e "\t-b <string> The Bot name"
	echo -e "\t            (Default \"$NH_BOT_NAME\")"
	echo -e "\t-d <path>   Define the path to the database where results will be inserted"
	echo -e "\t            (Default \"$NH_DATABASE_PATH\")"
	echo -e "\t-l          Activate the logger"
	echo -e "\t            (Default Desactivated)"
	echo -e "\t-r          Activate the replay"
	echo -e "\t            (Default Desactivated)"
	echo "Exemple: $0 -b \"python sp\" -p \"pythonsp/bot.py\" -c \"python\""
}


#b specifies the bot name (Unusual chars should be avoided, spaces are accepted)
#l enable middleman logging
#m specifies the number of moves per game
#g specifies the number of games
#p specifies the bot path
#c specifies the bot launching cmd
#d specifies the database path
while getopts "g:m:b:p:c:d:lrh" opt; do
		case $opt in
				h)
						usage;
						exit;
						;;
				g)
						NB_GAMES=$OPTARG;
						;;
				m)
						NH_MAX_MOVES=$OPTARG;
						;;
				b)
						NH_BOT_NAME=$OPTARG;
						;;
				p)
						BOT_PATH=$OPTARG;
						;;
				c)
						BOT_CMD=$OPTARG;
						;;
				d)
						NH_DATABASE_PATH=$OPTARG;
						;;
				l)
						NH_MM_LOGGING=1;
						;;
				r)
						export NH_MM_REPLAY=1;
						;;
		esac
done

NH_MM_SOCKPATH="/tmp/mmsock"$$

export NH_MM_SOCKPATH
export NH_MAX_MOVES
export NH_MM_LOGGING
export NH_BOT_NAME
export NH_DATABASE_PATH

BASEDIR=$(pwd)
DIR="$( cd "$( dirname "$0" )" && pwd )/.."
cd $DIR

TEST_FOLDER="/tmp/test"$$
BOT_FILE=$(basename $BOT_PATH)

mkdir $TEST_FOLDER || exit
#content to move should be improved
cp -r nethack-3.4.3 $TEST_FOLDER
sed -i s:=.*nethack-3.4.3:"=$TEST_FOLDER"/nethack-3.4.3: \
    $TEST_FOLDER/nethack-3.4.3/nethack
cd ..
cd $BASEDIR
cp $BOT_PATH $TEST_FOLDER
#dirtyhack
cp pythonsp/nhmap.py $TEST_FOLDER

printf "Done : 0 of %d" $NB_GAMES
for ((i = 1; i <= NB_GAMES; i++))
do
		#Avoiding mm.log to grow too much in size
		rm -f $TEST_FOLDER/nethack-3.4.3/nethackdir/mm.log
		#Running nethack
		$TEST_FOLDER/nethack-3.4.3/nethack >$TEST_FOLDER/nh_log &
		#Running bot
		$BOT_CMD $TEST_FOLDER/$BOT_FILE $NH_MM_SOCKPATH >$TEST_FOLDER/bot_log
		printf "\033[80DDone : %d of %d" $i $NB_GAMES
done
echo
