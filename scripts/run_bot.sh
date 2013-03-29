#!/bin/bash

BOTDIR=$(readlink -f $(find .. -name bots))
BOTS=$(grep "^[^#]" $BOTDIR/bots.conf)
RUNNER=$(readlink -f $(find .. -name game_runner.sh))

#We want the line feed as a separator
IFS=$'\n'
i=1
for line in $BOTS; do
	printf "\t $i - "
	echo $line  | cut -d\| -f1
	i=$((i+1))
done
printf "\t $i - Quit\n"

choice=0
while [[ $choice -lt 1 || $choice -gt $i ]]; do
	read -p "Choose your bot or quit (Default 1): " choice
	if [ ${choice:-enter} == "enter" ]; then
		choice=1
		break;
	fi
done

if [ $choice -eq $i ]; then
	exit
fi

#Extract chosen bot
BOT=$(printf "$BOTS" | head -$choice | tail -1)

BOTPATH="$(echo $BOT | cut -d\| -f1)"
LAUNCHER="$(echo $BOT | cut -d\| -f2)"
BOTNAME="$(echo $BOT | cut -d\| -f3)"
NBMOVES="$(echo $BOT | cut -d\| -f4)"

#Run a game for chosen bot using game_runner.sh
$RUNNER -b $BOTNAME -p $BOTPATH -c $LAUNCHER -m $NBMOVES -g 1
