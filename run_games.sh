#!/bin/bash

STARTM=$(date -u "+%s")

# Options for env. variables
NH_MM_REPLAY=0
NH_MM_LOGGING=0
NH_MM_SOCKPATH="/tmp/mmsock"

while getopts "s:rl" opt; do
	case $opt in
		s)
			NH_MM_SOCKPATH=$OPTARG;
			;;
		r)
			NH_MM_REPLAY=1;
			;;
		l)
			NH_MM_LOGGING=1;
			;;
	esac
done
shift $(( $OPTIND-1 ))
export NH_MM_REPLAY
export NH_MM_LOGGING
export NH_MM_SOCKPATH


if [ $# -lt 3 ]
then
		echo "Usage : $0 <nb_games> <launching_bot_cmd> <bot_name> <details_script (optional)>"
		echo "Usage: $0 [options] <nb_games> <launching_bot_cmd> <bot_name>"
		echo "Options:"
		echo -e "\t-r        enable replay recording"
		echo -e "\t-l        enable middleman logging"
		echo -e "\t-s <path> set an alternative path for IPC"
		echo "Exemple: $0 100 \"java -jar java_starter_package/Bot.jar\"" java_sp
		exit
fi

MAX_MOVES=$(grep "#define MAX_MOVES" src/game_statistics.c | grep -o [0-9]*)

# Destionation folder for collected data
DATA_FOLDER="collected_data"
DEST_FOLDER=$DATA_FOLDER/$(date +%y-%m-%d-%Hh%M)-$3-$1

echo "Output will be send to $DEST_FOLDER"

# Cleanup
rm -f nethack-3.4.3/nethackdir/pfa.db
rm -f nethack-3.4.3/nethackdir/replay


mkdir $DEST_FOLDER


for ((i = 1; i <= $1; i++))
do
		rm -f nethack-3.4.3/nethackdir/mm.log
		nethack-3.4.3/nethack >nh_log &
		$2 >bot_log
		printf "\033[80DRunning tests : %d/%d" $i $1

		if [ $NH_MM_REPLAY -gt 0 ]; then
			mv nethack-3.4.3/nethackdir/replay "$DEST_FOLDER/replay.$i"
		fi
done
echo

mv nethack-3.4.3/nethackdir/pfa.db $DEST_FOLDER/games_result.db

README=$DEST_FOLDER/README.md

echo "## Source Data" >$README
echo "* Number of games : $1" >>$README
echo "* Bot : $3" >>$README
echo "* Max moves : $MAX_MOVES" >>$README
echo "* Current Commit : $(git log -1 --format="%H")" >>$README

SCRIPT=$DATA_FOLDER/generate_stats.sh

$SCRIPT $DEST_FOLDER

STOPM=$(date -u "+%s")

RUNTIMEM=$(expr $STOPM - $STARTM)
if (($RUNTIMEM>3559)); then
TTIMEM=$(printf "%dhours%dm%ds\n" $((RUNTIMEM/3600)) $((RUNTIMEM/60%60)) $((RUNTIMEM%60)))
elif (($RUNTIMEM>59)); then
TTIMEM=$(printf "%dm%ds\n" $((RUNTIMEM/60%60)) $((RUNTIMEM%60)))
else
TTIMEM=$(printf "%ds\n" $((RUNTIMEM)))
fi

echo "* Processing time: $TTIMEM" >>$README

if [ $# -ge 4 ]
then
		echo >>$README
		echo "##Bot details" >>$README
		$4 >>$README	
fi
