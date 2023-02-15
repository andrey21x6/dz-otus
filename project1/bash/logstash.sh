#!/bin/bash

#dnf install java-11-openjdk-devel
#java -version

echo ""
echo " *** Копируем новый файл repo ***"
echo ""
cp /home/vagrant/elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo

echo ""
echo " *** Установка logstash ***"
echo ""
dnf install logstash -y

echo ""
echo " *** Копирование новых конфиг файлов для logstash ***"
echo ""
cp -R /home/vagrant/conf.d /etc/logstash

echo ""
echo " *** Смена владельца каталога и файлов ***"
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
echo " *** Смена владельца файла ***"
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
