#!/bin/bash

# Установка временной зоны
timedatectl set-timezone Asia/Yekaterinburg

# Настройка репозитория
sed -i -e "s|mirrorlist=|#mirrorlist=|g" /etc/yum.repos.d/CentOS-*
sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g" /etc/yum.repos.d/CentOS-*

# Настройка кодировки
localectl set-locale LANG=en_US.UTF-8
dnf install langpacks-en glibc-all-langpacks -y

# Установка программ
dnf install mc nano telnet net-tools -y

# Включение SSH по паролю
sed -i -e "s/\PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config

# Установка пароля
echo root:1 | /usr/sbin/chpasswd
#yes 1 | passwd root

# Рестарт службы SSH
systemctl restart sshd


