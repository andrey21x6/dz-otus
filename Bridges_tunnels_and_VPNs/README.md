# Мосты, туннели и VPN

# **Prerequisite**

- Host OS: Ubuntu Desktop 20.04.5
- Guest OS: CentOS 7.8.2003
- VirtualBox: 6.1.40
- Vagrant: 2.3.2
- easy-rsa: 3.0.8

# **Содержание ДЗ**

1. Между двумя виртуалками поднять vpn в режимах

	tun
	
	tap
	
2. Поднять RAS на базе OpenVPN с клиентскими сертификатами, подключиться с локальной машины на виртуалку

# **Выполнение ДЗ**

### TUN/TAP режимы VPN

Перейдём в папку OpenVPN и запустим Vagrantfile
```
vagrant up
```

После запуска машин из Vagrantfile заходим на ВМ server
```
vagrant ssh server
```

Устанавливаем epel репозиторий и пакеты
```
sudo -i
yum install -y epel-release mc nano
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

Cоздаём конфигурационный файл vpn-сервера для режима TAP
```
nano /etc/openvpn/server.conf

	dev tap
	ifconfig 10.10.10.1 255.255.255.0
	topology subnet
	secret /etc/openvpn/static.key
	comp-lzo
	status /var/log/openvpn-status.log
	log /var/log/openvpn.log
	verb 3
```

Запускаем openvpn сервер и добавляем в автозагрузку
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

Откроем второй терминал и зайдём на ВМ client
```
vagrant ssh client
```

Устанавливаем epel репозиторий и пакеты
```
sudo -i
yum install -y epel-release mc nano
yum install -y openvpn iperf3
```

Отключаем SELinux
```
setenforce 0
```

Настройка openvpn клиента

Cоздаём конфигурационнýй файл клиента
```
nano /etc/openvpn/server.conf

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

Запускаем openvpn клиент и добавляем в автозагрузку
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

Запускаем iperf3 на сервере в режиме сервера и замеряем скорость в туннеле
```
iperf3 -s &
```

Запускаем iperf3 на клиенте в режиме клиента и замеряем скорость в туннеле
```
iperf3 -c 10.10.10.1 -t 40 -i 5
```

**Результат на сервере в режиме TAP**
```
[1] 3690
[root@server ~]# -----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------
Accepted connection from 10.10.10.2, port 50238
[  5] local 10.10.10.1 port 5201 connected to 10.10.10.2 port 50240
[ ID] Interval           Transfer     Bandwidth
[  5]   0.00-1.00   sec  10.9 MBytes  91.2 Mbits/sec
[  5]   1.00-2.01   sec  12.9 MBytes   107 Mbits/sec
[  5]   2.01-3.00   sec  8.26 MBytes  69.7 Mbits/sec
[  5]   3.00-4.00   sec  13.1 MBytes   110 Mbits/sec
[  5]   4.00-5.00   sec  13.6 MBytes   114 Mbits/sec
[  5]   5.00-6.01   sec  8.96 MBytes  74.6 Mbits/sec
[  5]   6.01-7.01   sec  12.2 MBytes   102 Mbits/sec
[  5]   7.01-8.01   sec  13.4 MBytes   112 Mbits/sec
[  5]   8.01-9.00   sec  13.2 MBytes   111 Mbits/sec
[  5]   9.00-10.00  sec  11.3 MBytes  94.5 Mbits/sec
[  5]  10.00-11.00  sec  10.1 MBytes  84.9 Mbits/sec
[  5]  11.00-12.00  sec  10.1 MBytes  84.9 Mbits/sec
[  5]  12.00-13.00  sec  12.8 MBytes   107 Mbits/sec
[  5]  13.00-14.00  sec  13.5 MBytes   114 Mbits/sec
[  5]  14.00-15.00  sec  13.7 MBytes   115 Mbits/sec
[  5]  15.00-16.00  sec  13.6 MBytes   114 Mbits/sec
[  5]  16.00-17.00  sec  13.6 MBytes   114 Mbits/sec
[  5]  17.00-18.01  sec  13.7 MBytes   115 Mbits/sec
[  5]  18.01-19.00  sec  13.7 MBytes   115 Mbits/sec
[  5]  19.00-20.01  sec  13.0 MBytes   108 Mbits/sec
[  5]  20.01-21.01  sec  12.2 MBytes   102 Mbits/sec
[  5]  21.01-22.01  sec  12.1 MBytes   102 Mbits/sec
[  5]  22.01-23.01  sec  12.2 MBytes   102 Mbits/sec
[  5]  23.01-24.00  sec  12.2 MBytes   103 Mbits/sec
[  5]  24.00-25.00  sec  13.7 MBytes   115 Mbits/sec
[  5]  25.00-26.01  sec  13.7 MBytes   115 Mbits/sec
[  5]  26.01-27.01  sec  13.8 MBytes   115 Mbits/sec
[  5]  27.01-28.01  sec  13.0 MBytes   109 Mbits/sec
[  5]  28.01-29.00  sec  12.2 MBytes   103 Mbits/sec
[  5]  29.00-30.01  sec  12.7 MBytes   106 Mbits/sec
[  5]  30.01-31.00  sec  11.7 MBytes  98.7 Mbits/sec
^C
[root@server ~]# [  5]  31.00-32.01  sec  13.7 MBytes   115 Mbits/sec
[  5]  32.01-33.00  sec  13.7 MBytes   116 Mbits/sec
[  5]  33.00-34.00  sec  13.7 MBytes   115 Mbits/sec
[  5]  33.00-34.00  sec  13.7 MBytes   115 Mbits/sec
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth
[  5]   0.00-34.00  sec  0.00 Bytes  0.00 bits/sec                  sender
[  5]   0.00-34.00  sec   427 MBytes   105 Mbits/sec                  receiver
iperf3: the client has terminated
-----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------
^C
```

