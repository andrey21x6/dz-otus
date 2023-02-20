#!/bin/bash

FOLDERBACKUP=/home/vagrant/BACKUP/SQL
FOLDERBACKUP2=/home/vagrant/BACKUP/mariabackup
#FILE=SQL_${HOSTNAME}_Backup_$(date +"%d")
FILE=SQL_${HOSTNAME}_Backup_$(date "+%d-%m-%Y-%H-%M-%S")
FILE2=SQL_mariabackup_${HOSTNAME}_$(date "+%d-%m-%Y-%H-%M-%S")

rm -rf $FOLDERBACKUP/*
rm -rf $FOLDERBACKUP2/*

mysqldump --single-transaction project1 text_entries > $FOLDERBACKUP/$FILE.sql
mariabackup -u mariabackup --backup --target-dir=$FOLDERBACKUP2

tar -cvf $FOLDERBACKUP/$FILE.tar.gz -P $FOLDERBACKUP/$FILE.sql
tar -cvf $FOLDERBACKUP/$FILE2.tar.gz -P $FOLDERBACKUP2

sshpass -p 1 scp -o StrictHostKeyChecking=no -P 22 $FOLDERBACKUP/$FILE.tar.gz root@192.168.90.14:$FOLDERBACKUP/$FILE.tar.gz
sshpass -p 1 scp -o StrictHostKeyChecking=no -P 22 $FOLDERBACKUP/$FILE2.tar.gz root@192.168.90.14:$FOLDERBACKUP2/$FILE2.tar.gz
# -o StrictHostKeyChecking=no ---> не спрашивать о принятии сертификата сервера при первом подключении
