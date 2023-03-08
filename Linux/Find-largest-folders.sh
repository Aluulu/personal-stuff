#!/bin/bash

# Check if an argument is supplied
if [[ $1 == "" ]];

then

    # If no argument is supplied, display the largest folders in the current directory
    set -- "$PWD" "$2"

fi


# Checks if an argument is supplied for the number of folders to display
if [[ $2 == "" ]];

# If there is no argument, display 20 folders by default
then

    echo "No argument supplied for number of folders to display, displaying 20 folders by default"
    set -- "$1" "20"
    # https://www.shellcheck.net/wiki/SC2270

fi


# This script uses du to find the largest folders in a directory.
# The du command's arguments are as follows:

    # du : Estimate file space usage.
    # a : Displays all files and folders.
    # sort command : Sort lines of text files.
    # -n : Compare according to string numerical value.
    # -r : Reverse the result of comparisons.
    # head : Output the first part of files.
    # -n : Print the first ‘n’ lines. (In our case, We displayed the first 20 lines).
    # Found here: https://www.tecmint.com/find-top-large-directories-and-files-sizes-in-linux/

du -a "$1" | sort -n -r | head -n "$2"
