#!/bin/bash

#dnf install java-11-openjdk-devel
#java -version

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
echo " *** Смена владельца файла ***"
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
