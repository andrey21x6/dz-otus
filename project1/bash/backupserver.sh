#!/bin/bash

echo ""
echo " *** Создаём каталоги ***"
echo ""
mkdir -p /home/vagrant/BACKUP/SQL /home/vagrant/BACKUP/LOG

echo ""
echo " *** Изменяем владельца каталогов ***"
echo ""
chown -R vagrant:vagrant /home/vagrant/BACKUP
