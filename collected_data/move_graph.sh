#!/bin/bash

#Variables

DATABASE="diffusion.db"

BOTS[0]="diffusion"

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
		FILES[i]="data_${BOTS[i]}.csv"
		sqlite3 -header -csv $DATABASE 'select count(*) as nb_games,max_moves,100 * sum(nb_squares_explored) / sum(nb_squares_reachable) as percent_explored, sum(100 * nb_sdoors_found)/sum(nb_sdoors) as percent_sdoors_found, 100 * sum(nb_scorrs_found) /sum (nb_scorrs) as percent_scorrs_found from seek_secret group by max_moves' >${FILES[i]}
done

for ((i = 0; i < ${#FIELDS[@]};i++))
do
		gnuplot -persist <<PLOT
set yrange [0:110]
set xrange [0:20100]

set xlabel "Number of moves"
set ylabel "Percentage of ${FIELD_NAME[i]}"

set datafile separator ","
set key autotitle columnhead

set tics out

#In case for building an eps-file ...
set terminal postscript enhanced color solid eps 15
set output "graph_${FIELDS[i]}.eps"


plot for [k=0:${#BOTS[@]}-1] '${FILES[k]}' using ${MOVE_COLUMN}:${DATA_COLUMN[i]} with linespoints lw 3 title '${BOTS[k]}'
quit
PLOT
done