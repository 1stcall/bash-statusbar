#!/bin/bash

lineformat="This is a very long line with a lot of stuff so they will take " 
lineformat+="more than standard terminal width (80) columns... Progress %3d%%" 
LINES=$(tput lines)

n=0
while [[ $n -ne 100 ]]; do
    n=$((n+1))
    printf -v outputstring "$lineformat" $n
    twidth=$(tput cols)      # Get terminal width
    theight=$(tput lines)    # Get terminal height
    oldstty=$(stty -g)       # Save stty settings
    stty raw -echo min 0     # Suppres echo on terminal
    # echo -en "\E[6n"
    tput u7                  # Inquire for cursor position
    read -sdR CURPOS         # Read cursor position
    stty $oldstty            # Restore stty settings
    IFS=\; read cv ch <<<"${CURPOS#$'\e['}" # split $CURPOS
    uplines=$(((${#outputstring}/twidth)+cv-theight))
    ((uplines>0)) &&
        tput cuu $uplines    # cursor up one or more lines
    tput ed                  # clear to end of screen
    tput sc                  # save cursor position
    tput cup $LINES 0
    echo -n "$outputstring"
    tput rc                  # restore cursor
    sleep .0331s
done
echo
