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
echo " *** Переименовывание оригинального конфиг файла nginx.conf ***"
echo ""
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf_bak

echo ""
echo " *** Копирование конфиг файла nginx.conf ***"
echo ""
cp /home/vagrant/nginx.conf /etc/nginx/nginx.conf

echo ""
echo " *** Сгенерировать закрытый ключ nginx.key ***"
echo ""
openssl genrsa -out /root/nginx.key 2048

echo ""
echo " *** Создать файл CSR nginx.csr с автоответами ***"
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
echo " *** Сгенерировать самоподписанный ключ nginx.crt ***"
echo ""
openssl x509 -req -days 365 -in /root/nginx.csr -signkey /root/nginx.key -out /root/nginx.crt

echo ""
echo " *** Копируются файлы nginx.crt nginx.key nginx.csr ***"
echo ""
cp /root/nginx.crt /etc/pki/tls/certs/nginx.crt
cp /root/nginx.key /etc/pki/tls/private/nginx.key
cp /root/nginx.csr /etc/pki/tls/private/nginx.csr

echo ""
echo " *** Включение автозапуска nginx ***"
echo ""
systemctl enable nginx

echo ""
echo " *** Старт nginx ***"
echo ""
systemctl start nginx

echo ""
echo " *** Установка iptables-services ***"
echo ""
dnf remove nftables -y
dnf install iptables-services -y
systemctl enable iptables
systemctl start iptables

echo ""
echo " *** Настройка IPTABLES ***"
echo ""
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -F
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables-save > fwoff

echo ""
echo " *** Добавляется задание в cron, при старте восстанавливает правила IPTABLES ***"
echo ""
echo "@reboot root iptables-restore < fwoff" >> /etc/crontab