**Результат на клиенте в режиме TAP**
```
Connecting to host 10.10.10.1, port 5201
[  4] local 10.10.10.2 port 50240 connected to 10.10.10.1 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-5.00   sec  62.1 MBytes   104 Mbits/sec  1191   1.00 MBytes
[  4]   5.00-10.01  sec  59.6 MBytes  99.9 Mbits/sec  1756    203 KBytes
[  4]  10.01-15.00  sec  59.4 MBytes  99.8 Mbits/sec  104    267 KBytes
[  4]  15.00-20.01  sec  68.1 MBytes   114 Mbits/sec    0    409 KBytes
[  4]  20.01-25.01  sec  62.4 MBytes   105 Mbits/sec    0    544 KBytes
[  4]  25.01-30.00  sec  64.8 MBytes   109 Mbits/sec    0   1.24 MBytes
^C[  4]  30.00-33.95  sec  52.4 MBytes   111 Mbits/sec   17    769 KBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-33.95  sec   429 MBytes   106 Mbits/sec  3068             sender
[  4]   0.00-33.95  sec  0.00 Bytes  0.00 bits/sec                  receiver
iperf3: interrupt - the client has terminated



Connecting to host 10.10.10.1, port 5201
[  4] local 10.10.10.2 port 50244 connected to 10.10.10.1 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-5.00   sec  62.2 MBytes   104 Mbits/sec   46    462 KBytes
[  4]   5.00-10.01  sec  54.3 MBytes  91.0 Mbits/sec    0    558 KBytes
[  4]  10.01-15.00  sec  52.4 MBytes  88.0 Mbits/sec    0    601 KBytes
[  4]  15.00-20.00  sec  69.4 MBytes   116 Mbits/sec    1    626 KBytes
[  4]  20.00-25.00  sec  60.0 MBytes   101 Mbits/sec    3    542 KBytes
[  4]  25.00-30.00  sec  56.9 MBytes  95.4 Mbits/sec  937    274 KBytes
[  4]  30.00-35.01  sec  69.2 MBytes   116 Mbits/sec    0    419 KBytes
^C[  4]  35.01-35.92  sec  13.3 MBytes   122 Mbits/sec    0    440 KBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-35.92  sec   438 MBytes   102 Mbits/sec  987             sender
[  4]   0.00-35.92  sec  0.00 Bytes  0.00 bits/sec                  receiver
iperf3: interrupt - the client has terminated
```

Редактируем конфигурационный файл на сервере и клиенте /etc/openvpn/server.conf, меняем режим на TUN
```
nano /etc/openvpn/server.conf

	...
	dev tun
	...
	
systemctl restart openvpn@server
```

Запускаем iperf3 на сервере в режиме сервера и замеряем скорость в туннеле
```
iperf3 -s &
```

Запускаем iperf3 на клиенте в режиме клиента и замеряем скорость в туннеле
```
iperf3 -c 10.10.10.1 -t 40 -i 5
```

