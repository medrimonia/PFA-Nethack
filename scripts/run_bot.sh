#!/bin/bash

BOTDIR=$(readlink -f $(find . -name bots))
BOTS=$(grep "^[^#]" $BOTDIR/bots.conf)
RUNNER=$(readlink -f $(find . -name game_runner.sh))

#We want the line feed as a separator
IFS=$'\n'
i=1
for line in $BOTS; do
	printf "\t $i - "
	echo $line  | cut -d\| -f3
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

BOTNAME="$(echo $BOT | cut -d\| -f3)"
BOTPATH="$BOTDIR/$(echo $BOT | cut -d\| -f1)"
LAUNCHER="$(echo $BOT | cut -d\| -f2)"
NBMOVES="$(echo $BOT | cut -d\| -f4)"

if [ ${BOTNAME:-empty} == "empty" ]; then BOTNAMEOPT=""; else BOTNAMEOPT="-b $BOTNAME"; fi
if [ ${BOTPATH:-empty} == "empty" ]; then BOTPATHOPT=""; else BOTPATHOPT="-p $BOTPATH"; fi
if [ ${LAUNCHER:-empty} == "empty" ]; then LAUNCHEROPT=""; else LAUNCHEROPT="-c $LAUNCHER"; fi
if [ ${NBMOVES:-empty} == "empty" ]; then NBMOVESOPT=""; else NBMOVESOPT="-m $NBMOVES"; fi

#Run a game for chosen bot using game_runner.sh
$RUNNER $BOTNAMEOPT $BOTPATHOPT $LAUNCHEROPT $NBMOVESOPT -g 1 -s
