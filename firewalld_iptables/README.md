# Фильтрация трафика - nftables

# **Prerequisite**

- Host OS: Ubuntu Desktop 20.04.5
- Guest OS: 7.8.2003
- VirtualBox: 6.1.40
- Vagrant: 2.3.2

# **Содержание ДЗ**

1. Реализовать knocking port, centralRouter может попасть на ssh inetRouter через knock скрипт

2. Добавить inetRouter2, который виден(маршрутизируется (host-only тип сети для виртуалки)) с хоста или форвардится порт через локалхост

3. Запустить nginx на centralServer

4. Пробросить 80й порт на inetRouter2 8080

5. Дефолт в инет оставить через inetRouter

6. Реализовать проход на 80й порт без маскарадинга

# **Выполнение ДЗ**

Описание действий команд описаны в файлах Vagrantfile, centralRouter.sh, centralServer.sh, inetRouter.sh, inetRouter2.sh

Запускаем Vagrantfile
```
vagrant up
```

Заходим на centralRouter
```
vagrant ssh centralRouter
```

Пробуем подключиться по SSH к inetRouter, подключение зависает (нет доступа)
```
ssh vagrant@192.168.255.1
```

Пробуем подключиться по SSH к inetRouter через knock client (после ввода пароля - подключились)
```
knock 192.168.255.1 2222:tcp 3333:tcp 4444:tcp && ssh vagrant@192.168.255.1

	vagrant@192.168.255.1's password:
	Last login: Tue Nov 22 12:48:26 2022 from 192.168.255.2
	[vagrant@inetRouter ~]$
```

Для проверки вводим команду
```
hostname

	inetRouter
```

Выходим и заходим на inetRouter, смотрим правила iptables
```
exit
exit
vagrant ssh inetRouter
iptables -S

	-P INPUT DROP
	-P FORWARD ACCEPT
	-P OUTPUT ACCEPT
	-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
```

Cмотрим лог knockd
```
cat /var/log/knockd.log

	[2022-11-22 13:26] starting up, listening on eth1
	[2022-11-22 13:27] 192.168.255.2: opencloseSSH: Stage 1
	[2022-11-22 13:27] 192.168.255.2: opencloseSSH: Stage 2
	[2022-11-22 13:27] 192.168.255.2: opencloseSSH: Stage 3
	[2022-11-22 13:27] 192.168.255.2: opencloseSSH: OPEN SESAME
	[2022-11-22 13:27] opencloseSSH: running command: /sbin/iptables -A INPUT -s 192.168.255.2 -p tcp --dport ssh -j ACCEPT

	[2022-11-22 13:27] 192.168.255.2: opencloseSSH: command timeout
	[2022-11-22 13:27] opencloseSSH: running command: /sbin/iptables -D INPUT -s 192.168.255.2 -p tcp --dport ssh -j ACCEPT
```

Выходим и заходим на inetRouter2 и проверяем доступность вебсервера на centralServer
```
exit
vagrant ssh inetRouter2
curl 192.168.0.2

	...
	<h1>Welcome to CentOS</h1>
	...
```

Проверяем работу nginx с хостовой машины

![nginx_centralServer](https://github.com/andrey21x6/dz-otus/blob/main/firewalld_iptables3/scrin/nginx_centralServer.jpg)

Выходим и заходим на centralServer и делаем трассировку на ya.ru
```
exit
vagrant ssh centralServer
traceroute ya.ru
 
	 traceroute to ya.ru (87.250.250.242), 30 hops max, 60 byte packets
	 1  gateway (192.168.0.1)  0.540 ms  0.448 ms  0.599 ms
	 2  192.168.255.1 (192.168.255.1)  2.806 ms  2.760 ms  2.626 ms
	 3  * * *
	 4  * * *
	 5  * * *
	 6  87.226.151.112 (87.226.151.112)  7.588 ms  5.404 ms 87.226.151.94 (87.226.151.94)  5.702 ms
	 7  185.140.148.157 (185.140.148.157)  28.492 ms  28.343 ms *
	 8  188.254.94.106 (188.254.94.106)  28.364 ms  29.329 ms  28.810 ms
	 9  sas-32z3-ae2.yndx.net (87.250.239.185)  37.108 ms vla-32z3-ae3.yndx.net (93.158.160.155)  32.847 ms vla-32z1-ae2.yndx.net (93.158.172.19)  33.927 ms
	10  ya.ru (87.250.250.242)  32.913 ms * *
```

Благодарю за проверку!
