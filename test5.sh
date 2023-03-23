#!/usr/bin/env bash

lineformat="This is a very long line with a lot of stuff so they will take " 
lineformat+="more than standard terminal width (80) columns... Progress %3d%%" 

getWinSize() {
    {
        read twidth
        read theight
    } < <(
        tput -S - <<<$'cols\nlines'
    )
}
trap getWinSize WINCH
getWinSize

getCpos=$(tput u7)
getCurPos() {
    stty raw -echo min 0
    echo -en "$getCpos"
    read -sdR CURPOS
    stty $oldstty
    IFS=\; read curv curh <<<"${CURPOS#$'\e['}"
}
oldstty=$(stty -g)

before=$(tput -S - <<<$'ed\nsc')
after=$(tput rc)
n=0
while [[ $n -ne 100 ]]; do
    n=$((n+1))
    printf -v outputstring "$lineformat" $n
    getCurPos
    uplines=$(((${#outputstring}/twidth)+curv-theight))
    if ((uplines>0)) ;then
        printf -v movedown "%${uplines}s" ''
        echo -en "${movedown// /\\n}"
        tput cuu $uplines
    fi
    printf "%s%s%s" "$before" "$outputstring" "$after"
    sleep .05
done

downlines=$((${#outputstring}/twidth))
printf -v movedown "%${downlines}s" ''
echo "${movedown// /$'\n'}"
