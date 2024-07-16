#!/bin/bash

SWAPFILE=/swapfile
SWAPSIZE=$1

calculat() { awk "BEGIN{ print $* }" ;}

SWAPSIZEBYTE=$(calculat $SWAPSIZE*1048576)
dd if=/dev/zero of=$SWAPFILE bs=1024 count=$SWAPSIZEBYTE
chmod 600 $SWAPFILE
mkswap $SWAPFILE
swapon $SWAPFILE
swapon --show

# Проверяем, есть ли запись о swapfile в /etc/fstab

# If required add line in /etc/fstab:
# /swapfile swap swap defaults 0 0

grep -q "$SWAPFILE" /etc/fstab
if [ $? -ne 0 ]; then
    # Добавляем запись в /etc/fstab
    echo "$SWAPFILE none swap sw 0 0" | tee -a /etc/fstab
fi
