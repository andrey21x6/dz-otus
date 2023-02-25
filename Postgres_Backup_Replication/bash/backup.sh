#!/bin/bash

nameDb=demodb
FOLDERBACKUP=/var/lib/pgsql/backups
FILE=backup_${nameDb}_$(date "+%d-%m-%Y-%H-%M-%S")

su - postgres -c "pg_dump ${nameDb} > backups/${FILE}.dump"

tar -cvf $FOLDERBACKUP/$FILE.tar.gz -P $FOLDERBACKUP/$FILE.dump

rm -f $FOLDERBACKUP/$FILE.dump

su - postgres -c "pg_basebackup -D archive_b/ -Ft -z"
