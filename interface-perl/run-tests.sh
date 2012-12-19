#!/bin/sh

find t/ -type f -name *.t -print -exec perl {} \;
