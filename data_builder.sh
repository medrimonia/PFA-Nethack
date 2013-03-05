#!/bin/bash

BOT[0]="diffusion"
BOT_PATH[0]="diffusion_bot/Bot.jar"
BOT[1]="java sp"
BOT_PATH[1]="java_starter_package/Bot.jar"
MAX_MOVES[0]=500
MAX_MOVES[1]=1000
MAX_MOVES[2]=2000
MAX_MOVES[3]=5000
MAX_MOVES[4]=10000

NB_GAMES=20

for ((i = 0; i < ${#BOT[@]}; i++))
do
		for ((j = 0; j < ${#MAX_MOVES[@]}; j++))
		do
				echo "Doing games for '${BOT[$i]}' with '${MAX_MOVES[j]}' moves"
				./game_runner.sh -g $NB_GAMES       \
					               -m ${MAX_MOVES[$j]} \
						             -b ${BOT[$i]}       \
				                 -p ${BOT_PATH[$i]}
		done
done
				