**Результат на сервере в режиме TUN**
```
[2] 3742
[root@server ~]# iperf3: error - unable to start listener for connections: Address already in use
iperf3: exiting
[root@server ~]# Accepted connection from 10.10.10.2, port 50242
[  5] local 10.10.10.1 port 5201 connected to 10.10.10.2 port 50244
[ ID] Interval           Transfer     Bandwidth
[  5]   0.00-1.00   sec  11.5 MBytes  96.1 Mbits/sec
[  5]   1.00-2.00   sec  12.1 MBytes   101 Mbits/sec
[  5]   2.00-3.00   sec  12.3 MBytes   103 Mbits/sec
[  5]   3.00-4.00   sec  12.2 MBytes   103 Mbits/sec
[  5]   4.00-5.00   sec  11.9 MBytes  99.5 Mbits/sec
[  5]   5.00-6.00   sec  12.3 MBytes   104 Mbits/sec
[  5]   6.00-7.00   sec  11.0 MBytes  92.6 Mbits/sec
[  5]   7.00-8.00   sec  10.4 MBytes  86.9 Mbits/sec
[  5]   8.00-9.00   sec  10.3 MBytes  86.8 Mbits/sec
[  5]   9.00-10.00  sec  10.3 MBytes  86.6 Mbits/sec
[  5]  10.00-11.00  sec  10.3 MBytes  86.7 Mbits/sec
[  5]  11.00-12.00  sec  10.4 MBytes  86.9 Mbits/sec
[  5]  12.00-13.00  sec  10.3 MBytes  86.8 Mbits/sec
[  5]  13.00-14.00  sec  10.3 MBytes  86.7 Mbits/sec
[  5]  14.00-15.01  sec  11.9 MBytes  99.0 Mbits/sec
[  5]  15.01-16.00  sec  13.9 MBytes   117 Mbits/sec
[  5]  16.00-17.00  sec  13.4 MBytes   112 Mbits/sec
[  5]  17.00-18.01  sec  13.9 MBytes   117 Mbits/sec
[  5]  18.01-19.00  sec  13.8 MBytes   116 Mbits/sec
[  5]  19.00-20.00  sec  14.0 MBytes   117 Mbits/sec
[  5]  20.00-21.00  sec  13.8 MBytes   116 Mbits/sec
[  5]  21.00-22.00  sec  13.5 MBytes   113 Mbits/sec
[  5]  22.00-23.00  sec  11.6 MBytes  97.0 Mbits/sec
[  5]  23.00-24.00  sec  10.3 MBytes  86.2 Mbits/sec
[  5]  24.00-25.00  sec  10.3 MBytes  86.4 Mbits/sec
[  5]  25.00-26.00  sec  10.3 MBytes  86.3 Mbits/sec
[  5]  26.00-27.00  sec  10.3 MBytes  86.3 Mbits/sec
[  5]  27.00-28.01  sec  8.42 MBytes  70.2 Mbits/sec
[  5]  28.01-29.00  sec  14.3 MBytes   121 Mbits/sec
[  5]  29.00-30.00  sec  13.9 MBytes   116 Mbits/sec
^C
[2]+  Exit 1                  iperf3 -s
[root@server ~]# [  5]  30.00-31.00  sec  13.8 MBytes   116 Mbits/sec
[  5]  31.00-32.01  sec  13.9 MBytes   116 Mbits/sec
[  5]  32.01-33.00  sec  13.8 MBytes   116 Mbits/sec
[  5]  33.00-34.01  sec  13.9 MBytes   116 Mbits/sec
^C
[root@server ~]# [  5]  34.01-35.00  sec  13.7 MBytes   116 Mbits/sec
[  5]  34.01-35.00  sec  13.7 MBytes   116 Mbits/sec
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth
[  5]   0.00-35.00  sec  0.00 Bytes  0.00 bits/sec                  sender
[  5]   0.00-35.00  sec   436 MBytes   104 Mbits/sec                  receiver
iperf3: the client has terminated
-----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------
```

