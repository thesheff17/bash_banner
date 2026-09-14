#!/bin/bash

# clear the screen
clear

# show quick banner
echo "This is a custom bash script header to help manage ubuntu linux systems."
echo "More information can be found here: https://github.com/thesheff17/bash_banner"
echo ""

# show ubuntu version
FILE="/usr/bin/lsb_release"
# -f checks if the file exists and is a regular file
if [ -f "$FILE" ]; then
    DESC=$(lsb_release -s -d)
    CODENAME=$(lsb_release -s -c)
    echo "Linux Distro: $DESC code name: $CODENAME"
fi

# show ipv4 address
IP=$(hostname -I | awk '{print $1}')
echo "ipv4 address: $IP"

# root partition stats
ROOTSTAT=$(df -BG / | awk 'NR==2 {print "Used: " $5 ", Free: " $4}')
echo "/ stats: $ROOTSTAT"

# load average
LOADSTATS=$(uptime | awk -F'load average:' '{print $2}' | xargs)
echo "CPU stats: $LOADSTATS"