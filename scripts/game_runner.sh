#!/bin/bash

STARTM=$(date -u "+%s")

#default options
NH_MAX_MOVES=200
NH_BOT_NAME="java sp"
NH_MM_LOGGING=0
NH_DATABASE_PATH="/tmp/test.db"
NB_GAMES=10
BOT_PATH="java_starter_package/Bot.jar"
BOT_CMD="java -Djava.library.path=`locate libunix-java.so | xargs dirname` -jar"


#b specifies the bot name (Unusual chars should be avoided, spaces are accepted)
#l enable middleman logging
#m specifies the number of moves per game
#g specifies the number of games
#p specifies the bot path
#c specifies the bot launching cmd
#d specifies the database path
while getopts "g:m:b:p:c:d:l" opt; do
		case $opt in
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
		esac
done

NH_MM_SOCKPATH="/tmp/mmsock"$$

export NH_MM_SOCKPATH
export NH_MAX_MOVES
export NH_MM_LOGGING
export NH_BOT_NAME
export NH_DATABASE_PATH

#Some tests should be runned first

echo "Database_path : $NH_DATABASE_PATH"

TEST_FOLDER="/tmp/test"$$
BOT_FILE=$(basename $BOT_PATH)

mkdir $TEST_FOLDER || exit
#content to move should be improved
cp -r nethack-3.4.3 $TEST_FOLDER
sed -i s:=.*nethack-3.4.3:"=$TEST_FOLDER"/nethack-3.4.3: \
    $TEST_FOLDER/nethack-3.4.3/nethack
cp $BOT_PATH $TEST_FOLDER
#dirtyhack
cp pythonsp/nhmap.py $TEST_FOLDER

for ((i = 1; i <= NB_GAMES; i++))
do
		#dirtyhack
		cp pythonsp/nhmap.py $TEST_FOLDER
		#Avoiding mm.log to grow too much in size
		rm -f $TEST_FOLDER/nethack-3.4.3/nethackdir/mm.log
		#Running nethack
		$TEST_FOLDER/nethack-3.4.3/nethack >$TEST_FOLDER/nh_log &
		#Running bot
		$BOT_CMD $TEST_FOLDER/$BOT_FILE $NH_MM_SOCKPATH >$TEST_FOLDER/bot_log
		printf "\033[80DDone : %d of %d" $i $NB_GAMES
done
echo