**Результат на клиенте в режиме TUN**
```
Connecting to host 10.10.10.1, port 5201
[  4] local 10.10.10.2 port 50244 connected to 10.10.10.1 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-5.00   sec  62.2 MBytes   104 Mbits/sec   46    462 KBytes
[  4]   5.00-10.01  sec  54.3 MBytes  91.0 Mbits/sec    0    558 KBytes
[  4]  10.01-15.00  sec  52.4 MBytes  88.0 Mbits/sec    0    601 KBytes
[  4]  15.00-20.00  sec  69.4 MBytes   116 Mbits/sec    1    626 KBytes
[  4]  20.00-25.00  sec  60.0 MBytes   101 Mbits/sec    3    542 KBytes
[  4]  25.00-30.00  sec  56.9 MBytes  95.4 Mbits/sec  937    274 KBytes
[  4]  30.00-35.01  sec  69.2 MBytes   116 Mbits/sec    0    419 KBytes
^C[  4]  35.01-35.92  sec  13.3 MBytes   122 Mbits/sec    0    440 KBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-35.92  sec   438 MBytes   102 Mbits/sec  987             sender
[  4]   0.00-35.92  sec  0.00 Bytes  0.00 bits/sec                  receiver
iperf3: interrupt - the client has terminated
```

**Разница tap и tun режимов**:

***TAP***:

- создает ethernet-туннель
- здесь не получилось поднять маршрут посредством записи в конфиг-файле openvpn

**Преимущества**:
- ведёт себя как настоящий сетевой адаптер (за исключением того, что он виртуальный)
- может осуществлять транспорт любого сетевого протокола (IPv4, IPv6, IPX и прочих)
- работает на 2 уровне, поэтому может передавать Ethernet-кадры внутри тоннеля
- позволяет использовать мосты

**Недостатки**:
- в тоннель попадает broadcast-трафик, что иногда не требуется
- добавляет свои заголовки поверх заголовков Ethernet на все пакеты, которые следуют через тоннель
- в целом, менее масштабируем из-за предыдущих двух пунктов
- не поддерживается устройствами Android и iOS (по информации с сайта OpenVPN)

***TUN***:

- создает ip-туннель
- более экономный для трафика и процессора, соответственно, использование tun должно показать большую производительность
- из соответствующей директории автоматически поднимается и все работает
- для проверки доступности изолированных сетей на каждом хосте дополнительно поднимаются сети tun0 inet 10.10.10.1/24 и tun0 inet 10.10.10.2/24, маршуты к этим сетям поднимаются автоматически и можно проверить их доступность посредством ping

**Преимущества**:
- передает только пакеты протокола IP (3й уровень)
- сравнительно (отн. TAP) меньшие накладные расходы и, фактически, ходит только тот IP-трафик, который предназначен конкретному клиенту

**Недостатки**:
- broadcast-трафик обычно не передаётся
- нельзя использовать мосты

### RAS на базе OpenVPN

Перейдём в папку RAS и запустим Vagrantfile
```
vagrant up
```

После запуска машины из Vagrantfile заходим на ВМ serverras
```
vagrant ssh serverras
```

Устанавливаем epel репозиторий и пакеты
```
sudo -i
yum install -y epel-release mc nano
yum install -y openvpn easy-rsa
```

Отключаем SELinux
```
setenforce 0
```

Переходим в директорию /etc/openvpn/ и инициализируем pki
```
cd /etc/openvpn/
/usr/share/easy-rsa/3.0.8/easyrsa init-pki

	init-pki complete; you may now create a CA or requests.
	Your newly created PKI dir is: /etc/openvpn/pki
```

