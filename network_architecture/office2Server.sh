#!/bin/bash

# Установка программ
yum install mc nano traceroute -y

# Отключить маршрутизацию по умолчанию для сетевого интерфейса eth0
echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 

# Добавить запись в файле (сетевой интерфейс eth1) ifcfg-eth1, тем самым, установить шлюз 192.168.1.1
echo "GATEWAY=192.168.1.193" >> /etc/sysconfig/network-scripts/ifcfg-eth1

# Добавление маршрута по умолчанию через сетевой интерфейс 192.168.1.193
ip route add default via 192.168.1.193 dev eth1

# Перезапуск сетевых интерфейсов
systemctl restart network
