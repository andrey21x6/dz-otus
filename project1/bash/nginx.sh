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
dnf install mc nano telnet net-tools filebeat nginx -y

# Скачивание и установка filebeat
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.6.1-x86_64.rpm?_gl=1*xsxx36*_ga*NjU4NjU3ODA3LjE2NzU0MjkzNTg.*_ga_Q7TEQDPTH5*MTY3NTQyOTM1OC4xLjEuMTY3NTQyOTU1Ni4wLjAuMA..
mv ~/filebeat-8.6.1-x86_64.rpm?_gl=1*xsxx36*_ga*NjU4NjU3ODA3LjE2NzU0MjkzNTg.*_ga_Q7TEQDPTH5*MTY3NTQyOTM1OC4xLjEuMTY3NTQyOTU1Ni4wLjAuMA.. ~/filebeat-8.6.1-x86_64.rpm
rpm -ivh ~/filebeat-8.6.1-x86_64.rpm
#curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.5.2-x86_64.rpm
#rpm -ivh ~/filebeat-8.5.2-x86_64.rpm

# Удаляем старый конфиг nginx и копируем новый
rm -f /etc/filebeat/filebeat.yml
cp /home/vagrant/filebeat.yml /etc/filebeat/filebeat.yml

# Запускаем filebeat и добавляем в автозагрузку
systemctl enable --now filebeat

# Разрешение в SELinux на обратное проксирование
setsebool -P httpd_can_network_connect 1

# Удаляем старый конфиг nginx и копируем новый
rm -f /etc/nginx/nginx.conf
cp /home/vagrant/nginx.conf /etc/nginx/nginx.conf

# Автозапуск nginx
systemctl enable nginx

# Старт nginx
systemctl start nginx

# Включение SSH по паролю
sed -i -e "s/\PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config

# Установка пароля
echo root:1 | /usr/sbin/chpasswd
#yes 1 | passwd root

# Рестарт службы SSH
systemctl restart sshd


