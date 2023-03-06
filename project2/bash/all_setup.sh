#!/bin/bash

echo ""
echo " *** Установка временной зоны Asia/Yekaterinburg ***"
echo ""
timedatectl set-timezone Asia/Yekaterinburg

echo ""
echo " *** Перезапуск сервиса cron после смены часового пояса ***"
echo ""
systemctl restart crond.service

echo ""
echo " *** Настройка репозитория ***"
echo ""
sed -i -e "s|mirrorlist=|#mirrorlist=|g" /etc/yum.repos.d/CentOS-*
sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g" /etc/yum.repos.d/CentOS-*
dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y

echo ""
echo " *** Настройка кодировки UTF-8 ***"
echo ""
localectl set-locale LANG=en_US.UTF-8
dnf install langpacks-en glibc-all-langpacks -y

echo ""
echo " *** Установка mc ***"
echo ""
dnf install mc -y

echo ""
echo " *** Установка nano ***"
echo ""
dnf install nano -y

echo ""
echo " *** Установка net-tools ***"
echo ""
dnf install net-tools -y

echo ""
echo " *** Установка htop ***"
echo ""
dnf install htop -y

echo ""
echo " *** Копирование нового файла repo elasticsearch.repo ***"
echo ""
cp /home/vagrant/elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo

echo ""
echo " *** Устанавка filebeat ***"
echo ""
dnf install filebeat -y

echo ""
echo " *** Переименование оригинального конфиг файла filebeat.yml ***"
echo ""
mv /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml_bak

echo ""
echo " *** Копирование нового конфиг файла filebeat.yml ***"
echo ""
cp /home/vagrant/filebeat.yml /etc/filebeat/filebeat.yml

echo ""
echo " *** Старт filebeat и добавление в автозагрузку ***"
echo ""
systemctl enable --now filebeat

echo ""
echo " *** Включение SSH по паролю ***"
echo ""
sed -i -e "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config

echo ""
echo " *** Установка пароля root ***"
echo ""
echo root:1 | /usr/sbin/chpasswd
#yes 1 | passwd root

echo ""
echo " *** Рестарт службы SSH ***"
echo ""
systemctl restart sshd
