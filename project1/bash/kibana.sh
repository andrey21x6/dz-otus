#!/bin/bash

#dnf install java-11-openjdk-devel
#java -version

echo ""
echo " *** Копируем новый файл repo ***"
echo ""
cp /home/vagrant/elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo

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
