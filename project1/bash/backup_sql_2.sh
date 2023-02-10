#!/bin/bash

FOLDERBACKUP=/home/vagrant/BACKUP
#FILE=SQL_2_Backup_$(date +"%d")
FILE=SQL_2_Backup_$(date +"%F_%T")

rm -rf $FOLDERBACKUP/*
mysqldump project1 text_entries > $FOLDERBACKUP/$FILE.sql
tar -cvf $FOLDERBACKUP/$FILE.tar.gz -P $FOLDERBACKUP/$FILE.sql

scp -o StrictHostKeyChecking=no -P 22 -i /home/vagrant/backup_private_key $FOLDERBACKUP/$FILE.tar.gz vagrant@192.168.90.14:~/BACKUP/SQL/$FILE.tar.gz
# -o StrictHostKeyChecking=no ---> не спрашивать о принятии сертификата сервера при первом подключении
