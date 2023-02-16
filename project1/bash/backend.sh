#!/bin/bash

echo ""
echo " *** Устанавливается nginx ***"
echo ""
dnf install nginx -y

echo ""
echo " *** Устанавливается PHP ***"
echo ""
dnf install php php-cli php-mysqlnd php-json php-gd php-ldap php-odbc php-pdo php-opcache php-pear php-xml php-xmlrpc php-mbstring php-snmp php-soap php-zip -y

echo ""
echo " *** Удаляются файлы в каталоге html ***"
echo ""
rm -rf /usr/share/nginx/html/

echo ""
echo " *** Копируются файлы в каталог html ***"
echo ""
cp -r /home/vagrant/html /usr/share/nginx/html

echo ""
echo " *** Включение разрешения в SELinux на на удалённое подключение по http ***"
echo ""
setsebool -P httpd_can_network_connect 1

echo ""
echo " *** Включается автозапуск nginx ***"
echo ""
systemctl enable nginx

echo ""
echo " *** Старт nginx ***"
echo ""
systemctl start nginx
