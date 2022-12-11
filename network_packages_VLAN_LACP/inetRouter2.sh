#!/bin/bash

# Установка программ
yum install mc nano traceroute telnet -y

# Включение маршрутизации в файле sysctl.conf
echo net.ipv4.conf.all.forwarding=1 >> /etc/sysctl.conf

# Включение маршрутизации в файле sysctl.conf
echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf

# Включение маршрутизации
/sbin/sysctl -p /etc/sysctl.conf

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

# Проброс порта 80 ТСР на centralServer
iptables -t nat -A PREROUTING  -j DNAT -p tcp -m tcp --dport 80 --to-destination  192.168.0.2:80
iptables -t nat -A POSTROUTING -j SNAT -p tcp -m tcp --dport 80 --to-source       192.168.0.3
