#!/bin/bash

if [ $# -lt 1 ]
then
		echo "usage: `basename $0` <database_name>"
		exit
fi

DATABASE=$1;

if [ ! -f $DATABASE ]
then
		echo "'$DATABASE' doesn't exist, please provide a valid database"
		exit
fi

DB_PATH=$(dirname $DATABASE)

#Variables

BOTS[0]="diffusion"
BOTS[1]="java sp"
#BOTS[2]="python sp"

MOVE_COLUMN=2

FIELDS[0]="percent_explored"
DATA_COLUMN[0]=3
FIELD_NAME[0]="squares explored"
FIELDS[1]="percent_sdoors_found"
DATA_COLUMN[1]=4
FIELD_NAME[1]="secret doors found"
FIELDS[2]="percent_scorrs_found"
DATA_COLUMN[2]=5
FIELD_NAME[2]="secret corridors found"

#Generating data files
for ((i = 0; i < ${#BOTS[@]}; i++))
do
		BOT_FILE[i]=$(echo ${BOTS[i]} | sed 's/ /-/')
		echo "Bot file : ${BOT_FILE[i]}"
    FILES[i]="${DB_PATH}/${BOT_FILE[i]}.csv"
    REQUEST="'select count(*) as nb_games,
                     max_moves,
                     100*sum(nb_squares_explored)/ sum(nb_squares_reachable) as percent_explored,
                     100*sum(nb_sdoor_discovery)/sum(nb_sdoors) as percent_sdoors_found,
                     100*sum(nb_scorr_discovery)/sum (nb_scorrs) as percent_scorrs_found
              from game_results
              where bot_name == \"${BOTS[i]}\" group by max_moves;'"
		echo "redirection to ${FILES[i]}"
    # This particular syntax is due to a problem when processing argument with '...'
    echo $REQUEST | xargs sqlite3 -header -csv $DATABASE >${FILES[i]}
done

pushd $DB_PATH >/dev/null

MAX_X=$(sqlite3 $DATABASE 'select max(max_moves) from games')

for ((i = 0; i < ${#FIELDS[@]};i++))
do
		gnuplot -persist <<PLOT
set yrange [0:110]
set xrange [0:${MAX_MOVES}]

set xlabel "Number of moves"
set ylabel "Percentage of ${FIELD_NAME[i]}"

set datafile separator ","
set key autotitle columnhead

set tics out

#In case for building an eps-file ...
set terminal postscript enhanced color solid eps 15
set output "graph_${FIELDS[i]}.eps"

plot for [bot in "${BOT_FILE[@]}"] bot.".csv" using ${MOVE_COLUMN}:${DATA_COLUMN[i]} with linespoints lw 3 title bot
quit
PLOT
done

popd $DB_PATH >/dev/null