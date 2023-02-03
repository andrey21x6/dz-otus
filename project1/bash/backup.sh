#!/bin/bash

FOLDERBACKUP=/home/vagrant/BACKUP
FILE=SQL_Backup_$(date +"%d")

rm -rf $FOLDERBACKUP/*
mysqldump -u root -p123456 project1 text_entries > $FOLDERBACKUP/$FILE.sql
tar -cvf $FOLDERBACKUP/ZIP_$FILE.tar.gz -P $FOLDERBACKUP/$FILE.sql

scp -P 22 -i ~/backup_private_key $FOLDERBACKUP/ZIP_$FILE.tar.gz vagrant@192.168.90.16:~/BACKUP/SQL/ZIP_$FILE.tar.gz
