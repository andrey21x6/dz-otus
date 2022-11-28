#!/bin/bash

# Установка программ
yum install mc nano traceroute -y
yum install epel-release -y
yum install nginx -y

# Включение автозапуска и старт nginx
systemctl enable nginx
systemctl start nginx

# Отключить маршрутизацию по умолчанию для сетевого интерфейса eth0
echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 

# Добавить запись в файле (сетевой интерфейс eth1) ifcfg-eth1, тем самым, установить шлюз 192.168.0.1
echo "GATEWAY=192.168.0.1" >> /etc/sysconfig/network-scripts/ifcfg-eth1

# Перезапуск сетевых интерфейсов
systemctl restart network

# Удаление маршрута по умолчанию
ip route del default

# Добавление маршрута по умолчанию через сетевой интерфейс 192.168.0.1
ip route add default via 192.168.0.1 dev eth1