Сгенерируем необходимые ключи и сертификаты для сервера serverras
```
echo 'rasvpn' | /usr/share/easy-rsa/3.0.8/easyrsa build-ca nopass

	Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
	Generating RSA private key, 2048 bit long modulus
	.......+++
	...............+++
	e is 65537 (0x10001)
	You are about to be asked to enter information that will be incorporated
	into your certificate request.
	What you are about to enter is what is called a Distinguished Name or a DN.
	There are quite a few fields but you can leave some blank
	For some fields there will be a default value,
	If you enter '.', the field will be left blank.
	-----
	Common Name (eg: your user, host, or server name) [Easy-RSA CA]:
	CA creation complete and you may now import and sign cert requests.
	Your new CA certificate file for publishing is at:
	/etc/openvpn/pki/ca.crt

echo 'rasvpn' | /usr/share/easy-rsa/3.0.8/easyrsa gen-req server nopass

	Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
	Generating a 2048 bit RSA private key
	...............................+++
	......................+++
	writing new private key to '/etc/openvpn/pki/easy-rsa-22770.F2hnTq/tmp.q2r4zp'
	-----
	You are about to be asked to enter information that will be incorporated
	into your certificate request.
	What you are about to enter is what is called a Distinguished Name or a DN.
	There are quite a few fields but you can leave some blank
	For some fields there will be a default value,
	If you enter '.', the field will be left blank.
	-----
	Common Name (eg: your user, host, or server name) [server]:
	Keypair and certificate request completed. Your files are:
	req: /etc/openvpn/pki/reqs/server.req
	key: /etc/openvpn/pki/private/server.key

echo 'yes' | /usr/share/easy-rsa/3.0.8/easyrsa sign-req server server

	Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017

	You are about to sign the following certificate.
	Please check over the details shown below for accuracy. Note that this request
	has not been cryptographically verified. Please be sure it came from a trusted
	source or that you have verified the request checksum with the sender.

	Request subject, to be signed as a server certificate for 825 days:

	subject=
		commonName                = rasvpn

	Type the word 'yes' to continue, or any other input to abort.
	  Confirm request details: Using configuration from /etc/openvpn/pki/easy-rsa-22813.0A65Zo/tmp.FIzyTd
	Check that the request matches the signature
	Signature ok
	The Subject's Distinguished Name is as follows
	commonName            :ASN.1 12:'rasvpn'
	Certificate is to be certified until Mar 11 06:12:26 2025 GMT (825 days)

	Write out database with 1 new entries
	Data Base Updated

	Certificate created at: /etc/openvpn/pki/issued/server.crt

/usr/share/easy-rsa/3.0.8/easyrsa gen-dh

	Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
	Generating DH parameters, 2048 bit long safe prime, generator 2
	This is going to take a long time
	...................................................................+...

	DH parameters of size 2048 created at /etc/openvpn/pki/dh.pem

openvpn --genkey --secret ta.key
```

Сгенерируем сертификаты для клиента
```
echo 'client' | /usr/share/easy-rsa/3/easyrsa gen-req client nopass

	Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
	Generating a 2048 bit RSA private key
	.............................................+++
	..........+++
	writing new private key to '/etc/openvpn/pki/easy-rsa-23010.2KpeZe/tmp.TMu1ij'
	-----
	You are about to be asked to enter information that will be incorporated
	into your certificate request.
	What you are about to enter is what is called a Distinguished Name or a DN.
	There are quite a few fields but you can leave some blank
	For some fields there will be a default value,
	If you enter '.', the field will be left blank.
	-----
	Common Name (eg: your user, host, or server name) [client]:
	Keypair and certificate request completed. Your files are:
	req: /etc/openvpn/pki/reqs/client.req
	key: /etc/openvpn/pki/private/client.key

echo 'yes' | /usr/share/easy-rsa/3/easyrsa sign-req client client

	Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017

	You are about to sign the following certificate.
	Please check over the details shown below for accuracy. Note that this request
	has not been cryptographically verified. Please be sure it came from a trusted
	source or that you have verified the request checksum with the sender.

	Request subject, to be signed as a client certificate for 825 days:

	subject=
		commonName                = client

	Type the word 'yes' to continue, or any other input to abort.
	  Confirm request details: Using configuration from /etc/openvpn/pki/easy-rsa-23053.RyNJvy/tmp.MIoFcq
	Check that the request matches the signature
	Signature ok
	The Subject's Distinguished Name is as follows
	commonName            :ASN.1 12:'client'
	Certificate is to be certified until Mar 11 06:15:03 2025 GMT (825 days)

	Write out database with 1 new entries
	Data Base Updated

	Certificate created at: /etc/openvpn/pki/issued/client.crt
```

Создадим конфигурационнýй файл /etc/openvpn/server.conf
```
nano /etc/openvpn/server.conf

	port 1207
	proto udp
	dev tun
	ca /etc/openvpn/pki/ca.crt
	cert /etc/openvpn/pki/issued/server.crt
	key /etc/openvpn/pki/private/server.key
	dh /etc/openvpn/pki/dh.pem
	server 10.10.10.0 255.255.255.0
	ifconfig-pool-persist ipp.txt
	client-to-client
	client-config-dir /etc/openvpn/client
	keepalive 10 120
	comp-lzo
	persist-key
	persist-tun
	status /var/log/openvpn-status.log
	log /var/log/openvpn.log
	verb 3
```

