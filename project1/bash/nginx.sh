#!/bin/bash

echo ""
echo " *** Установка временной зоны ***"
echo ""
timedatectl set-timezone Asia/Yekaterinburg

echo ""
echo " *** Перезапуск сервиса cron после смены часового пояса ***"
echo ""
systemctl status crond.service

echo ""
echo " *** Настройка репозитория ***"
echo ""
sed -i -e "s|mirrorlist=|#mirrorlist=|g" /etc/yum.repos.d/CentOS-*
sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g" /etc/yum.repos.d/CentOS-*

echo ""
echo " *** Настройка кодировки ***"
echo ""
localectl set-locale LANG=en_US.UTF-8
dnf install langpacks-en glibc-all-langpacks -y

echo ""
echo " *** Установка программ ***"
echo ""
dnf install mc nano telnet net-tools -y

echo ""
echo " *** Включение SSH по паролю ***"
echo ""
sed -i -e "s/\PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config

echo ""
echo " *** Установка пароля root ***"
echo ""
echo root:1 | /usr/sbin/chpasswd
#yes 1 | passwd root

echo ""
echo " *** Рестарт службы SSH ***"
echo ""
systemctl restart sshd

#==========================================================================================================

echo ""
echo " *** Установка nginx ***"
echo ""
dnf install nginx -y

echo ""
echo " *** Разрешение в SELinux на обратное проксирование ***"
echo ""
setsebool -P httpd_can_network_connect 1

echo ""
echo " *** Удаляем старый конфиг nginx ***"
echo ""
rm -f /etc/nginx/nginx.conf

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

#echo ""
#echo " *** Скачивание и установка filebeat ***"
#echo ""
#curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.6.1-x86_64.rpm?_gl=1*xsxx36*_ga*NjU4NjU3ODA3LjE2NzU0MjkzNTg.*_ga_Q7TEQDPTH5*MTY3NTQyOTM1OC4xLjEuMTY3NTQyOTU1Ni4wLjAuMA..
#mv ~/filebeat-8.6.1-x86_64.rpm?_gl=1*xsxx36*_ga*NjU4NjU3ODA3LjE2NzU0MjkzNTg.*_ga_Q7TEQDPTH5*MTY3NTQyOTM1OC4xLjEuMTY3NTQyOTU1Ni4wLjAuMA.. ~/filebeat-8.6.1-x86_64.rpm
#rpm -ivh ~/filebeat-8.6.1-x86_64.rpm

echo ""
echo " *** Скачивание filebeat ***"
echo ""
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.5.2-x86_64.rpm

echo ""
echo " ***Установка filebeat ***"
echo ""
rpm -ivh filebeat-8.5.2-x86_64.rpm

echo ""
echo " *** Удаляем старый конфиг filebeat ***"
echo ""
rm -f /etc/filebeat/filebeat.yml

echo ""
echo " *** Копируем новый конфиг filebeat ***"
echo ""
cp /home/vagrant/filebeat.yml /etc/filebeat/filebeat.yml

echo ""
echo " *** Запускаем filebeat и добавляем в автозагрузку ***"
echo ""
systemctl enable --now filebeat
