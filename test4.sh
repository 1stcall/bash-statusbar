#/usr/bin/env bash
#
twidth=$(tput cols)      # Get terminal width
theight=$(tput lines)    # Get terminal height
oldstty=$(stty -g)       # Save stty settings
stty raw -echo min 0     # Suppres echo on terminal
tput u7                  # Inquire for cursor position
read -sdR CURPOS         # Read cursor position
stty $oldstty            # Restore stty settings
IFS=\; read cv ch <<<"${CURPOS#$'\e['}" # split $CURPOS
#printf "cv:%s ch:%s" $cv $ch
tput cup $theight 0;
echo -n "--- Test Message ---"
tput cup $((cv-1)) $((ch-1))
