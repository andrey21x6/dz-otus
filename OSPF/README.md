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

### Настройка OSPF между машинами на базе FRR (Quagga)

Первоначальные установки и настройки сделаем при запуске Vagrantfile с помощью ansible-playbook, в том числе сконфигурировали файлы frr.conf и daemons для каждого роутера.

Проверим доступность сетей с хоста router1
```
vagrant ssh router1
ping 192.168.30.1

    64 bytes from 192.168.30.1: icmp_seq=1 ttl=64 time=0.763 ms
    64 bytes from 192.168.30.1: icmp_seq=2 ttl=64 time=0.521 ms
    64 bytes from 192.168.30.1: icmp_seq=3 ttl=64 time=0.490 ms
```

Запустим трассировку до адреса 192.168.30.1
```
traceroute 192.168.30.1

    traceroute to 192.168.30.1 (192.168.30.1), 30 hops max, 60 byte packets
    1  192.168.30.1 (192.168.30.1)  1.042 ms  0.896 ms  0.843 ms
```

Попробуем отключить интерфейс enp0s9 и немного подождем и снова запустим трассировку до ip-адреса 192.168.30.1
```
sudo -i
ifconfig enp0s9 down
ip a | grep enp0s9

    4: enp0s9: <BROADCAST,MULTICAST> mtu 1500 qdisc fq_codel state DOWN group default qlen 1000
```

Запустим трассировку до адреса 192.168.30.1
```
traceroute 192.168.30.1

    traceroute to 192.168.30.1 (192.168.30.1), 30 hops max, 60 byte packets
    1  10.0.10.2 (10.0.10.2)  0.719 ms  0.629 ms  0.430 ms
    2  192.168.30.1 (192.168.30.1)  1.352 ms  1.299 ms  1.257 ms
```

Как мы видим, после отключения интерфейса сеть 192.168.30.0/24 нам остаётся доступна.

Также мы можем проверить из интерфейса vtysh какие маршруты мы видим на данный момент
```
vtysh

    Codes: K - kernel route, C - connected, S - static, R - RIP,
        O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
        T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
        f - OpenFabric,
        > - selected route, * - FIB route, q - queued, r - rejected, b - backup
        t - trapped, o - offload failure

    O   10.0.10.0/30 [110/100] is directly connected, enp0s8, weight 1, 00:14:02
    O>* 10.0.11.0/30 [110/200] via 10.0.10.2, enp0s8, weight 1, 00:03:56
    O>* 10.0.12.0/30 [110/300] via 10.0.10.2, enp0s8, weight 1, 00:03:56
    O   192.168.10.0/24 [110/100] is directly connected, enp0s10, weight 1, 00:14:32
    O>* 192.168.20.0/24 [110/200] via 10.0.10.2, enp0s8, weight 1, 00:13:57
    O>* 192.168.30.0/24 [110/300] via 10.0.10.2, enp0s8, weight 1, 00:03:56

exit
```

Включим интерфейс enp0s9
```
ifconfig enp0s9 up
ip a | grep enp0s9

    4: enp0s9: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
        inet 10.0.12.1/30 brd 10.0.12.3 scope global enp0s9
```

### Настройка ассиметричного роутинга

Для настройки ассиметричного роутинга нам необходимо выключить блокировку ассиметричной маршрутизации
```
sysctl net.ipv4.conf.all.rp_filter=0

    net.ipv4.conf.all.rp_filter = 0
```

Изменим «стоимость интерфейса» enp0s8 на router1
```
vtysh
conf t
int enp0s8
ip ospf cost 1000
exit
exit
show ip route ospf

    Codes: K - kernel route, C - connected, S - static, R - RIP,
        O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
        T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
        f - OpenFabric,
        > - selected route, * - FIB route, q - queued, r - rejected, b - backup
        t - trapped, o - offload failure

    O   10.0.10.0/30 [110/300] via 10.0.12.2, enp0s9, weight 1, 00:00:32
    O>* 10.0.11.0/30 [110/200] via 10.0.12.2, enp0s9, weight 1, 00:00:32
    O   10.0.12.0/30 [110/100] is directly connected, enp0s9, weight 1, 00:05:34
    O   192.168.10.0/24 [110/100] is directly connected, enp0s10, weight 1, 00:23:45
    O>* 192.168.20.0/24 [110/300] via 10.0.12.2, enp0s9, weight 1, 00:00:32
    O>* 192.168.30.0/24 [110/200] via 10.0.12.2, enp0s9, weight 1, 00:05:34
```

