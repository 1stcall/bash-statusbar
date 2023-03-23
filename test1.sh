#/usr/bin/env bash
#
LINES=$(tput lines)
COLS=$(tput cols)

set_window ()
{
    # Create a virtual window that is two lines smaller at the bottom.
    tput csr 0 $(($LINES-3))
}

print_status ()
{
#    tput sc
    
    # Move cursor to last line in your screen
    tput cup $LINES 0;

    echo -n "--- $1 ---"

    # Move cursor to home position, back in virtual window
    tput cup 0 0
#    tput rc
}

set_window
tput sc
print_status "Hello"
tput rc
#
