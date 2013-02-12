#!/bin/bash

#Variables

DATABASE="different_moves.db"

BOTS[0]="diffusionV2"
BOTS[1]="java_sp"
BOTS[2]="pythonSP"

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
		FILES[i]="${BOTS[i]}.csv"
		REQUEST="'select count(*) as nb_games, max_moves,100*sum(nb_squares_explored) / sum(nb_squares_reachable) as percent_explored, sum(100*nb_sdoors_found)/sum(nb_sdoors) as percent_sdoors_found, 100*sum(nb_scorrs_found) /sum (nb_scorrs) as percent_scorrs_found from seek_secret where bot_name == \"${BOTS[i]}\" group by max_moves'"
		# This particular syntax is due to a problem when processing argument with '...'
		echo $REQUEST | xargs sqlite3 -header -csv $DATABASE >${FILES[i]}
done

for ((i = 0; i < ${#FIELDS[@]};i++))
do
		gnuplot -persist <<PLOT
set yrange [0:110]
set xrange [0:5100]

set xlabel "Number of moves"
set ylabel "Percentage of ${FIELD_NAME[i]}"

set datafile separator ","
set key autotitle columnhead

set tics out

#In case for building an eps-file ...
set terminal postscript enhanced color solid eps 15
set output "graph_${FIELDS[i]}.eps"

#for should be used here but it stills seems difficult
plot for [bot in "${BOTS[@]}"] bot.".csv" using ${MOVE_COLUMN}:${DATA_COLUMN[i]} with linespoints lw 3 title bot
quit
PLOT
done