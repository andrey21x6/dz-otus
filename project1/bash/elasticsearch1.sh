#!/bin/bash

#dnf install java-11-openjdk-devel
#java -version

echo ""
echo " *** Копируем новый файл repo ***"
echo ""
cp /home/vagrant/elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo

echo ""
echo " *** Устанавка elasticsearch ***"
echo ""
dnf install --enablerepo=elasticsearch elasticsearch -y

echo ""
echo " *** Переименование оригинального конфиг файла elasticsearch.yml ***"
echo ""
mv /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml_bak

echo ""
echo " *** Копирование нового конфиг файла elasticsearch.yml ***"
echo ""
cp /home/vagrant/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml

echo ""
echo " *** Смена владельца файла ***"
echo ""
chown root:elasticsearch /etc/elasticsearch/elasticsearch.yml

echo ""
echo " *** Увеличение Timeout старта сервиса elasticsearch (иногда не успевает запуститься) ***"
echo ""
sed -i -e "s/TimeoutStartSec=75/TimeoutStartSec=300/g" /usr/lib/systemd/system/elasticsearch.service

echo ""
echo " *** Перегрузка демона systemd ***"
echo ""
systemctl daemon-reload

echo ""
echo " *** Включение автозапуска elasticsearch ***"
echo ""
systemctl enable elasticsearch

echo ""
echo " *** Старт elasticsearch ***"
echo ""
systemctl start elasticsearch

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
