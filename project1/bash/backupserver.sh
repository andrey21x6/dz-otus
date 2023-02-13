#!/bin/bash

echo ""
echo " *** Создаём каталоги ***"
echo ""
mkdir -p /home/vagrant/BACKUP/SQL /home/vagrant/BACKUP/LOG /home/vagrant/BACKUP/mariabackup

echo ""
echo " *** Изменяем владельца каталогов ***"
echo ""
chown -R vagrant:vagrant /home/vagrant/BACKUP

echo ""
echo " *** Копируем новый файл repo ***"
echo ""
cp /home/vagrant/elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo

echo ""
echo " *** Устанавливаем filebeat ***"
echo ""
dnf install filebeat -y

echo ""
echo " *** Переименовываем оригинальный конфиг filebeat.yml ***"
echo ""
mv /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml_bak

echo ""
echo " *** Копируем новый конфиг filebeat ***"
echo ""
cp /home/vagrant/filebeat.yml /etc/filebeat/filebeat.yml

echo ""
echo " *** Запускаем filebeat и добавляем в автозагрузку ***"
echo ""
systemctl enable --now filebeat
