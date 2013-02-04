#!/bin/bash

if [ $# -lt 3 ]
then
		echo "Usage : $0 <nb_games> <launching_bot_cmd> <bot_name>"
		echo "Exemple : $0 100 \"java -jar java_starter_package/Bot.jar\""
		kill -SIGINT $$
fi

DATA_FOLDER="collected_data"

DEST_FOLDER=$DATA_FOLDER/$(date +%y-%m-%d-%Hh%M)-$3-$1

echo $DEST_FOLDER

rm -f nethack-3.4.3/nethackdir/pfa.db

for ((i = 1; i <= $1; i++))
do
		rm -f nethack-3.4.3/nethackdir/mm.log
		nethack-3.4.3/nethack >nh_log &
		$2 >bot_log
		if [ $(($i % 10)) == 0 ]
		then
				echo $i
		fi
done

mkdir $DEST_FOLDER

mv nethack-3.4.3/nethackdir/pfa.db $DEST_FOLDER/games_result.db