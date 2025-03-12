#!/bin/bash

# Резервное копирование файлов с удалением старых копий.

TARGETDIR=/mnt/BACKUP/
DAYD=3

DATADIR=$TARGETDIR/`date +%Y-%m-%d`/www
STATUS='/tmp/filesbackup_last_status'

let ResultCode=0

if [ ! -d "$DATADIR" ]; then
    mkdir -p $DATADIR
	let ResultCode=ResultCode+$?
fi

tar -czpvf $DATADIR/backup-`date +%F--%H-%M`.tgz /var/www/
let ResultCode=ResultCode+$?

if [ "$ResultCode" -ne "0" ]; then
  echo "1" > $STATUS
  exit 1
else
  echo "0" > $STATUS
  find $TARGETDIR -name '*.gz' -type f -atime +$DAYD -delete
  find $TARGETDIR -type d -empty -exec rmdir {} \;
  exit 0;
fi;