#!/bin/bash

#dnf install java-11-openjdk-devel
#java -version

echo ""
echo " *** Копирование новых файлов repo ***"
echo ""
cp -R /home/vagrant/logserver/yum.repos.d/* /etc/yum.repos.d

echo ""
echo " *** Устанавка elasticsearch ***"
echo ""
dnf install --enablerepo=elasticsearch elasticsearch -y

echo ""
echo " *** Переименование оригинального конфиг файла elasticsearch.yml ***"
echo ""
mv /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml_bak

echo ""
echo " *** Копирование нового конфиг файла elasticsearch.yml ***"
echo ""
cp /home/vagrant/logserver/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml

echo ""
echo " *** Смена владельца файла ***"
echo ""
chown root:elasticsearch /etc/elasticsearch/elasticsearch.yml

echo ""
echo " *** Увеличение Timeout старта сервиса elasticsearch (иногда не успевает запуститься) ***"
echo ""
sed -i -e "s/TimeoutStartSec=75/TimeoutStartSec=150/g" /usr/lib/systemd/system/elasticsearch.service

echo ""
echo " *** Включение автозапуска elasticsearch ***"
echo ""
systemctl enable elasticsearch

echo ""
echo " *** Старт elasticsearch ***"
echo ""
systemctl start elasticsearch

#-------------------------------------------------------------------------------------------------------------------------

# https://192.168.100.29:9200
# Логин: elastic
# Пароль: При установке генерится: ... The generated password for the elastic built-in superuser is : mAaEdv=RXc0ZT=nA=HZP

# Смена пароля
#/usr/share/elasticsearch/bin/elasticsearch-reset-password -i -u elastic

# Подключение с помощью сертификата
#curl --cacert /etc/elasticsearch/certs/http_ca.crt -u elastic https://127.0.0.1:9200
#curl --cacert /etc/elasticsearch/certs/http_ca.crt -u elastic 'https://127.0.0.1:9200/_cat/indices?v&pretty'
# Вводим пароль

#-------------------------------------------------------------------------------------------------------------------------

echo ""
echo " *** Смена пароля в elasticsearch с автоответами ***"
echo ""
/usr/share/elasticsearch/bin/elasticsearch-reset-password -i -u elastic <<EOF
y
123456
123456
EOF

echo ""
echo " *** Устанавка kibana ***"
echo ""
dnf install kibana -y

echo ""
echo " *** Переименование оригинального конфиг файла kibana.yml ***"
echo ""
mv /etc/kibana/kibana.yml /etc/kibana/kibana.yml_bak

echo ""
echo " *** Копирование нового конфиг файла kibana.yml ***"
echo ""
cp /home/vagrant/logserver/kibana/kibana.yml /etc/kibana/kibana.yml

echo ""
echo " *** Смена владельца файла ***"
echo ""
chown root:kibana /etc/kibana/kibana.yml

echo ""
echo " *** Создание каталога certs и копирование каталога certs в /etc/kibana/ ***"
echo ""
cp -R /etc/elasticsearch/certs /etc/kibana/certs

echo ""
echo " *** Смена владельца каталога и файлов ***"
echo ""
chown -R root:kibana /etc/kibana/certs

echo ""
echo " *** Включение автозапуска kibana ***"
echo ""
systemctl enable kibana.service

echo ""
echo " *** Старт kibana ***"
echo ""
systemctl start kibana.service

echo ""
echo " *** Смена пароля для kibana в elasticsearch с автоответами ***"
echo ""
/usr/share/elasticsearch/bin/elasticsearch-reset-password -i -u kibana_system <<EOF
y
123456
123456
EOF

echo ""
echo " *** Установка logstash ***"
echo ""
dnf install logstash -y

echo ""
echo " *** Копирование новых конфиг файлов для logstash ***"
echo ""
cp -R /home/vagrant/logserver/logstash/conf.d /etc/logstash

echo ""
echo " *** Смена владельца каталога и файлов ***"
echo ""
chown -R root:logstash /etc/logstash/conf.d

echo ""
echo " *** Создание каталога certs и копирование каталога certs в /etc/logstash/ ***"
echo ""
cp -R /etc/elasticsearch/certs /etc/logstash/certs

echo ""
echo " *** Смена владельца каталога и файлов ***"
echo ""
chown -R root:logstash /etc/logstash/certs

echo ""
echo " *** Переименовывание оригинального конфиг файла pipelines.yml ***"
echo ""
mv /etc/logstash/pipelines.yml /etc/logstash/pipelines.yml_bak

echo ""
echo " *** Копирование конфиг файла pipelines.yml ***"
echo ""
cp /home/vagrant/pipelines.yml /etc/logstash/pipelines.yml

echo ""
echo " *** Смена владельца файла ***"
echo ""
chown root:logstash /etc/logstash/pipelines.yml

echo ""
echo " *** Включение автозапуска logstash ***"
echo ""
systemctl enable logstash.service

echo ""
echo " *** Старт logstash ***"
echo ""
systemctl start logstash.service
