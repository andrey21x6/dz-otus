#!/bin/bash

#dnf install java-11-openjdk-devel
#java -version

echo ""
echo " *** Установка logstash ***"
echo ""
dnf install logstash -y

echo ""
echo " *** Копирование новых конфиг файлов для logstash ***"
echo ""
cp -R /home/vagrant/conf.d /etc/logstash

echo ""
echo " *** Смена владельца каталога и файлов /etc/logstash/conf.d ***"
echo ""
chown -R root:logstash /etc/logstash/conf.d

echo ""
echo " *** Переименовывание оригинального конфиг файла pipelines.yml ***"
echo ""
mv /etc/logstash/pipelines.yml /etc/logstash/pipelines.yml_bak

echo ""
echo " *** Копирование конфиг файла pipelines.yml ***"
echo ""
cp /home/vagrant/pipelines.yml /etc/logstash/pipelines.yml

echo ""
echo " *** Смена владельца файла pipelines.yml ***"
echo ""
chown root:logstash /etc/logstash/pipelines.yml

echo ""
echo " *** Включение автозапуска logstash ***"
echo ""
systemctl enable logstash.service

echo ""
echo " *** Старт logstash ***"
echo ""
systemctl start logstash.service
