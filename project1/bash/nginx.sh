#!/bin/bash

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
