# Статическая и динамическая маршрутизация, OSPF 

# **Prerequisite**

- Host OS: Ubuntu Desktop 20.04.5
- Guest OS: Ubuntu 20.04.5 LTS
- VirtualBox: 6.1.40
- Vagrant: 2.3.2

# **Содержание ДЗ**

1. Поднять три виртуалки

2. Объединить их разными vlan

* Поднять OSPF между машинами на базе Quagga;

* Изобразить ассиметричный роутинг;

* Сделать один из линков "дорогим", но что бы при этом роутинг был симметричным.


# **Выполнение ДЗ**

Первоначальные установки и настройки сделаем при запуске Vagrantfile с помощью ansible-playbook. 
Для настройки OSPF нам потребуется файл /etc/frr/frr.conf, который будет содержать в себе информацию о требуемых интерфейсах и OSPF. 
Разберем пример создания файла на хосте router1.

Для начала нам необходимо узнать имена интерфейсов и их адреса
```
sudo -i
ip a | grep "inet "

    inet 127.0.0.1/8 scope host lo
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic enp0s3
    inet 10.0.10.1/30 brd 10.0.10.3 scope global enp0s8
    inet 10.0.12.1/30 brd 10.0.12.3 scope global enp0s9
    inet 192.168.10.1/24 brd 192.168.10.255 scope global enp0s10
    inet 192.168.50.10/24 brd 192.168.50.255 scope global enp0s16
```

Зайдём в интерфейс FRR и посмотрим информацию об интерфейсах
```
vtysh
show interface brief

    Interface       Status  VRF             Addresses
    ---------       ------  ---             ---------
    enp0s3          up      default         10.0.2.15/24
    enp0s8          up      default         10.0.10.1/30
    enp0s9          up      default         10.0.12.1/30
    enp0s10         up      default         192.168.10.1/24
    enp0s16         up      default         192.168.50.10/24
    lo              up      default

exit
```

Исходя из схемы мы понимаем, что для настройки OSPF нам достаточно описать интерфейсы enp0s8, enp0s9, enp0s10

Открываем файл /etc/frr/frr.conf и вносим в него следующую информацию
```
!Указание версии FRR
frr version 8.1
frr defaults traditional
!
!Указываем имя машины
hostname router1
log syslog informational
no ipv6 forwarding
service integrated-vtysh-config
!
!Добавляем информацию об интерфейсе enp0s8
interface enp0s8
!
!Указываем имя интерфейса
description r1-r2
!
!Указываем ip-aдрес и маску (эту информацию мы получили в прошлом шаге)
ip address 10.0.10.1/30
!
!Указываем параметр игнорирования MTU
ip ospf mtu-ignore
!
!Если потребуется, можно указать «стоимость» интерфейса
!ip ospf cost 1000
!
!Указываем параметры hello-интервала для OSPF пакетов
ip ospf hello-interval 10
!
!Указываем параметры dead-интервала для OSPF пакетов
!Должно быть кратно предыдущему значению
ip ospf dead-interval 30
!
interface enp0s9
description r1-r3
ip address 10.0.12.1/30
ip ospf mtu-ignore
!ip ospf cost 45
ip ospf hello-interval 10
ip ospf dead-interval 30
!
interface enp0s10
description net_router1
ip address 192.168.10.1/24
ip ospf mtu-ignore
!ip ospf cost 45
ip ospf hello-interval 10
ip ospf dead-interval 30
!
!Начало настройки OSPF
router ospf
!
!Указываем router-id
router-id 1.1.1.1
!
!Указываем сети, которые хотим анонсировать соседним роутерам
network 10.0.10.0/30 area 0
network 10.0.12.0/30 area 0
network 192.168.10.0/24 area 0
!
!Указываем адреса соседних роутеров
neighbor 10.0.10.2
neighbor 10.0.12.2
!
!Указываем адрес log-файла
log file /var/log/frr/frr.log
default-information originate always
```

На хостах router2 и router3 также нужно настроить конфигруационные файлы, предварительно поменяв ip -адреса интерфейсов












Благодарю за проверку!
