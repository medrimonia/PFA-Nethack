#!/bin/sh
BASEDIR=$(pwd)
DIR="$( cd "$( dirname "$0" )" && pwd )"
echo "Switching to script directory"
cd $DIR
echo "Compiling..."
find -name "*.java" | xargs javac -cp ".:unix.jar" -d bin
echo "Extracting lib classes"
jar -xf unix.jar cx
echo "moving lib files"
mv cx bin/cx
cd bin
echo "Creating jar..."
find -name "*.class" | xargs jar -cfe ../Bot.jar LaunchBot
echo "Cleaning lib files"
rm -rf cx
cd ..
cd $BASEDIR
echo "Back to original directory"