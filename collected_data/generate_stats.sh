#!/bin/bash

if [ $# -lt 1 ]
then
		echo ""
		echo "Usage : $0 <db_folder>"
		kill -SIGINT $$
fi

FOLDER=$1
DATABASE="games_result.db"

# DATAS DEPENDING OF COLUMNS
FIELDS[0]="nb_squares_explored"
FIELDS[1]="nb_squares_reachable"
FIELDS[2]="nb_sdoors_found"
FIELDS[3]="nb_sdoors"
FIELDS[4]="nb_scorrs_found"
FIELDS[5]="nb_scorrs"
XAXIS[0]="Number of squares explored"
XAXIS[1]="Number of squares reachable"
XAXIS[2]="Number of secret doors found"
XAXIS[3]="Number of secret doors in the game"
XAXIS[4]="Number of secret corridors found"
XAXIS[5]="Number of secret corridors in the game"

NB_GAMES=`sqlite3 ${FOLDER}/${DATABASE} 'select count(*) from seek_secret'`


for ((i = 0; i < 6 ; i++))
do
		sqlite3 ${FOLDER}/${DATABASE} "select ${FIELDS[i]}, count(*) from seek_secret group by ${FIELDS[$i]}" > ${FOLDER}/${FIELDS[i]}_result.txt
		sqlite3 ${FOLDER}/${DATABASE} "select AVG, MAX from (select max(NB) as MAX from (select count(*) as NB from seek_secret group by ${FIELDS[i]}) A) A, (select avg(${FIELDS[i]}) as AVG from seek_secret) B" >${FOLDER}/average.txt


		gnuplot -persist <<PLOT

set title "Distribution of collected data over ${NB_GAMES} games"

set yrange [0:*]
set xrange [-1:*]

set xlabel "${XAXIS[i]}"

set ylabel "Number of games with this result"

set datafile separator "|"

set tics out

#In case for building an eps-file ...
set terminal postscript enhanced color solid eps 15
set output "${FOLDER}/${FIELDS[i]}.eps"

plot '${FOLDER}/${FIELDS[i]}_result.txt' with impulses title "games results", '${FOLDER}/average.txt' with impulses lc rgb "blue" lw 3 title "average"

#replot

quit
PLOT
		rm ${FOLDER}/${FIELDS[i]}_result.txt
		rm ${FOLDER}/average.txt
done
