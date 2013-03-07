#!/bin/bash

#Variables

DATABASE="database.db"

DATAFILE="data.csv"
PLOTDATA="data_formated.csv"

REQUEST="'select scorr_line, scorr_column, count(*) as nb_scorrs from scorrs group by scorr_line, scorr_column'"
# This particular syntax is due to a problem when processing argument with
# 'select ... '
echo $REQUEST | xargs sqlite3 -header -csv $DATABASE > $DATAFILE
rm -f $PLOTDATA
for ((x = 0 ; x < 22 ; x++))
do
		grep "^$x" ${DATAFILE} >> $PLOTDATA
		echo "" >> $PLOTDATA
done

gnuplot -persist <<PLOT
set yrange [0:80]
set xrange [0:21]

set xlabel "Line"
set ylabel "Column"

set datafile separator ","
set key autotitle columnhead

set tics out

#In case for building an eps-file ...
#set terminal postscript enhanced color solid eps 15
#set output "3d_graph.eps"

set view 0,90

set style line 1 lt 4 lw .5
set pm3d at s hidden3d 1

#for should be used here but it stills seems difficult
splot '${PLOTDATA}' with pm3d
quit
PLOT