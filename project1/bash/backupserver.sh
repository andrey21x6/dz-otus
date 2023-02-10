#!/bin/bash

echo ""
echo " *** Создаём каталоги ***"
echo ""
mkdir -p /home/vagrant/BACKUP/SQL /home/vagrant/BACKUP/LOG

echo ""
echo " *** Изменяем владельца каталогов ***"
echo ""
chown -R vagrant:vagrant /home/vagrant/BACKUP

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
