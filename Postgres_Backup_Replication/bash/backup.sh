#!/bin/bash

nameDb=demodb
FOLDERBACKUP=/var/lib/pgsql/backups
FILE=backup_${nameDb}_$(date "+%d-%m-%Y-%H-%M-%S")
FOLDERBACKUP_PG=/var/lib/pgsql/backups/${nameDb}_$(date "+%d-%m-%Y-%H-%M-%S")

su - postgres -c "pg_dump ${nameDb} > backups/${FILE}.dump"

tar -cvf $FOLDERBACKUP/$FILE.tar.gz -P $FOLDERBACKUP/$FILE.dump

rm -f $FOLDERBACKUP/$FILE.dump

mkdir $FOLDERBACKUP_PG
chown -R postgres:postgres $FOLDERBACKUP_PG
su - postgres -c "pg_basebackup -D ${FOLDERBACKUP_PG}/ -Ft -z"
