#!/bin/bash

echo ""
echo " *** Устанавка kibana ***"
echo ""
dnf install kibana -y

echo ""
echo " *** Переименование оригинального конфиг файла kibana.yml ***"
echo ""
mv /etc/kibana/kibana.yml /etc/kibana/kibana.yml_bak

echo ""
echo " *** Копирование нового конфиг файла kibana.yml ***"
echo ""
cp /home/vagrant/kibana.yml /etc/kibana/kibana.yml

echo ""
echo " *** Смена владельца файла kibana.yml ***"
echo ""
chown root:kibana /etc/kibana/kibana.yml

echo ""
echo " *** Включение автозапуска kibana ***"
echo ""
systemctl enable kibana.service

echo ""
echo " *** Старт kibana ***"
echo ""
systemctl start kibana.service

echo ""
echo " *** Установка и настройка heartbeat ***"
echo ""
curl -L -O https://artifacts.elastic.co/downloads/beats/heartbeat/heartbeat-8.6.2-x86_64.rpm
rpm -vi heartbeat-8.6.2-x86_64.rpm
mv /etc/heartbeat/heartbeat.yml /etc/heartbeat/heartbeat.yml_bak
cp /home/vagrant/heartbeat.yml /etc/heartbeat/heartbeat.yml
heartbeat setup
service heartbeat-elastic start
