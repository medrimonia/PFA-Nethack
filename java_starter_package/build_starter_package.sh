#!/bin/sh
BASEDIR=$(pwd)
DIR="$( cd "$( dirname "$0" )" && pwd )"
echo "Switching to script directory"
cd $DIR
echo "Compiling..."
find -name "*.java" | xargs javac -d bin
cd bin
echo "Creating jar..."
find -name "*.class" | xargs jar -cfe ../Bot.jar LaunchBot
cd ..
cd $BASEDIR
echo "Back to original directory"