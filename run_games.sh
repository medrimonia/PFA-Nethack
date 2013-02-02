#!/bin/bash

rm nethack-3.4.3/nethackdir/pfa.db

for ((i = 0; i < 100; i++))
do
		nethack-3.4.3/nethack >/dev/null &
		java -jar java_starter_package/Bot.jar >/dev/null
		if [ $(($i % 10)) == 0 ]
		then
				echo $i
		fi
done

mv nethack-3.4.3/nethackdir/pfa.db games_result.db