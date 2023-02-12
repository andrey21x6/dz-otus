#!/bin/bash

echo ""
echo " *** Установка nginx ***"
echo ""
dnf install nginx -y

echo ""
echo " *** Разрешение в SELinux на обратное проксирование ***"
echo ""
setsebool -P httpd_can_network_connect 1

echo ""
echo " *** Переименовываем оригинальный конфиг nginx.conf ***"
echo ""
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf_bak

echo ""
echo " *** Копируем конфиг nginx ***"
echo ""
cp /home/vagrant/nginx.conf /etc/nginx/nginx.conf

echo ""
echo " *** Включаем автозапуск nginx ***"
echo ""
systemctl enable nginx

echo ""
echo " *** Старт nginx ***"
echo ""
systemctl start nginx

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
