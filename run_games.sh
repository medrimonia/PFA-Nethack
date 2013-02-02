#!/bin/bash

rm -f nethack-3.4.3/nethackdir/pfa.db

for ((i = 1; i <= 5000; i++))
do
		rm -f nethack-3.4.3/nethackdir/mm.log
		nethack-3.4.3/nethack >nh_log &
		java -jar java_starter_package/Bot.jar >bot_log
		if [ $(($i % 10)) == 0 ]
		then
				echo $i
		fi
done

mv nethack-3.4.3/nethackdir/pfa.db games_result.db