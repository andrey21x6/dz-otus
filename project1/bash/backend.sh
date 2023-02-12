#!/bin/bash

echo ""
echo " *** Установка nginx ***"
echo ""
dnf install nginx -y

echo ""
echo " *** Установка PHP ***"
echo ""
dnf install php php-cli php-mysqlnd php-json php-gd php-ldap php-odbc php-pdo php-opcache php-pear php-xml php-xmlrpc php-mbstring php-snmp php-soap php-zip -y

echo ""
echo " *** Удаляем файлы в каталоге html ***"
echo ""
rm -rf /usr/share/nginx/html/

echo ""
echo " *** Копируем другие файлы в каталоге html ***"
echo ""
cp -r /home/vagrant/html /usr/share/nginx/html

echo ""
echo " *** Разрешение в SELinux на на удалённое подключение по http ***"
echo ""
setsebool -P httpd_can_network_connect 1

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
