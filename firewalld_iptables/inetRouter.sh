#!/bin/bash

# Установка программ
yum install mc nano traceroute epel-release libpcap -y

# Установка knockd server
rpm -ivh http://li.nux.ro/download/nux/dextop/el7Server/x86_64/knock-0.7-1.el7.nux.x86_64.rpm

# Установка параметра для работы с интерфейсрм eth1 в файл knockd
echo 'OPTIONS="-i eth1"' > /etc/sysconfig/knockd

# Создание настроек конфигурационного файла knockd
cat > /etc/knockd.conf <<EOF
[options]
    UseSyslog
	logfile = /var/log/knockd.log

[opencloseSSH]
	sequence      = 2222:tcp,3333:tcp,4444:tcp
	seq_timeout   = 5
	tcpflags      = syn
	start_command = /sbin/iptables -A INPUT -s %IP% -p tcp --dport ssh -j ACCEPT
	cmd_timeout   = 10
	stop_command  = /sbin/iptables -D INPUT -s %IP% -p tcp --dport ssh -j ACCEPT
EOF

# Включение автозапуска и старт nginx
systemctl enable knockd && systemctl start knockd

# Разрешаем SSH по паролю и перезапуск
sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sshd -T && systemctl restart sshd

# Включение маршрутизации в файле sysctl.conf
echo net.ipv4.conf.all.forwarding=1 >> /etc/sysctl.conf

# Включение маршрутизации в файле sysctl.conf
echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf

# Включение маршрутизации
/sbin/sysctl -p /etc/sysctl.conf

# Добавление статического маршрута для подсети 192.168.0.0/16 через сетевой интерфейс 192.168.255.2
echo '192.168.0.0/16 via 192.168.255.2 dev eth1' > /etc/sysconfig/network-scripts/route-eth1

# Добавление статического маршрута для подсети 192.168.0.0/16 через сетевой интерфейс 192.168.255.2
ip route add 192.168.0.0/16 via 192.168.255.2 dev eth1

# Включение маскарадинга для всех, кроме подсети 192.168.0.0/16
iptables -t nat -A POSTROUTING ! -d 192.168.0.0/16 -o eth0 -j MASQUERADE

# Чтобы не обрывало установленную сессию
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# Политика по умолчанию для цепочки INPUT
iptables -P INPUT DROP

#knock 192.168.255.1 2222:tcp 3333:tcp 4444:tcp && ssh vagrant@192.168.255.1