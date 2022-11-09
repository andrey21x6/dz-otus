#!/bin/bash

# Установка программ
yum install mc nano traceroute -y

# Включение маршрутизации
sysctl net.ipv4.conf.all.forwarding=1

# Включение маскарадинга для всех, кроме подсети 192.168.0.0/16
iptables -t nat -A POSTROUTING ! -d 192.168.0.0/16 -o eth0 -j MASQUERADE

# Добавление статического маршрута для подсети 192.168.0.0/16 через сетевой интерфейс 192.168.255.2
echo '192.168.0.0/16 via 192.168.255.2 dev eth1' > /etc/sysconfig/network-scripts/route-eth1

# Добавление статического маршрута для подсети 192.168.0.0/16 через сетевой интерфейс 192.168.255.2
ip route add 192.168.0.0/16 via 192.168.255.2 dev eth1
