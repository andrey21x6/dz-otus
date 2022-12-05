# DNS- настройка и обслуживание  (Ansible)

# **Prerequisite**

- Host OS: Ubuntu Desktop 20.04.5
- Guest OS: CentOS 7.8.2003
- VirtualBox: 6.1.40
- Vagrant: 2.3.2
- Ansible [core 2.13.6]
- Python version = 3.8.10
- jinja version = 3.1.2

# **Содержание ДЗ**

- Добавить еще один сервер client2

- Завести в зоне dns.lab имена:

    web1 - смотрит на клиент1

    web2 смотрит на клиент2

- Завести еще одну зону newdns.lab

- Завести в ней запись www - смотрит на обоих клиентов

- Настроить split-dns:

    клиент1 - видит обе зоны, но в зоне dns.lab только web1

    клиент2 видит только dns.lab

Дополнительное задание

* настроить все без выключения selinux

# **Выполнение ДЗ**

Команды и пояснения прописаны в файлах Vagrantfile и playbook.yml


Запустим стенд
```
vagrant up
```

Выполним проверки на client1
```
vagrant ssh client1
dig @192.168.50.10 web1.dns.lab

    ; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.10 <<>> @192.168.50.10 web1.dns.lab
    ; (1 server found)
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 2034
    ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;web1.dns.lab.                  IN      A

    ;; ANSWER SECTION:
    web1.dns.lab.           3600    IN      A       192.168.50.15

    ;; AUTHORITY SECTION:
    dns.lab.                3600    IN      NS      ns01.dns.lab.
    dns.lab.                3600    IN      NS      ns02.dns.lab.

    ;; ADDITIONAL SECTION:
    ns01.dns.lab.           3600    IN      A       192.168.50.10
    ns02.dns.lab.           3600    IN      A       192.168.50.11

    ;; Query time: 0 msec
    ;; SERVER: 192.168.50.10#53(192.168.50.10)
    ;; WHEN: Mon Dec 05 11:14:35 UTC 2022
    ;; MSG SIZE  rcvd: 127

dig @192.168.50.11 web1.dns.lab

    ; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.10 <<>> @192.168.50.11 web1.dns.lab
    ; (1 server found)
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 7687
    ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;web1.dns.lab.                  IN      A

    ;; ANSWER SECTION:
    web1.dns.lab.           3600    IN      A       192.168.50.15

    ;; AUTHORITY SECTION:
    dns.lab.                3600    IN      NS      ns01.dns.lab.
    dns.lab.                3600    IN      NS      ns02.dns.lab.

    ;; ADDITIONAL SECTION:
    ns01.dns.lab.           3600    IN      A       192.168.50.10
    ns02.dns.lab.           3600    IN      A       192.168.50.11

    ;; Query time: 0 msec
    ;; SERVER: 192.168.50.11#53(192.168.50.11)
    ;; WHEN: Mon Dec 05 11:18:44 UTC 2022
    ;; MSG SIZE  rcvd: 127

dig @192.168.50.10 web2.dns.lab

    ; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.10 <<>> @192.168.50.10 web2.dns.lab
    ; (1 server found)
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 90
    ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;web2.dns.lab.                  IN      A

    ;; AUTHORITY SECTION:
    dns.lab.                600     IN      SOA     ns01.dns.lab. root.dns.lab. 2711201408 3600 600 86400 600

    ;; Query time: 0 msec
    ;; SERVER: 192.168.50.10#53(192.168.50.10)
    ;; WHEN: Mon Dec 05 11:20:10 UTC 2022
    ;; MSG SIZE  rcvd: 87

dig @192.168.50.11 web2.dns.lab

    ; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.10 <<>> @192.168.50.11 web2.dns.lab
    ; (1 server found)
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 53406
    ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;web2.dns.lab.                  IN      A

    ;; AUTHORITY SECTION:
    dns.lab.                600     IN      SOA     ns01.dns.lab. root.dns.lab. 2711201408 3600 600 86400 600

    ;; Query time: 0 msec
    ;; SERVER: 192.168.50.11#53(192.168.50.11)
    ;; WHEN: Mon Dec 05 11:20:14 UTC 2022
    ;; MSG SIZE  rcvd: 87
```

Согласно заданию, c client1 доступен web1.dns.lab и не доступен web2.dns.lab

