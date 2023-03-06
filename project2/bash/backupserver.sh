#!/bin/bash

echo ""
echo " *** Создаются каталоги SQL и mariabackup ***"
echo ""
mkdir -p /home/vagrant/BACKUP/SQL /home/vagrant/BACKUP/mariabackup

echo ""
echo " *** Смена владельца каталогов SQL и mariabackup ***"
echo ""
chown -R vagrant:vagrant /home/vagrant/BACKUP
