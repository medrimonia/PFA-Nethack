#!/bin/bash


rm -f pfa.db

make test_db

for ((i = 1; i <= 10000 ; i++))
do
		./test_db
done

# Generating data

FIELDS={"nb_sdoors",

sqlite3 pfa.db 'select nb_sdoors_found, count(*) from seek_secret group by nb_sdoors_found' >nb_sdoors_found_result.txt