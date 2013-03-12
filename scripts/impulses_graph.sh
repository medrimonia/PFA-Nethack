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

# DATAS DEPENDING OF COLUMNS
FIELDS[0]="nb_squares_explored"
FIELDS[1]="nb_squares_reachable"
FIELDS[2]="nb_sdoor_discovery"
FIELDS[3]="nb_sdoors"
FIELDS[4]="nb_scorr_discovery"
FIELDS[5]="nb_scorrs"
FIELDS[6]="level_reached"
XAXIS[0]="Number of squares explored"
XAXIS[1]="Number of squares reachable"
XAXIS[2]="Number of secret doors found"
XAXIS[3]="Number of secret doors in the game"
XAXIS[4]="Number of secret corridors found"
XAXIS[5]="Number of secret corridors in the game"
XAXIS[6]="Deepest level reached"

BOTS=( $(sqlite3 ${DATABASE} 'select distinct bot_name from games' | sed 's/ /-/') )

#For each bot
for ((b = 0; b < ${#BOTS[@]}; b++))
do
		BOT_FOLDER=${DB_PATH}/${BOTS[b]}
		BOT_NAME="$(echo ${BOTS[b]} | sed 's/-/ /')"
		
		# Creating the folder if it doesn't exist yet
		if [ ! -d ${BOT_FOLDER} ]
		then
				mkdir ${BOT_FOLDER}
		fi

		REQUEST="'select distinct max_moves
                from game_results
                where bot_name == \"${BOT_NAME}\";'"
		MAX_MOVES=( `echo $REQUEST | xargs sqlite3 ${DATABASE}`)
		# For each max_moves
		for (( m = 0; m < ${#MAX_MOVES[@]}; m++))
		do
				# For each field
				for ((i = 0; i < 7 ; i++))
				do
						# File used
						RESULT_FILE=${BOT_FOLDER}/${FIELDS[i]}_result.txt
						AVERAGE_FILE=${BOT_FOLDER}/${FIELDS[i]}_average.txt
						OUTPUT_FILE=${BOT_FOLDER}/m_${MAX_MOVES[m]}_${FIELDS[i]}.eps

						# Getting results
						REQUEST="'select ${FIELDS[i]}, count(*) as nb
                        from game_results
                        where max_moves == ${MAX_MOVES[m]}
                          and bot_name  == \"${BOT_NAME}\"
                        group by ${FIELDS[$i]}'"
						echo $REQUEST | xargs sqlite3 ${DATABASE} >${RESULT_FILE}
		
						# Getting average and max
						REQUEST="'select AVG, MAX
                        from (select max(NB) as MAX
                                from (select count(*) as NB
                                        from game_results
                                        where max_moves == ${MAX_MOVES[m]}
                                          and bot_name  == \"${BOT_NAME}\"
                                        group by ${FIELDS[i]}) A) A,
                             (select avg(${FIELDS[i]}) as AVG
                                from game_results
                                where max_moves == ${MAX_MOVES[m]}
                                  and bot_name  == \"${BOT_NAME}\" ) B'"
						echo $REQUEST | xargs sqlite3 ${DATABASE} >${AVERAGE_FILE}

						# Getting game_count
						REQUEST="'select count(*)
                        from game_results
                        where max_moves == ${MAX_MOVES[m]}
                          and bot_name  == \"${BOT_NAME}\"'"
						NB_GAMES=$( echo $REQUEST | xargs sqlite3 $DATABASE)
						
						gnuplot -persist <<PLOT

set title "Distribution of collected data over ${NB_GAMES} games with bot '${BOT[b]}' having ${MAX_MOVES[m]} moves allowed"

set yrange [0:*]
set xrange [-1:*]

set xlabel "${XAXIS[i]}"

set ylabel "Number of games with this result"

set datafile separator "|"

set tics out

#In case for building an eps-file ...
set terminal postscript enhanced color solid eps 15
set output "${OUTPUT_FILE}"

plot '${RESULT_FILE}' with impulses title "games results", '${AVERAGE_FILE}' with impulses lc rgb "blue" lw 3 title "average"


quit
PLOT
						rm ${RESULT_FILE}
						rm ${AVERAGE_FILE}
				done
		done
done
