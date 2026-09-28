#!/bin/bash

SEARCH_STR="banner.sh"
ADD_STR="source ~/git/bash_banner/banner.sh"
FILE="$HOME/.bashrc"

if ! grep -Fq "$SEARCH_STR" "$FILE"; then
    echo "$ADD_STR" >> "$FILE"
    echo "Added '$ADD_STR' to $FILE"
else
    echo "Search pattern '$SEARCH_STR' already found in $FILE. No changes made."
fi
