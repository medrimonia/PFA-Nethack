#!/bin/bash
DATABASE="/tmp/test.db"
FILE="result_from_db"
if [ -f $FILE ]
then
		rm $FILE
fi

MAX=1800

for (( i=0 ; i < $MAX ; i++ ))
do

		REQUEST="'select count(*) from sdoor_discovery where sdd_turn <= $i'"
		printf "$i " >> $FILE
		NB=$(echo $REQUEST | xargs sqlite3 ${DATABASE})
		bc <<< "scale = 3; $NB / 100" >> $FILE
done