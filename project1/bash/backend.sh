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
echo " *** Скачивание filebeat ***"
echo ""
curl -L -o /root/filebeat-8.6.1-x86_64.rpm https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.6.1-x86_64.rpm?_gl=1*xsxx36*_ga*NjU4NjU3ODA3LjE2NzU0MjkzNTg.*_ga_Q7TEQDPTH5*MTY3NTQyOTM1OC4xLjEuMTY3NTQyOTU1Ni4wLjAuMA..

echo ""
echo " ***Установка filebeat ***"
echo ""
rpm -ivh ~/filebeat-8.6.1-x86_64.rpm

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
