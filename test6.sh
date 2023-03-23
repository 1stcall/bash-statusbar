#!/usr/bin/env bash

COLUMNS=`tput cols`
LINES=`tput lines`
line=`expr $LINES`
column=`expr \( $COLUMNS - 6 \) / 2`
tput sc
tput csr 1 $((LINES-1))
tput cup $line $column
tput rev
echo -n 'Hello, World'
tput sgr0
tput rc
printf "                                                                                                             \r"
