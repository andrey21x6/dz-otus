#!/bin/bash

FOLDERBACKUP=/home/vagrant/BACKUP
#FILE=SQL_Backup_$(date +"%d")
FILE=SQL_Backup_$(date +"%F_%T")

rm -rf $FOLDERBACKUP/*
mysqldump -u root -p123456 project1 text_entries > $FOLDERBACKUP/$FILE.sql
tar -cvf $FOLDERBACKUP/ZIP_$FILE.tar.gz -P $FOLDERBACKUP/$FILE.sql

scp -P 22 -i /home/vagrant/backup_private_key $FOLDERBACKUP/ZIP_$FILE.tar.gz vagrant@192.168.90.14:~/BACKUP/SQL/ZIP_$FILE.tar.gz