Запускаем openvpn сервер и добавляем в автозагрузку
```
systemctl start openvpn@server
systemctl enable openvpn@server
systemctl status openvpn@server

	● openvpn@server.service - OpenVPN Robust And Highly Flexible Tunneling Application On server
	   Loaded: loaded (/usr/lib/systemd/system/openvpn@.service; disabled; vendor preset: disabled)
	   Active: active (running) since Wed 2022-12-07 06:20:05 UTC; 8s ago
	 Main PID: 23368 (openvpn)
	   Status: "Initialization Sequence Completed"
	   CGroup: /system.slice/system-openvpn.slice/openvpn@server.service
			   └─23368 /usr/sbin/openvpn --cd /etc/openvpn/ --config server.conf

	Dec 07 06:20:05 serverras systemd[1]: Starting OpenVPN Robust And Highly Flexible Tunneling Application On server...
	Dec 07 06:20:05 serverras systemd[1]: Started OpenVPN Robust And Highly Flexible Tunneling Application On server.
```

Скопируем следующие файлы сертификатов и ключ для клиента на хостмашину в каталог /etc/openvpn/client
```
/etc/openvpn/pki/ca.crt
/etc/openvpn/pki/issued/client.crt
/etc/openvpn/pki/private/client.key
```

Создадим конфигурационный файл клиента client.conf на хост-машине
```
nano /etc/openvpn/client/client.conf

	client
	dev tun
	proto udp
	remote 192.168.100.239 1207
	resolv-retry infinite
	ca /etc/openvpn/client/ca.crt
	cert /etc/openvpn/client/client.crt
	key /etc/openvpn/client/client.key
	persist-key
	persist-tun
	comp-lzo
	verb 3
```

Подключаемся к openvpn сервер с хост-машины
```
openvpn --config /etc/openvpn/client/client.conf
```

При успешном подключении проверяем пинг по внутреннему IP адресу сервера в туннеле
```
ping -c 4 10.10.10.1

	PING 10.10.10.1 (10.10.10.1) 56(84) bytes of data.
	64 bytes from 10.10.10.1: icmp_seq=1 ttl=64 time=0.811 ms
	64 bytes from 10.10.10.1: icmp_seq=2 ttl=64 time=0.736 ms
	64 bytes from 10.10.10.1: icmp_seq=3 ttl=64 time=0.773 ms
	64 bytes from 10.10.10.1: icmp_seq=4 ttl=64 time=0.793 ms
```

Также проверяем командами на хостовой машине, что сеть туннеля импортирована в таблицу маршрутизации
```
ip r

	default via 192.168.100.1 dev enp3s0 proto dhcp metric 100
	10.10.10.0/24 via 10.10.10.5 dev tun0
	10.10.10.5 dev tun0 proto kernel scope link src 10.10.10.6
	169.254.0.0/16 dev enp3s0 scope link metric 1000
	172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1 linkdown
	192.168.10.0/24 dev vboxnet2 proto kernel scope link src 192.168.10.1 linkdown
	192.168.100.0/24 dev enp3s0 proto kernel scope link src 192.168.100.29 metric 100
	
netstat -rn

	Таблица маршутизации ядра протокола IP
	Destination Gateway Genmask Flags MSS Window irtt Iface
	0.0.0.0         192.168.100.1   0.0.0.0         UG        0 0          0 enp3s0
	10.10.10.0      10.10.10.5      255.255.255.0   UG        0 0          0 tun0
	10.10.10.5      0.0.0.0         255.255.255.255 UH        0 0          0 tun0
	169.254.0.0     0.0.0.0         255.255.0.0     U         0 0          0 enp3s0
	172.17.0.0      0.0.0.0         255.255.0.0     U         0 0          0 docker0
	192.168.10.0    0.0.0.0         255.255.255.0   U         0 0          0 vboxnet2
	192.168.100.0   0.0.0.0         255.255.255.0   U         0 0          0 enp3s0
```

![openvpn_ras_test](https://github.com/andrey21x6/dz-otus/blob/main/Bridges_tunnels_and_VPNs/RAS/scrin/openvpn_ras_test.jpg)

### ![#008000](https://placehold.co/15x15/008000/008000.png) ![#f03c15](https://placehold.co/15x15/f03c15/f03c15.png) ![#1589F0](https://placehold.co/15x15/1589F0/1589F0.png)
### Благодарю за проверку!
