#!/bin/bash

# Установка программ
yum install mc nano traceroute -y

# Включение маршрутизации в файле sysctl.conf
echo net.ipv4.conf.all.forwarding=1 >> /etc/sysctl.conf

# Включение маршрутизации в файле sysctl.conf
echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf

# Применить
/sbin/sysctl -p /etc/sysctl.conf

# Добавить запись в файле (сетевой интерфейс eth1) ifcfg-eth1, тем самым, установить шлюз 192.168.255.1
echo "GATEWAY=192.168.255.1" >> /etc/sysconfig/network-scripts/ifcfg-eth1

# Отключить маршрутизацию по умолчанию для сетевого интерфейса eth0
echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0



# Настройки сетевого интерфейса eth1:0
#cat <<EOT>> /etc/sysconfig/network-scripts/ifcfg-eth1:0
#DEVICE=eth1:0
#BOOTPROTO=static
#IPADDR=192.168.254.1
#NETMASK=255.255.255.252
#ONBOOT=yes
#EOT

# Настройки сетевого интерфейса eth1:1
#cat <<EOT>> /etc/sysconfig/network-scripts/ifcfg-eth1:1
#DEVICE=eth1:1
#BOOTPROTO=static
#IPADDR=192.168.253.1
#NETMASK=255.255.255.252
#ONBOOT=yes
#EOT

# Добавление статического маршрута в файле route-eth2 для подсети 192.168.2.0/24 через сетевой интерфейс 192.168.100.2
echo '192.168.2.0/24 via 192.168.100.2 dev eth2' > /etc/sysconfig/network-scripts/route-eth2

# Добавление статического маршрута в файле route-eth3 для подсети 192.168.1.0/24 через сетевой интерфейс 192.168.200.2
echo '192.168.1.0/24 via 192.168.200.2 dev eth3' > /etc/sysconfig/network-scripts/route-eth3

# Перезапуск сетевых интерфейсов
systemctl restart network



ip route del default
ip route add default via 192.168.255.1 dev eth1
ip route add 192.168.2.0/24 via 192.168.100.2 dev eth2
ip route add 192.168.1.0/24 via 192.168.200.2 dev eth3