#!/bin/bash

#Variables

DATABASE="different_moves.db"

BOTS[0]="diffusion"
BOTS[1]="java_sp"

MOVE_COLUMN=2

FIELDS[0]="percent_explored"
DATA_COLUMN[0]=3
FIELD_NAME[0]="squares explored"
YRANGE[0]=110
FIELDS[1]="percent_sdoors_found"
DATA_COLUMN[1]=4
FIELD_NAME[1]="secret doors found"
YRANGE[1]=110
FIELDS[2]="percent_scorrs_found"
DATA_COLUMN[2]=5
FIELD_NAME[2]="secret corridors found"
YRANGE[2]=110
FIELDS[3]="level_reached"
DATA_COLUMN[3]=6
FIELD_NAME[3]="average level reached"
YRANGE[3]=15

#Generating data files
for ((i = 0; i < ${#BOTS[@]}; i++))
do
		FILES[i]="${BOTS[i]}.csv"
		REQUEST="'select count(*) as nb_games, max_moves,100*sum(nb_squares_explored) / sum(nb_squares_reachable) as percent_explored, sum(100*nb_sdoors_found)/sum(nb_sdoors) as percent_sdoors_found, 100*sum(nb_scorrs_found) /sum (nb_scorrs) as percent_scorrs_found, avg(level_reached) as level_reached from seek_secret where bot_name == \"${BOTS[i]}\" group by max_moves'"
		# This particular syntax is due to a problem when processing argument with '...'
		echo $REQUEST | xargs sqlite3 -header -csv $DATABASE >${FILES[i]}
done

for ((i = 0; i < ${#FIELDS[@]};i++))
do
		gnuplot -persist <<PLOT
set yrange [0:${YRANGE[i]}]
set xrange [0:200100]

set xlabel "Number of moves per game"
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