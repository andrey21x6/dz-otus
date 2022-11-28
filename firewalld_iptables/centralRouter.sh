#!/bin/bash

# Установка программ
yum install mc nano traceroute epel-release libpcap -y

# Установка knock client
rpm -Uvh http://li.nux.ro/download/nux/dextop/el7Server/x86_64/knock-server-0.7-1.el7.nux.x86_64.rpm

# Включение маршрутизации в файле sysctl.conf
echo net.ipv4.conf.all.forwarding=1 >> /etc/sysctl.conf

# Включение маршрутизации в файле sysctl.conf
echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf

# Включение маршрутизации
/sbin/sysctl -p /etc/sysctl.conf

# Добавить запись в файле (сетевой интерфейс eth1) ifcfg-eth1, тем самым, установить шлюз 192.168.255.1
echo "GATEWAY=192.168.255.1" >> /etc/sysconfig/network-scripts/ifcfg-eth1

# Отключить маршрутизацию по умолчанию для сетевого интерфейса eth0
echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0

# Перезапуск сетевых интерфейсов
systemctl restart network

# Удаление маршрута по умолчанию
ip route del default

# Добавление маршрута по умолчанию через сетевой интерфейс 192.168.255.1
ip route add default via 192.168.255.1 dev eth1
