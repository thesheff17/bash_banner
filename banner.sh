#!/bin/bash

# clear the screen
clear

# if short is passed to the script it will skip
# this banner and the network stats below.

if [[ -z $1 ]]; then
    if [ "$1" == "short" ]; then
        SKIPOUTPUT="yes"
    else
        SKIPOUTPUT="no"
    fi
fi

# show quick banner 
if [[ $SKIPOUTPUT == "no" ]]; then
    echo "This is a custom bash script header to help manage debian/ubuntu systems."
    echo "More information can be found here: https://github.com/thesheff17/bash_banner"
    echo ""
fi

# suppress debian/ubuntu headers
FILE1="$HOME/.hushlogin"
if [ ! -f "$FILE1" ]; then
    touch $FILE1
fi

# show version
FILE2="/usr/bin/lsb_release"
if [ -f "$FILE2" ]; then
    DESC=$(lsb_release -s -d)
    CODENAME=$(lsb_release -s -c)
    echo "Linux Distro: $DESC code name: $CODENAME"
fi

# total cores
TOTAL_CORES=$(lscpu | grep "^CPU(s):" | awk '{print $2}')

echo "CPU Cores: $TOTAL_CORES"

# load average
LOADSTATS=$(uptime | awk -F'load average:' '{print $2}' | xargs)
echo "CPU stats: $LOADSTATS"

# root partition stats
ROOTSTAT=$(df -BG / | awk 'NR==2 {print "Used: " $5 ", Free: " $4}')
echo "/ stats: $ROOTSTAT"

# show ipv4 address
IP=$(hostname -I | awk '{print $1}')
echo "ipv4 address: $IP"

# iostat info
FILE3=/usr/bin/iostat
if [ -f "$FILE3" ]; then
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

if [[ $SKIPOUTPUT == "no" ]]; then
    if systemctl is-active --quiet "$SERVICE"; then
        echo "Network stats:"
        vnstat -h
        vnstat
    fi
fi
