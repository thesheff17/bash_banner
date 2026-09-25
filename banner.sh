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

# kernel version
KERNEL_VERSION=$(uname -r)
echo "Kernel version: $KERNEL_VERSION"

# total cores
TOTAL_CORES=$(lscpu | grep "^CPU(s):" | awk '{print $2}')
echo "CPU cores: $TOTAL_CORES"

# load average
LOADSTATS=$(uptime | awk -F'load average:' '{print $2}' | xargs)
echo "CPU stats: $LOADSTATS"

# Read Memory and Swap values from /proc/meminfo in KiB
mem_total=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
mem_available=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)
swap_total=$(awk '/^SwapTotal:/ {print $2}' /proc/meminfo)
swap_free=$(awk '/^SwapFree:/ {print $2}' /proc/meminfo)

# Validate RAM readings
if [[ -z "$mem_total" || -z "$mem_available" || "$mem_total" -eq 0 ]]; then
    echo "Error: Unable to read RAM information from /proc/meminfo." >&2
    exit 1
fi

# Calculate RAM usage
mem_used=$((mem_total - mem_available))
mem_usage_percent=$(awk -v used="$mem_used" -v total="$mem_total" 'BEGIN { printf "%.2f", (used / total) * 100 }')

# Convert RAM KiB to GiB for display
mem_total_gb=$(awk -v val="$mem_total" 'BEGIN { printf "%.2f", val / 1024 / 1024 }')
mem_used_gb=$(awk -v val="$mem_used" 'BEGIN { printf "%.2f", val / 1024 / 1024 }')
mem_available_gb=$(awk -v val="$mem_available" 'BEGIN { printf "%.2f", val / 1024 / 1024 }')

# Output RAM status
echo "Memory Usage: ${mem_usage_percent}%"
echo "Details: ${mem_used_gb} GiB used / ${mem_available_gb} GiB available (${mem_total_gb} GiB total)"

echo "--------------------------------------------------"

# Handle Swap calculation
if [[ -z "$swap_total" || "$swap_total" -eq 0 ]]; then
    echo "Swap Usage:   0.00% (No swap configured)"
else
    swap_used=$((swap_total - swap_free))
    swap_usage_percent=$(awk -v used="$swap_used" -v total="$swap_total" 'BEGIN { printf "%.2f", (used / total) * 100 }')

    swap_total_gb=$(awk -v val="$swap_total" 'BEGIN { printf "%.2f", val / 1024 / 1024 }')
    swap_used_gb=$(awk -v val="$swap_used" 'BEGIN { printf "%.2f", val / 1024 / 1024 }')
    swap_free_gb=$(awk -v val="$swap_free" 'BEGIN { printf "%.2f", val / 1024 / 1024 }')

    echo "Swap Usage:   ${swap_usage_percent}%"
    echo "Details: ${swap_used_gb} GiB used / ${swap_free_gb} GiB free (${swap_total_gb} GiB total)"
fi

# root partition stats
ROOTSTAT=$(df -BG / | awk 'NR==2 {print "Used: " $5 ", Free: " $4}')
echo "/ stats: $ROOTSTAT"

# show ipv4 address
IP=$(hostname -I | awk '{print $1}')
echo "ipv4 address: $IP"

# python version
FILE3=/usr/bin/python3
if [ -f "$FILE3" ]; then
    PYTHON_VERSION1=$(/usr/bin/python3 -V)
    PYTHON_VERSION2="${PYTHON_VERSION1//Python/}"
    echo "Python version:$PYTHON_VERSION2"
fi

# gcc version
FILE4=/usr/bin/gcc
if [ -f "$FILE4" ]; then
    GCC_VERSION1=$(gcc --version | head -n 1)
    GCC_VERSION2="${GCC_VERSION1//gcc/}"
    echo "gcc version:$GCC_VERSION2"
fi

# iostat info
FILE5=/usr/bin/iostat
if [ -f "$FILE5" ]; then
    IOSTAT_OUTPUT=$(iostat)

    IOSTAT_INFO1=$(printf "%s\n" "$IOSTAT_OUTPUT" | grep -A 1 "^avg-cpu:")

    DEVICE_HEADER=$(printf "%s\n" "$IOSTAT_OUTPUT" | grep "^Device")
    NVME_LINE=$(printf "%s\n" "$IOSTAT_OUTPUT" | grep "^nvme0n1")
    DEVICE_INFO="${DEVICE_HEADER}"$'\n'"${NVME_LINE}"

    echo "IO stats:"
    echo "$IOSTAT_INFO1"
    echo "$DEVICE_INFO"
fi

# check to see if any packages are missing
PACKAGES=(
  build-essential
  curl
  git
  htop
  python3-venv
  sysstat
  ssh
  tmux
  vim
  wget
)

MISSING=()

# Check each package using dpkg-query
for pkg in "${PACKAGES[@]}"; do
  if ! dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "ok installed"; then
    MISSING+=("$pkg")
  fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
  echo "The following required packages are missing:"
  echo "  ${MISSING[*]}"
  echo ""
  echo "Run the following command to install them:"
  echo "sudo apt-get update && sudo apt-get install -y ${MISSING[*]}"
  echo ""
fi

# quick to check to see if packages are out of date
FILE6="/var/lib/update-notifier/updates-available"
if [ -f "$FILE6" ]; then
    UPDATES_COUNT=$(grep -i "updates can be applied immediately" "$FILE6" | awk '{print $1}')

    # Fallback: if grep/awk fails to parse a number, set to 0
    UPDATES_COUNT=${UPDATES_COUNT:-0}

    # 3. Check if updates are greater than 0
    if [ "$UPDATES_COUNT" -gt 0 ]; then
        echo "There are $UPDATES_COUNT packages available to install."
        echo "You should run: sudo apt-get update && sudo apt-get dist-upgrade -y"
        echo "Reboot if you have a kernel upgrade."
        echo ""
    fi
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
