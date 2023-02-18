#!/bin/bash

FOLDERBACKUP=/home/vagrant/BACKUP/SQL
FOLDERBACKUP2=/home/vagrant/BACKUP/mariabackup
#FILE=SQL_2_Backup_$(date +"%d")
FILE=SQL_2_Backup_$(date "+%d-%m-%Y-%H-%M-%S")
FILE2=SQL_mariabackup_2_$(date "+%d-%m-%Y-%H-%M-%S")

rm -rf $FOLDERBACKUP/*
rm -rf $FOLDERBACKUP2/*

mysqldump --single-transaction bet_odds > $FOLDERBACKUP/$FILE.sql
mariabackup -u mariabackup --backup --target-dir=$FOLDERBACKUP2

tar -cvf $FOLDERBACKUP/$FILE.tar.gz -P $FOLDERBACKUP/$FILE.sql
tar -cvf $FOLDERBACKUP/$FILE2.tar.gz -P $FOLDERBACKUP2