#!/bin/bash

STARTM=$(date -u "+%s")

# Options for env. variables
NH_MM_LOGGING=0
NH_MM_SOCKPATH="/tmp/mmsock"

while getopts "s:l" opt; do
	case $opt in
		s)
			NH_MM_SOCKPATH=$OPTARG;
			;;
		l)
			NH_MM_LOGGING=1;
			;;
	esac
done
shift $(( $OPTIND-1 ))
export NH_MM_LOGGING
export NH_MM_SOCKPATH


if [ $# -lt 3 ]
then
		echo "Usage: $0 [options] <nb_games> <launching_bot_cmd> <bot_name>"
		echo "Options:"
		echo -e "\t-l        enable middleman logging"
		echo -e "\t-s <path> set an alternative path for IPC"
		echo "Exemple: $0 100 \"java -jar java_starter_package/Bot.jar\"" java_sp
		exit
fi


# Destionation folder for collected data
DATA_FOLDER="collected_data"
DEST_FOLDER=$DATA_FOLDER/$(date +%y-%m-%d-%Hh%M)-$3-$1

echo $DEST_FOLDER

# Cleanup
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

README=$DEST_FOLDER/README.md

echo "## Source Data" >$README
echo "Number of games : $1" >>$README
echo "Bot : $3" >>$README
echo "CurrentCommit : $(git log -1 --format="%H")" >>$README

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

echo "Processing time: $TTIMEM" >>$README
