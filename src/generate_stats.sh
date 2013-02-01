#!/bin/bash

FIELDS[0]="nb_squares_explored"
FIELDS[1]="nb_squares_reachable"
FIELDS[2]="nb_sdoors_found"
FIELDS[3]="nb_sdoors_reachable"
FIELDS[4]="nb_scorrs_found"
FIELDS[5]="nb_scorrs_reachable"

for ((i = 0; i < 6 ; i++))
do
		sqlite3 pfa.db "select ${FIELDS[i]}, count(*) from seek_secret group by ${FIELDS[$i]}" > ${FIELDS[i]}_result.txt

		gnuplot -persist <<PLOT
set yrange [0:1000]

set title "distribution of random data"
set datafile separator "|"

#In case for building an eps-file ...
set terminal postscript enhanced color solid eps 15
set output "${FIELDS[i]}.eps"

plot '${FIELDS[i]}_result.txt' with impulses

#replot

quit
PLOT
		rm ${FIELDS[i]}_result.txt
done