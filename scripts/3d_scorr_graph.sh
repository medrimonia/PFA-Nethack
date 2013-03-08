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

DATAFILE="${DB_PATH}/sc_3d_data.csv"
PLOTDATA="${DB_PATH}/sc_3d_data_formated.csv"

REQUEST="'select sc_line, sc_column, count(*) as nb_scorrs
            from scorrs
            group by sc_line, sc_column
            order by sc_line, sc_column'"

# This particular syntax is due to a problem when processing argument with
# 'select ... '
echo $REQUEST | xargs sqlite3 -header -csv $DATABASE > $DATAFILE

rm -f $PLOTDATA
for ((x = 0 ; x < 22 ; x++))
do
		for ((y =0; y < 81; y++))
		do
				LINE=$(grep "^$x,$y," ${DATAFILE})
				if [ ${#LINE} -lt 4 ]
				then
						echo "$x,$y,0" >> $PLOTDATA
				else
						echo "$LINE" >> $PLOTDATA
				fi
		done
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

splot '${PLOTDATA}' with pm3d
quit
PLOT