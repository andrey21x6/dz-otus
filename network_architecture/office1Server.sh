#!/bin/bash

# Установка программ
yum install mc nano traceroute -y

# Отключить маршрутизацию по умолчанию для сетевого интерфейса eth0
echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 

# Добавить запись в файле (сетевой интерфейс eth1) ifcfg-eth1, тем самым, установить шлюз 192.168.2.1
echo "GATEWAY=192.168.2.193" >> /etc/sysconfig/network-scripts/ifcfg-eth1

# Добавление статического маршрута
ip route add default via 192.168.2.193 dev eth1

# Перезапуск сетевых интерфейсов
systemctl restart network
