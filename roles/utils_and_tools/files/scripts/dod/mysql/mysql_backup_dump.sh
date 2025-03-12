#!/bin/bash

# Резервное копирование баз данных mysql с удалением старых копий.

TARGETDIR=/mnt/BACKUP/
DAYD=3

DATADIR=$TARGETDIR/`date +%Y-%m-%d`/DB
STATUS='/tmp/mysqlbackup_last_status'

EXCLUDED_DB=(
 information_schema
 performance_schema
)

let ResultCode=0

if [ ! -d "$DATADIR" ]; then
    mkdir -p $DATADIR
	let ResultCode=ResultCode+$?
fi

dblist=`mysql -e "show databases" | sed -n '2,$ p'`
for db in $dblist; do
	if [[ ! " ${EXCLUDED_DB[@]} " =~ " ${db} " ]]; then
	    mysqldump --routines --compact --no-create-db -v $db | gzip --best > $DATADIR/$db-`date +%F--%H-%M`.sql.gz
		let ResultCode=ResultCode+$?
 	fi
done

if [ "$ResultCode" -ne "0" ]; then
  echo "1" > $STATUS
  exit 1
else
  echo "0" > $STATUS
  find $TARGETDIR -name '*.gz' -type f -atime +$DAYD -delete
  find $TARGETDIR -type d -empty -exec rmdir {} \;
  exit 0;
fi;






