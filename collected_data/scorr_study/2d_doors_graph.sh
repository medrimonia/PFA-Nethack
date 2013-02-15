#!/bin/bash

#Variables

DATABASE="database.db"

LINE_DATA="line_data.csv"
COLUMN_DATA="col_data.csv"

LINE_REQUEST="'select scorr_line, count(*) as nb_scorrs from scorrs group by scorr_line'"
COLUMN_REQUEST="'select scorr_column, count(*) as nb_scorrs from scorrs group by scorr_column'"
# This particular syntax is due to a problem when processing argument with
# 'select ... '
echo $LINE_REQUEST | xargs sqlite3 -header -csv $DATABASE > $LINE_DATA
echo $COLUMN_REQUEST | xargs sqlite3 -header -csv $DATABASE > $COLUMN_DATA

#Line graph
gnuplot -persist <<PLOT
set xrange [0:21]
set yrange [0:*]

set xlabel "Line"
set ylabel "NbScorrs"

set datafile separator ","
set key autotitle columnhead

set tics out
set style fill solid

#In case for building an eps-file ...
set terminal postscript enhanced color solid eps 15
set output "line_graph.eps"

#for should be used here but it stills seems difficult
plot '${LINE_DATA}' with boxes
quit
PLOT

#Column graph
gnuplot -persist <<PLOT
set xrange [0:80]
set yrange [0:*]

set xlabel "Column"
set ylabel "NbScorrs"

set datafile separator ","
set key autotitle columnhead

set tics out
set style fill solid

#In case for building an eps-file ...
set terminal postscript enhanced color solid eps 15
set output "column_graph.eps"

#for should be used here but it stills seems difficult
plot '${COLUMN_DATA}' with boxes
quit
PLOT