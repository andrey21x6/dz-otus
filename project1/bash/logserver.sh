#!/bin/bash

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