Подключимся к router2 во втором терминале
```
vagrant ssh router2
sudo -i
vtysh
show ip route ospf

    Codes: K - kernel route, C - connected, S - static, R - RIP,
        O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
        T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
        f - OpenFabric,
        > - selected route, * - FIB route, q - queued, r - rejected, b - backup
        t - trapped, o - offload failure

    O   10.0.10.0/30 [110/100] is directly connected, enp0s8, weight 1, 00:28:17
    O   10.0.11.0/30 [110/100] is directly connected, enp0s9, weight 1, 00:28:17
    O>* 10.0.12.0/30 [110/200] via 10.0.10.1, enp0s8, weight 1, 00:09:56
    *                        via 10.0.11.1, enp0s9, weight 1, 00:09:56
    O>* 192.168.10.0/24 [110/200] via 10.0.10.1, enp0s8, weight 1, 00:27:41
    O   192.168.20.0/24 [110/100] is directly connected, enp0s10, weight 1, 00:28:17
    O>* 192.168.30.0/24 [110/200] via 10.0.11.1, enp0s9, weight 1, 00:27:42
```

После внесения данных настроек, мы видим, что маршрут до сети 192.168.20.0/30 теперь пойдёт через router2, но обратный трафик от router2 пойдёт по другому пути

На router1 запускаем пинг от 192.168.10.1 до 192.168.20.1
```
ping -I 192.168.10.1 192.168.20.1
```

На router2 запускаем tcpdump, который будет смотреть трафик только на порту enp0s9
```
exit
tcpdump -i enp0s9

    tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
    listening on enp0s9, link-type EN10MB (Ethernet), capture size 262144 bytes
    09:12:49.811368 IP 192.168.10.1 > router2: ICMP echo request, id 3, seq 11, length 64
    09:12:50.962982 IP 192.168.10.1 > router2: ICMP echo request, id 3, seq 12, length 64
    09:12:51.987210 IP 192.168.10.1 > router2: ICMP echo request, id 3, seq 13, length 64
    ^C
    3 packets captured
    3 packets received by filter
    0 packets dropped by kernel
```

Видим что данный порт только получает ICMP-трафик с адреса 192.168.10.1

На router2 запускаем tcpdump, который будет смотреть трафик только на порту enp0s8
```
tcpdump -i enp0s8

    tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
    listening on enp0s8, link-type EN10MB (Ethernet), capture size 262144 bytes
    09:15:10.160750 IP router2 > 192.168.10.1: ICMP echo reply, id 4, seq 7, length 64
    09:15:11.162682 IP router2 > 192.168.10.1: ICMP echo reply, id 4, seq 8, length 64
    09:15:12.179233 IP router2 > 192.168.10.1: ICMP echo reply, id 4, seq 9, length 64
    ^C
    3 packets captured
    3 packets received by filter
    0 packets dropped by kernel
```

Видим что данный порт только отправляет ICMP-трафик на адрес 192.168.10.1. Таким образом мы видим ассиметричный роутинг

### Настройка симметичного роутинга

Так как у нас уже есть один «дорогой» интерфейс, нам потребуется добавить ещё один дорогой интерфейс, чтобы у нас перестала работать ассиметричная маршрутизация

Так как в прошлом задании мы заметили что router2 будет отправлять обратно трафик через порт enp0s8, мы также должны сделать его дорогим и далее проверить, что теперь используется симметричная маршрутизация

Поменяем стоимость интерфейса enp0s8 на router2
```
vtysh
conf t
int enp0s8
ip ospf cost 1000
exit
exit
show ip route ospf

    Codes: K - kernel route, C - connected, S - static, R - RIP,
        O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
        T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
        f - OpenFabric,
        > - selected route, * - FIB route, q - queued, r - rejected, b - backup
        t - trapped, o - offload failure

    O   10.0.10.0/30 [110/1000] is directly connected, enp0s8, weight 1, 00:00:25
    O   10.0.11.0/30 [110/100] is directly connected, enp0s9, weight 1, 03:14:46
    O>* 10.0.12.0/30 [110/200] via 10.0.11.1, enp0s9, weight 1, 00:00:25
    O>* 192.168.10.0/24 [110/300] via 10.0.11.1, enp0s9, weight 1, 00:00:25
    O   192.168.20.0/24 [110/100] is directly connected, enp0s10, weight 1, 03:14:46
    O>* 192.168.30.0/24 [110/200] via 10.0.11.1, enp0s9, weight 1, 03:14:11

exit
```

На router1 запускаем пинг от 192.168.10.1 до 192.168.20.1
```
ping -I 192.168.10.1 192.168.20.1
```


На router2 запускаем tcpdump, который будет смотреть трафик только на порту enp0s9
```
tcpdump -i enp0s9

    tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
    listening on enp0s9, link-type EN10MB (Ethernet), capture size 262144 bytes
    11:57:41.999613 IP 192.168.10.1 > router2: ICMP echo request, id 5, seq 110, length 64
    11:57:41.999670 IP router2 > 192.168.10.1: ICMP echo reply, id 5, seq 110, length 64
    11:57:43.000787 IP 192.168.10.1 > router2: ICMP echo request, id 5, seq 111, length 64
    11:57:43.000839 IP router2 > 192.168.10.1: ICMP echo reply, id 5, seq 111, length 64
    ^C
    4 packets captured
    4 packets received by filter
    0 packets dropped by kernel
```

Теперь мы видим, что трафик между роутерами ходит симметрично

![#f03c15](https://placehold.co/15x15/f03c15/f03c15.png) ### Благодарю за проверку!
