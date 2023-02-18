#!/bin/bash

FOLDERBACKUP=/home/vagrant/BACKUP/SQL
FOLDERBACKUP2=/home/vagrant/BACKUP/mariabackup
#FILE=SQL_1_Backup_$(date +"%d")
FILE=SQL_1_Backup_$(date "+%d-%m-%Y-%H-%M-%S")
FILE2=SQL_mariabackup_1_$(date "+%d-%m-%Y-%H-%M-%S")

rm -rf $FOLDERBACKUP/*
rm -rf $FOLDERBACKUP2/*

mysqldump --single-transaction project1 text_entries > $FOLDERBACKUP/$FILE.sql
mariabackup -u mariabackup --backup --target-dir=$FOLDERBACKUP2

tar -cvf $FOLDERBACKUP/$FILE.tar.gz -P $FOLDERBACKUP/$FILE.sql
tar -cvf $FOLDERBACKUP/$FILE2.tar.gz -P $FOLDERBACKUP2
