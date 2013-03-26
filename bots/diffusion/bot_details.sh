#!/bin/sh

SCRIPTPATH=$( dirname $( readlink -f $0 ) )

echo "* Constants :"
# Different constants are separated by ';' instead of '\n'
CONSTANTS=`grep "final static [a-Z]* [A-Z_]* = " $SCRIPTPATH/src/util/Scoring.java | grep -o "[A-Z_]* = [0-9.]*" | tr "\n" ";"`
#IFS is temporary switched
IFS=';'
for str in $CONSTANTS
do
		echo "    * $str"
done
