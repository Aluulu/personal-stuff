#!/bin/bash

# Check if user is running as root
# If not, prompt then run the script as root
if [[ $EUID -ne 0 ]]; then
   sudo "$0" "$@"
   exit $?
fi

# This function checks if a string exists in a file
#   Arguments:
#       $1 - The file to check
#       $2 - The string to check in the file
#       $3 - If the string should be added to the top of the file
#   Returns:
#       No return value
function checkFileForString() {

    # Check if the string exists in the file
    if grep -q "$2" "$1"; then

        # Prints the string if it exists in the file
        echo "$2 already exists in the file"

    # If the string does not exist in the file
    else

        # If setNameServerToTop is true, add the nameserver to the top of the file
        if [ $3 == "true" ];
        then

            # Add the nameserver to the top of the file
            # https://superuser.com/questions/246837/how-do-i-add-text-to-the-beginning-of-a-file-in-bash
            echo "$2" | cat - $1 > temp && mv temp $1
            echo "$2 added to the file"

        # If setNameServerToTop is false, add the nameserver to the bottom of the file
        else

            echo "$2" >> "$1"
            echo "$2 added to the file"

        fi
    fi
}

# Set the variable to true by default
# This is used to determine if the script should set the nameserver to the top of the file
setNameServerToTop="true"

# If the script is called with the argument "true", set the variable to true
if [ $1 == "true" ];
then
    setNameServerToTop="true"
fi

# If the script is called with the argument "false", set the variable to false
if [ $1 == "false" ];
then
    setNameServerToTop="false"
fi

# Runs the function to check if the nameserver is in the file
checkFileForString "/etc/resolv.conf" "nameserver 8.8.8.8" "$setNameServerToTop"
checkFileForString "/etc/resolv.conf" "nameserver 1.1.1.1" "$setNameServerToTop"