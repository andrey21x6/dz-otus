#!/bin/bash

# Установка программ
yum install mc nano traceroute -y

# Включение маршрутизации в файле sysctl.conf
echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf
echo net.ipv4.conf.all.forwarding=1 >> /etc/sysctl.conf

# Применить
sbin/sysctl -p /etc/sysctl.conf

# Отключить маршрутизацию по умолчанию для сетевого интерфейса eth0
echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 

# Добавить запись в файле (сетевой интерфейс eth1) ifcfg-eth1, тем самым, установить шлюз 192.168.254.1
echo "GATEWAY=192.168.100.1" >> /etc/sysconfig/network-scripts/ifcfg-eth1

# Добавление статического маршрута
ip route add default via 192.168.100.1 dev eth1

# Перезапуск сетевых интерфейсов
systemctl restart network
