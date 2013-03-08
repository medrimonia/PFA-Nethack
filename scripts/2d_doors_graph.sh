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

LINE_DATA="${DB_PATH}/sd_line_data.csv"
COLUMN_DATA="${DB_PATH}/sd_col_data.csv"

LINE_REQUEST="'select sd_line, count(*) as nb_doors
                 from sdoors
                 group by sd_line'"
COLUMN_REQUEST="'select sd_column, count(*) as nb_doors
                   from sdoors
                   group by sd_column'"

# This particular syntax is due to a problem when processing argument with
# 'select ... '
echo $LINE_REQUEST | xargs sqlite3 -header -csv $DATABASE > $LINE_DATA
echo $COLUMN_REQUEST | xargs sqlite3 -header -csv $DATABASE > $COLUMN_DATA

#Line graph
gnuplot -persist <<PLOT
set xrange [0:21]
set yrange [0:*]

set xlabel "Line"
set ylabel "NbDoors"

set datafile separator ","
set key autotitle columnhead

set tics out
set style fill solid

#In case for building an eps-file ...
set terminal postscript enhanced color solid eps 15
set output "${DB_PATH}/sd_line_graph.eps"

plot '${LINE_DATA}' with boxes
quit
PLOT

#Column graph
gnuplot -persist <<PLOT
set xrange [0:80]
set yrange [0:*]

set xlabel "Column"
set ylabel "NbDoors"

set datafile separator ","
set key autotitle columnhead

set tics out
set style fill solid

#In case for building an eps-file ...
set terminal postscript enhanced color solid eps 15
set output "${DB_PATH}/sd_column_graph.eps"

plot '${COLUMN_DATA}' with boxes
quit
PLOT