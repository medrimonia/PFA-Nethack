#!/bin/bash

pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd -P`
popd > /dev/null

echo "* Constants :"
# Different constants are separated by ';' instead of '\n'
CONSTANTS=`grep "final static [a-Z]* [A-Z_]* = " $SCRIPTPATH/src/util/Scoring.java | grep -o "[A-Z_]* = [0-9.]*" | tr "\n" ";"`
#IFS is temporary switched
OIFS=$IFS
IFS=';'
CONSTANTS_COPY=$CONSTANTS
for str in $CONSTANTS_COPY
do
		echo "    * $str"
done
IFS=$OIFS
#IFS get back to normal
