#!/bin/bash

# Add swapfile size 1Gb.

dd if=/dev/zero of=/swapfile bs=1024 count=1048576
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
swapon --show

# If required add line in /etc/fstab:
# /swapfile swap swap defaults 0 0

# info:
# swapon --show

