#!/usr/bin/env bash

trap clear_progress EXIT
init_progress=0 # progress bar has not been initialised

function initialise_progress()
{
    local counter

    # go to last line and print the empty progress bar
    tput sc                                                     #save the current cursor position
    tput cup $((`tput lines`-1)) 2                              # go to last line
    echo -n "["                                                 # print the start of the progress bar line
    tput cup $((`tput lines`-1)) $((`tput cols`-7))             # move to the end of the progress bar line
    echo -n "]"                                                 # print the end of the progress bar line
    tput rc                                                     # bring the cursor back to the last saved position
    tput civis                                                  # hide the cursor
    init_progress=1                                               # progress bar has been initialised
}

function clear_progress()
{
    # the next few lines remove the progress bar after the program is over   
    tput sc                                                     # save the current cursor position
    tput cup $((`tput lines`-1)) 0                              # go to the line with the progress bar
    tput el                                                     # clear the current line
    tput rc                                                     # go back to the saved cursor position
    tput cnorm                                                  # restore the cursor
    init_progress=0                                               # progress bar is uninitialised
}

function display_progress()
{
    local counter
    local j
    [[ init_progress -ne 1 ]] && initialise_progress
    # print the filled progress bar
    tput sc  #save the current cursor position
    doned=${1}  #example value for completed amount
    total=${2}   #example value for total amount
    percent=$(awk -v doned=$doned -v total=$total 'BEGIN { printf "%.0f%%", (doned/total*100) }')
    doned=`echo $doned $total | awk '{print ($1/$2)}'` # the next three lines calculate how many characters to print for the completed amount
    total=`tput cols | awk '{print $1-10}'`
    doned=`echo $doned $total | awk '{print int(($1*$2))}'`

    tput cup $((`tput lines`-1)) $((`tput cols`-5)) && echo -n $percent
    tput cup $((`tput lines`-1)) 3 #go to the last line
    for counter in $(seq 1 $doned); do #this loop prints the required no. of "#"s to fill the bar
        echo -n "#"
    done
    tput rc #bring the cursor back to the last saved position

    # the next 7 lines are to find the row on which the cursor is currently on to check if it 
    # is at the last line 
    # (based on the accepted answer of this question: https://stackoverflow.com/questions/2575037/)
    exec < /dev/tty
    oldstty=$(stty -g)
    stty raw -echo min 0
    tput u7 > /dev/tty
    IFS=';' read -r -d R -a pos
    stty $oldstty
    row=$((${pos[0]:2} - 1))

    # check if the cursor is on the line before the last line, if yes, clear the terminal, 
    # and make the empty bar again and fill it with the required amount of "="s
    if [ $row -gt $((`tput lines`-2)) ]; then
        printf "%s\n%s" $(tput el) $(tput cup $((`tput lines`-2)) 0)
        tput sc
        tput cup $((`tput lines`-1)) 2
        echo -n "["
        tput cup $((`tput lines`-1)) $((`tput cols`-7))         # move to the end of the progress bar line
        echo -n "] $percent"                                    # print the end of the progress bar line
        tput cup $((`tput lines`-1)) 3
        for counter in $(seq 1 $doned); do
            echo -n "#"
        done
        tput rc
    fi

}
# the actual loop which does the script's main job
for counter in {1..50}; do
    # this is just to show that the cursor is behaving correctly
    sleep .1
    printf "x%dx\n" $counter
    display_progress $counter 50
done
