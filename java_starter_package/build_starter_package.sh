#!/bin/sh
find -name "*.java" | xargs javac -d bin
cd bin
find -name "*.class" | xargs jar -cfe ../Bot.jar LaunchBot
cd ..