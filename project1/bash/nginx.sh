#!/bin/bash

echo ""
echo " *** Установка nginx ***"
echo ""
dnf install nginx -y

echo ""
echo " *** Установка openssl ***"
echo ""
dnf install openssl -y

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
echo " *** Сгенерировать закрытый ключ ***"
echo ""
openssl genrsa -out /root/nginx.key 2048

echo ""
echo " *** Создать CSR с автоответами ***"
echo ""
openssl req -new -key /root/nginx.key -out /root/nginx.csr <<EOF
RU
URAL
CHELYABINSK
OTUS_Project1
Project1
nginx
andrey@7kas.ru

OTUS_Project1
EOF

echo ""
echo " *** Сгенерировать самоподписанный ключ ***"
echo ""
openssl x509 -req -days 365 -in /root/nginx.csr -signkey /root/nginx.key -out /root/nginx.crt

echo ""
echo " *** Копируются ключи ***"
echo ""
cp /root/nginx.crt /etc/pki/tls/certs/nginx.crt
cp /root/nginx.key /etc/pki/tls/private/nginx.key
cp /root/nginx.csr /etc/pki/tls/private/nginx.csr

echo ""
echo " *** Включаем автозапуск nginx ***"
echo ""
systemctl enable nginx

echo ""
echo " *** Старт nginx ***"
echo ""
systemctl start nginx
