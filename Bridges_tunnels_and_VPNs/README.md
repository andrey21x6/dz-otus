# Мосты, туннели и VPN

# **Prerequisite**

- Host OS: Ubuntu Desktop 20.04.5
- Guest OS: CentOS 7.8.2003
- VirtualBox: 6.1.40
- Vagrant: 2.3.2

# **Содержание ДЗ**

1. Между двумя виртуалками поднять vpn в режимах

	tun
	
	tap
	
2. Поднять RAS на базе OpenVPN с клиентскими сертификатами, подключиться с локальной машины на виртуалку

# **Выполнение ДЗ**

После запуска машин из Vagrantfile заходим на ВМ server

Устанавливаем epel репозиторий
```
sudo -i
yum install -y epel-release
```

Устанавливаем пакет openvpn, easy-rsa и iperf3
```
yum install -y openvpn iperf3
```

Отключаем SELinux
```
setenforce 0
```

Настроим openvpn сервер

Создаём файл-ключ
```
openvpn --genkey --secret /etc/openvpn/static.key
```

Cоздаём конфигурационнýй файл vpn-сервера (TUN/TAP режимы VPN)
```
vi /etc/openvpn/server.conf

dev tap
ifconfig 10.10.10.1 255.255.255.0
topology subnet
secret /etc/openvpn/static.key
comp-lzo
status /var/log/openvpn-status.log
log /var/log/openvpn.log
verb 3
```

Запускаем openvpn сервер и добавлāем в автозагрузку
```
systemctl start openvpn@server
systemctl enable openvpn@server
systemctl status openvpn@server

	● openvpn@server.service - OpenVPN Robust And Highly Flexible Tunneling Application On server
	   Loaded: loaded (/usr/lib/systemd/system/openvpn@.service; disabled; vendor preset: disabled)
	   Active: active (running) since Tue 2022-12-06 08:16:31 UTC; 7s ago
	 Main PID: 3517 (openvpn)
	   Status: "Pre-connection initialization successful"
	   CGroup: /system.slice/system-openvpn.slice/openvpn@server.service
			   └─3517 /usr/sbin/openvpn --cd /etc/openvpn/ --config server.conf

	Dec 06 08:16:31 server.loc systemd[1]: Starting OpenVPN Robust And Highly Flexible Tunneling Application On server...
	Dec 06 08:16:31 server.loc systemd[1]: Started OpenVPN Robust And Highly Flexible Tunneling Application On server.
```

Откроем второй терминал и зайдём на client

Устанавливаем epel репозиторий
```
sudo -i
yum install -y epel-release
```

Устанавливаем пакет openvpn, easy-rsa и iperf3
```
yum install -y openvpn iperf3
```

Отключаем SELinux
```
setenforce 0
```

Настройка openvpn клиента

Cоздаём конфигурационнýй файл клиента
```
vi /etc/openvpn/server.conf

	dev tap
	remote 192.168.10.10
	ifconfig 10.10.10.2 255.255.255.0
	topology subnet
	route 192.168.10.0 255.255.255.0
	secret /etc/openvpn/static.key
	comp-lzo
	status /var/log/openvpn-status.log
	log /var/log/openvpn.log
	verb 3
```

С сервера на клиент в директорию /etc/openvpn/ копируем файл-ключ static.key

Запускаем openvpn клиент и добавлāем в автозагрузку
```
systemctl start openvpn@server
systemctl enable openvpn@server
systemctl status openvpn@server

	● openvpn@server.service - OpenVPN Robust And Highly Flexible Tunneling Application On server
	   Loaded: loaded (/usr/lib/systemd/system/openvpn@.service; disabled; vendor preset: disabled)
	   Active: active (running) since Tue 2022-12-06 08:34:06 UTC; 1min 28s ago
	 Main PID: 3552 (openvpn)
	   Status: "Initialization Sequence Completed"
	   CGroup: /system.slice/system-openvpn.slice/openvpn@server.service
			   └─3552 /usr/sbin/openvpn --cd /etc/openvpn/ --config server.conf

	Dec 06 08:34:06 client.loc systemd[1]: Starting OpenVPN Robust And Highly Flexible Tunneling Application On server...
	Dec 06 08:34:06 client.loc systemd[1]: Started OpenVPN Robust And Highly Flexible Tunneling Application On server.
```

Далее необходимо замерить скорость в туннеле на openvpn сервере

Запускаем iperf3 в режиме сервера
```
iperf3 -s &
```

На openvpn клиенте запускаем iperf3 в режиме клиента и замеряем скорость в туннеле
```
iperf3 -c 10.10.10.1 -t 40 -i 5
```














### ![#008000](https://placehold.co/15x15/008000/008000.png) ![#f03c15](https://placehold.co/15x15/f03c15/f03c15.png) ![#1589F0](https://placehold.co/15x15/1589F0/1589F0.png)
### Благодарю за проверку!
