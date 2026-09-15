#!/bin/bash

# clear the screen
clear

# show quick banner
echo "This is a custom bash script header to help manage ubuntu linux systems."
echo "More information can be found here: https://github.com/thesheff17/bash_banner"
echo ""

# show ubuntu version
FILE1="/usr/bin/lsb_release"
# -f checks if the file exists and is a regular file
if [ -f "$FILE1" ]; then
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

# iostat info
FILE2=/usr/bin/iostat
if [ -f "$FILE2" ]; then
    IOSTAT_OUTPUT=$(iostat)

    IOSTAT_INFO1=$(printf "%s\n" "$IOSTAT_OUTPUT" | grep -A 1 "^avg-cpu:")

    DEVICE_HEADER=$(printf "%s\n" "$IOSTAT_OUTPUT" | grep "^Device")
    NVME_LINE=$(printf "%s\n" "$IOSTAT_OUTPUT" | grep "^nvme0n1")
    DEVICE_INFO="${DEVICE_HEADER}"$'\n'"${NVME_LINE}"

    echo "io stats:"
    echo "$IOSTAT_INFO1"
    echo "$DEVICE_INFO"
fi

# vnstat info
SERVICE="vnstat"
if [[ -z $1 ]]; then
    if [ "$1" == "short" ]; then
        SKIPNETWORK="yes"
    else
        SKIPNETWORK="no"
    fi
fi

if [[ $SKIPNETWORK == "no" ]]; then
    if systemctl is-active --quiet "$SERVICE"; then
        echo "Network stats:"
        vnstat -h
        vnstat
    fi
fi