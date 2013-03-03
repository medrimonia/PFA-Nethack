#!/bin/sh

##From David: I don't think there is a need to save the IFS as long as you
##don't do any export. I don't understand the point of using CONSTANTS_COPY
##either.
##Besides, using pushd, popd and pwd can be replace by a readlink. It may be
##better because now the script can be run with sh instead of bash.
##If you agreed with me, every line of this file starting with '##' can be
##removed.

##pushd `dirname $0` > /dev/null
##SCRIPTPATH=`pwd -P`
##popd > /dev/null

SCRIPTPATH=$( dirname $( readlink -f $0 ) )

echo "* Constants :"
# Different constants are separated by ';' instead of '\n'
CONSTANTS=`grep "final static [a-Z]* [A-Z_]* = " $SCRIPTPATH/src/util/Scoring.java | grep -o "[A-Z_]* = [0-9.]*" | tr "\n" ";"`
#IFS is temporary switched
##OIFS=$IFS
IFS=';'
##CONSTANTS_COPY=$CONSTANTS
##for str in $CONSTANTS_COPY
for str in $CONSTANTS
do
		echo "    * $str"
done
##IFS=$OIFS
##IFS get back to normal