Сделаем пинг
```
ping www.newdns.lab

    PING www.newdns.lab (192.168.50.15) 56(84) bytes of data.
    64 bytes from client1 (192.168.50.15): icmp_seq=1 ttl=64 time=0.019 ms
    64 bytes from client1 (192.168.50.15): icmp_seq=2 ttl=64 time=0.044 ms
    ^C
    --- www.newdns.lab ping statistics ---
    2 packets transmitted, 2 received, 0% packet loss, time 1005ms
    rtt min/avg/max/mdev = 0.019/0.031/0.044/0.013 ms

ping web1.dns.lab

    PING web1.dns.lab (192.168.50.15) 56(84) bytes of data.
    64 bytes from client1 (192.168.50.15): icmp_seq=1 ttl=64 time=0.024 ms
    64 bytes from client1 (192.168.50.15): icmp_seq=2 ttl=64 time=0.045 ms
    ^C
    --- web1.dns.lab ping statistics ---
    2 packets transmitted, 2 received, 0% packet loss, time 1002ms
    rtt min/avg/max/mdev = 0.024/0.034/0.045/0.012 ms

ping: web2.dns.lab: Name or service not known

    ping: web2.dns.lab: Name or service not known

ping newdns.lab

    PING newdns.lab (192.168.50.10) 56(84) bytes of data.
    64 bytes from 192.168.50.10 (192.168.50.10): icmp_seq=1 ttl=64 time=0.334 ms
    64 bytes from 192.168.50.10 (192.168.50.10): icmp_seq=2 ttl=64 time=0.538 ms
    ^C
    --- newdns.lab ping statistics ---
    2 packets transmitted, 2 received, 0% packet loss, time 1001ms
    rtt min/avg/max/mdev = 0.334/0.436/0.538/0.102 ms
```

Согласно заданию, c client1 видит обе зоны, но в зоне dns.lab только web1

Выполним проверки на client2
```
exit
vagrant ssh client2
ping www.newdns.lab

    ping: www.newdns.lab: Name or service not known

dig @192.168.50.10 www.newdns.lab

    ; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.10 <<>> @192.168.50.10 www.newdns.lab
    ; (1 server found)
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 4905
    ;; flags: qr rd ra ad; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;www.newdns.lab.                        IN      A

    ;; AUTHORITY SECTION:
    .                       10441   IN      SOA     a.root-servers.net. nstld.verisign-grs.com. 2022120500 1800 900 604800 86400

    ;; Query time: 0 msec
    ;; SERVER: 192.168.50.10#53(192.168.50.10)
    ;; WHEN: Mon Dec 05 11:34:37 UTC 2022
    ;; MSG SIZE  rcvd: 118

ping web1.dns.lab

    PING web1.dns.lab (192.168.50.15) 56(84) bytes of data.
    64 bytes from 192.168.50.15 (192.168.50.15): icmp_seq=1 ttl=64 time=1.46 ms
    64 bytes from 192.168.50.15 (192.168.50.15): icmp_seq=2 ttl=64 time=0.555 ms
    ^C
    --- web1.dns.lab ping statistics ---
    2 packets transmitted, 2 received, 0% packet loss, time 1004ms
    rtt min/avg/max/mdev = 0.555/1.009/1.464/0.455 ms

ping web2.dns.lab

    PING web2.dns.lab (192.168.50.16) 56(84) bytes of data.
    64 bytes from client2 (192.168.50.16): icmp_seq=1 ttl=64 time=0.030 ms
    64 bytes from client2 (192.168.50.16): icmp_seq=2 ttl=64 time=0.048 ms
    ^C
    --- web2.dns.lab ping statistics ---
    2 packets transmitted, 2 received, 0% packet loss, time 1010ms
    rtt min/avg/max/mdev = 0.030/0.039/0.048/0.009 ms

dig @192.168.50.11 web1.dns.lab

    ; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.10 <<>> @192.168.50.11 web1.dns.lab
    ; (1 server found)
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 44461
    ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;web1.dns.lab.                  IN      A

    ;; ANSWER SECTION:
    web1.dns.lab.           3600    IN      A       192.168.50.15

    ;; AUTHORITY SECTION:
    dns.lab.                3600    IN      NS      ns01.dns.lab.
    dns.lab.                3600    IN      NS      ns02.dns.lab.

    ;; ADDITIONAL SECTION:
    ns01.dns.lab.           3600    IN      A       192.168.50.10
    ns02.dns.lab.           3600    IN      A       192.168.50.11

    ;; Query time: 1 msec
    ;; SERVER: 192.168.50.11#53(192.168.50.11)
    ;; WHEN: Mon Dec 05 11:33:16 UTC 2022
    ;; MSG SIZE  rcvd: 127

dig @192.168.50.11 web2.dns.lab

    ; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.10 <<>> @192.168.50.11 web2.dns.lab
    ; (1 server found)
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 63240
    ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;web2.dns.lab.                  IN      A

    ;; ANSWER SECTION:
    web2.dns.lab.           3600    IN      A       192.168.50.16

    ;; AUTHORITY SECTION:
    dns.lab.                3600    IN      NS      ns01.dns.lab.
    dns.lab.                3600    IN      NS      ns02.dns.lab.

    ;; ADDITIONAL SECTION:
    ns01.dns.lab.           3600    IN      A       192.168.50.10
    ns02.dns.lab.           3600    IN      A       192.168.50.11

    ;; Query time: 0 msec
    ;; SERVER: 192.168.50.11#53(192.168.50.11)
    ;; WHEN: Mon Dec 05 11:33:22 UTC 2022
    ;; MSG SIZE  rcvd: 127
```

Согласно заданию, c client2 видит только dns.lab, то есть newdns.lab не видит

### ![#008000](https://placehold.co/15x15/008000/008000.png) ![#f03c15](https://placehold.co/15x15/f03c15/f03c15.png) ![#1589F0](https://placehold.co/15x15/1589F0/1589F0.png)
### Благодарю за проверку!
