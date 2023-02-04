#!/bin/bash

dnf install java-11-openjdk-devel
#java -version

#=================================================================================================================

rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch



nano /etc/yum.repos.d/elasticsearch.repo

[elasticsearch]
name=Elasticsearch repository for 8.x packages
baseurl=https://artifacts.elastic.co/packages/8.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md



dnf install --enablerepo=elasticsearch elasticsearch -y

#systemctl daemon-reload
systemctl enable elasticsearch
systemctl start elasticsearch



# https://192.168.100.29:9200
# Логин: elastic
# Пароль: При установке генерится: ... The generated password for the elastic built-in superuser is : mAaEdv=RXc0ZT=nA=HZP

# Смена пароля
#/usr/share/elasticsearch/bin/elasticsearch-reset-password -i -u elastic

# Подключение с помощью сертификата
#curl --cacert /etc/elasticsearch/certs/http_ca.crt -u elastic https://127.0.0.1:9200
#Вводим пароль



# Конфигурационный файл
#nano /etc/elasticsearch/elasticsearch.yml
	#node.name: logserver
	#network.host: 192.168.90.17
	


#==================================================================================================================

rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch



nano /etc/yum.repos.d/kibana.repo

[kibana-8.x]
name=Kibana repository for 8.x packages
baseurl=https://artifacts.elastic.co/packages/8.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md



dnf install kibana -y

systemctl daemon-reload
systemctl enable kibana.service
systemctl start kibana.service



echo ""
echo " *** Изменяем конфигурацию kibana ***"
echo ""
sed -i -e "s/\#server.host: \"localhost\"/server.host: \"192.168.90.17\"/g" /etc/kibana/kibana.yml
sed -i -e "s/\#elasticsearch.hosts\: \[\"http\:\/\/localhost\:9200\"\]/elasticsearch.hosts\: \[\"https\:\/\/192.168.90.17\:9200\"\]/g" /etc/kibana/kibana.yml
sed -i -e "s/\#server.host: \"localhost\"   /   server.host: \"192.168.90.17\"/g" /etc/kibana/kibana.yml

# Смена пароля
#/usr/share/elasticsearch/bin/elasticsearch-reset-password -i -u kibana_system