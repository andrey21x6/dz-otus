# LDAP. Централизованная авторизация и аутентификация (Ansible)

# **Prerequisite**

- Host OS: Ubuntu Desktop 20.04.5
- Guest OS: CentOS 8.3.2011
- VirtualBox: 6.1.40
- Vagrant: 2.3.2

# **Содержание ДЗ**

1. Установить FreeIPA;

2. Написать Ansible playbook для конфигурации клиента;

3. ** Настроить аутентификацию по SSH-ключам;

4. ** Firewall должен быть включен на сервере и на клиенте.

# **Выполнение ДЗ**

Запустим команду для развёртывания стенда, с помощью которого установяться пакеты @idm:DL1 ipa-server ipa-server-dns
```
vagrant up
```

Зайдём на server FreeIPA
```
vagrant ssh server
```

Выполним команду для запуска предварительных интерактивных настроек для наглядности
```
sudo -i
ipa-server-install --mkhomedir

	Do you want to configure integrated DNS (BIND)? [no]: (Вы хотите настроить интегрированный DNS)
yes

	Server host name [server.freeipa.loc]: (Имя хоста сервера)
"Enter"

	Please confirm the domain name [freeipa.loc]: (Пожалуйста, подтвердите доменное имя)
"Enter"

	Please provide a realm name [FREEIPA.LOC]: (Please provide a realm name [FREEIPA.LOC]:)
"Enter"

	Directory Manager password: (Пароль диспетчера каталогов)
12345678

	Password (confirm):
12345678

	IPA admin password: (пароль администратора сервера IPA)
12345678

	Password (confirm):
12345678

	Please provide the IP address to be used for this host name: (Укажите IP-адрес, который будет использоваться для этого имени хоста)
192.168.10.10

	Enter an additional IP address, or press Enter to skip: (Введите дополнительный IP-адрес или нажмите Enter, чтобы пропустить)
"Enter"

	Do you want to configure DNS forwarders? [yes]: (Вы хотите настроить серверы пересылки DNS)
yes

	Following DNS servers are configured in /etc/resolv.conf: 10.0.2.3. Do you want to configure these servers as DNS forwarders? [yes]:
	(В файле /etc/resolv.conf настроены следующие DNS-серверы: 10.0.2.3. Вы хотите настроить эти серверы как серверы пересылки DNS)
yes

	Enter an IP address for a DNS forwarder, or press Enter to skip: 
	(Введите IP-адрес сервера пересылки DNS или нажмите Enter, чтобы пропустить)
"Enter"

	Do you want to search for missing reverse zones? [yes]: (Вы хотите искать недостающие обратные зоны)
yes

	Do you want to create reverse zone for IP 192.168.10.10 [yes]: (Вы хотите создать обратную зону для IP 192.168.10.10)
yes

	Please specify the reverse zone name [10.168.192.in-addr.arpa.]: (Укажите имя обратной зоны)
"Enter"

	NetBIOS domain name [FREEIPA]: (Доменное имя NetBIOS)
FREEIPA

	Do you want to configure chrony with NTP server or pool address? [no]: (Вы хотите настроить chrony с адресом NTP-сервера или пула)
yes

	Enter NTP source server addresses separated by comma, or press Enter to skip: 
	(Введите адреса исходного NTP-сервера через запятую или нажмите Enter, чтобы пропустить)
ntp7.ntp-servers.net,ntp6.ntp-servers.net,ntp5.ntp-servers.net

	Enter a NTP source pool address, or press Enter to skip: (Введите адрес исходного пула NTP или нажмите Enter, чтобы пропустить)
"Enter"

	Continue to configure the system with these values? [no]: (Продолжать настраивать систему с этими значениями?)
yes
```

Проверим работу сервера FreeIPA
```
kinit admin
	Password for admin@FREEIPA.LOC:
12345678

klist
	Ticket cache: KCM:0
	Default principal: admin@FREEIPA.LOC

	Valid starting       Expires              Service principal
	17.12.2022 08:00:59  18.12.2022 08:00:36  krbtgt/FREEIPA.LOC@FREEIPA.LOC
	
ipa user-find admin
	---------------------------------------
	установлено соответствие 1 пользователя
	---------------------------------------
	  Имя учётной записи пользователя: admin
	  Фамилия: Administrator
	  Домашний каталог: /home/admin
	  Оболочка входа: /bin/bash
	  Псевдоним учётной записи: admin@FREEIPA.LOC, root@FREEIPA.LOC
	  UID: 32000000
	  ID группы: 32000000
	  Учётная запись отключена: False
	---------------------------------
	Количество возвращённых записей 1
	---------------------------------
```

Для проверки доступности веб интерфейса FreeIPA сервера c хостовой машины, в Vagrantfile прописал public_network
```
server.vm.network "public_network", ip: "192.168.100.210", bridge: "enp3s0"
```

На хостовой машине в файле hosts нужно прописать
```
192.168.100.210   server.freeipa.loc
```

С хостовой машины можно в браузере набрать
```
192.168.100.210
```

И он перебрасывает на адрес: https://server.freeipa.loc/ipa/ui по которому открывается веб интерфейса FreeIPA сервера

![FreeIPA_web_1](https://github.com/andrey21x6/dz-otus/blob/main/LDAP/scrin/FreeIPA_web_1.jpg)

Авторизуемся
```
admin
12345678
```

![FreeIPA_web_2](https://github.com/andrey21x6/dz-otus/blob/main/LDAP/scrin/FreeIPA_web_2.jpg)

Теперь можно запустить ansible-playbook для конфигурации клиента
```

``` 
















### ![#008000](https://placehold.co/15x15/008000/008000.png) ![#f03c15](https://placehold.co/15x15/f03c15/f03c15.png) ![#1589F0](https://placehold.co/15x15/1589F0/1589F0.png)
### Благодарю за проверку!
