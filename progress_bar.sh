#!/usr/bin/env bash
#
set -o errexit
set -o errtrace
set -o functrace
set -o nounset
set -o pipefail
set -o noclobber
#
# Function for basic logging to stderr
#
log(){
  printf  "${LBLUE}%s:${RESTORE} %s\n" "$SCRIPTNAME" "${*}" 1>&2
}
#
# Function to format seconds in days, hours, mins & seconds
#
function displaytime {
  local T="${1}"
  local D=$((T/60/60/24))                                   # calculate days from seconds
  local H=$((T/60/60%24))                                   # calculate hours from seconds
  local M=$((T/60%60))                                      # calculate minutes from seconds
  local S=$((T%60))                                         # calculate remaining from seconds
  (( D > 0 )) && printf '%d days ' $D                      # output days if needed
  (( H > 0 )) && printf '%d hours ' $H                     # output hours if needed
  (( M > 0 )) && printf '%d minutes ' $M                   # output minuets if needed
  (( D > 0 || H > 0 || M > 0 )) && printf 'and '         # output "and" if days, hours or minutes are used
  printf '%d seconds\n' $S                                  # output seconds
  return 0
}
#
# Function to initialise the progress bar
#
function initialise_progress {
    #
    # go to last line and print the empty progress bar
    #
    tput sc                                                     # save the current cursor position
    tput cup $(($(tput lines)-1)) 2                              # go to last line
    echo -n "["                                                 # print the start of the progress bar line
    tput cup $(($(tput lines)-1)) $(($(tput cols)-7))             # move to the end of the progress bar line
    echo -n "]"                                                 # print the end of the progress bar line
    tput rc                                                     # bring the cursor back to the last saved position
    tput civis                                                  # hide the cursor
    init_progress=1                                             # progress bar has been initialised
    return 0
}
#
# Function to clear the progress bar line
#
# shellcheck disable=SC2317  # Don't warn about unreachable commands in this function
function clear_progress {
    tput sc                                                     # save the current cursor position
    tput cup $(($(tput lines)-1)) 0                              # go to the line with the progress bar
    tput el                                                     # clear the current line
    tput rc                                                     # go back to the saved cursor position
    tput cnorm                                                  # restore the cursor
    init_progress=0                                             # progress bar is uninitialised
    return 0
}
#
# Function to display the current progress.  TODO break up function
#
function display_progress {
    local counter                                               # counter used in loops
    #
    [[ init_progress -ne 1 ]] && initialise_progress            # initialise the progress bar if needed
    #
    # print the filled progress bar
    #
    tput sc                                                     # save the current cursor position
    doned=${1}                                                  # amount done
    total=${2}                                                  # total amount to do
                                                                # calculate & format percentage done
    percent=$(awk -v doned="$doned" -v total="$total" 'BEGIN { printf "%.0f%%", (doned/total*100) }')
    doned=$(echo "$doned" "$total" | awk '{print ($1/$2)}')          # calculate amount done
    total=$(tput cols | awk '{print $1-10}')                     # calculate how many # = 100%
    doned=$(echo "$doned" "$total" | awk '{print int(($1*$2))}')     # calculate how many # = % done

    tput cup $(($(tput lines)-1)) $(($(tput cols)-5))             # move to position at the end of the progress bar
    echo -n "$percent"                                            # print the % done
    tput cup $(($(tput lines)-1)) 3                              # go to the start of the progress bar
    for counter in $(seq 1 "$doned"); do                          # this loop prints the required no. of "#"s to fill the bar
        echo -n "#"
    done
    tput rc                                                     # bring the cursor back to the last saved position
    #
    # the following lines are to find the row on which the cursor is currently on to check if it is at the last line 
    #
    exec < /dev/tty
    oldstty=$(stty -g)
    stty raw -echo min 0
    tput u7 > /dev/tty
    IFS=';' read -r -d R -a pos
    stty "$oldstty"
    row=$((${pos[0]:2} - 1))
    #
    # check if the cursor is on the line before the last line, if yes, clear the progress bar, scroll the screen by 1 line,
    # then redraw the bar
    #
    if [ $row -gt $(($(tput lines)-2)) ]; then
        printf "%s\n%s" "$(tput el)" "$(tput cup $(($(tput lines)-2)) 0)"
        tput sc
        tput cup $(($(tput lines)-1)) 2
        echo -n "["
        tput cup $(($(tput lines)-1)) $(($(tput cols)-7))         # move to the end of the progress bar line
        echo -n "] $percent"                                    # print the end of the progress bar line and % done
        tput cup $(($(tput lines)-1)) 3
        for counter in $(seq 1 "$doned"); do
            echo -n "#"
        done
        tput rc
    fi

}
#
# test code. ########################################################################################################
# initialise constants and variables
#
SECONDS=0                                                       # initialise the timer
VERSION="1.1.0-dev"                                             # initialise the script version
init_progress=0                                                 # progress bar has not been initialised
LBLUE=$(echo -en '\033[01;34m')                                 # font colour light blue
RESTORE=$(echo -en '\033[0m')                                   # restore font color
#SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )" # initialise the script path
SCRIPTFILE=$(basename -- "${0}")                                # initialise the script filename
SCRIPTNAME=${SCRIPTFILE%.*}                                     # initialise the script name
#
log "Running: $SCRIPTNAME version: $VERSION"
#
trap clear_progress EXIT                                        # clear the progress bar on exit
#
# the actual loop which does the script's main job
#
for counter in {1..500}; do
    # this is just to show that the cursor is behaving correctly
    printf "x%dx\n" "$counter"
    display_progress "$counter" 500
done
#
log "$SCRIPTNAME $VERSION completed in $(displaytime $SECONDS)"
exit 0