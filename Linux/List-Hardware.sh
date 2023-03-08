#!/bin/bash

# List drives
echo "Listing drives"
lsblk -f

# Seperator
echo ""
echo "#######################################"
echo ""

# List USB Devices
echo "Listing USB devices"
lsusb -t