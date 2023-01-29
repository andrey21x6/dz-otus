#!/bin/bash

# Настройка репозитория
sed -i -e "s|mirrorlist=|#mirrorlist=|g" /etc/yum.repos.d/CentOS-*
sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g" /etc/yum.repos.d/CentOS-*

# Настройка кодировки
localectl set-locale LANG=en_US.UTF-8
dnf install langpacks-en glibc-all-langpacks -y

# Установка программ
dnf install mc nano telnet net-tools nginx -y

# Разрешение в SELinux на обратное проксирование
setsebool -P httpd_can_network_connect 1

# Удаляем старый конфиг nginx и копируем новый
rm -f /etc/nginx/nginx.conf
cp /home/vagrant/nginx.conf /etc/nginx/nginx.conf

# Автозапуск nginx
systemctl enable nginx

# Старт nginx
systemctl start nginx
