#!/bin/bash

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
echo " *** Смена владельца файла elasticsearch.yml ***"
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

# Изменение логики использования файла подкачки
# 0: подкачка отключена
# 1: минимальный объем подкачки без полного отключения
# 10: рекомендуемое значение для повышения производительности при наличии достаточного объема памяти в системе
# 100: агрессивная подкачка

echo ""
echo " *** Изменение логики использования файла подкачки, устанавливаем vm.swappiness=1 ***"
echo ""
sysctl -w vm.swappiness=1
echo vm.swappiness = 1 >> /etc/sysctl.conf

echo ""
echo " *** Включение автозапуска elasticsearch ***"
echo ""
systemctl enable elasticsearch

echo ""
echo " *** Старт elasticsearch ***"
echo ""
systemctl start elasticsearch

echo ""
echo " *** Устанавка Metricbeat ***"
echo ""
curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-8.6.2-x86_64.rpm
rpm -vi metricbeat-8.6.2-x86_64.rpm

echo ""
echo " *** Включение модуля elasticsearch-xpack ***"
echo ""
metricbeat modules enable elasticsearch-xpack

echo ""
echo " *** Включение автозапуска Metricbeat ***"
echo ""
systemctl enable metricbeat

echo ""
echo " *** Старт Metricbeat ***"
echo ""
systemctl start metricbeat

echo ""
echo " *** Рестарт elasticsearch ***"
echo ""
systemctl restart elasticsearch
