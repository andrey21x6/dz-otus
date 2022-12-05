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

Добавим в Vagrantfile ещё одну машину "client2
```
config.vm.define "client2" do |client2|
    client2.vm.network "private_network", ip: "192.168.50.16", virtualbox__intnet: "dns"
    client2.vm.hostname = "client2"
end
```

Откроем файл playbook.yml для редактирования и в строку "hosts: client" добавим client2
```
- hosts: client, client2
```

Для запуска службы chronyd прописываем
```
- name: start chronyd
    service:
      name: chronyd
      state: restarted
      enabled: true
```












Нам нужно подкорректировать файл /etc/resolv.conf для DNS-серверов: на хосте ns01 указать nameserver 192.168.50.10, а на хосте ns02 — 192.168.50.11

В Ansible для этого можно воспользоваться шаблоном с Jinja

Изменим имя файла servers-resolv.conf на servers-resolv.conf.j2 и укажем там следующие условия
```
domain dns.lab
search dns.lab
#
# Если имя сервера ns02, то указываем nameserver 192.168.50.11
{% if ansible_hostname == 'ns02' %}
nameserver 192.168.50.11
{% endif %}
#
# Если имя сервера ns01, то указываем nameserver 192.168.50.10
{% if ansible_hostname == 'ns01' %}
nameserver 192.168.50.10
{% endif %}
```

После внесение измений в файл, внесём измения в ansible-playbook, используем вместо модуля copy модуль template
```
- name: copy resolv.conf to the servers
    template:
      src: servers-resolv.conf.j2
      dest: /etc/resolv.conf
      owner: root
      group: root
      mode: 0644
```

Первоначальные настройки закончали, теперь можно запустить стен
```
vagrant up
```

### Добавление имён в зону dns.lab

Проверим, что зона dns.lab уже существует на DNS-серверах, зайдём на ns01
```
vagrant ssh ns01
sudo -i
cat /etc/named.conf

    ...
    // lab's zone
    zone "dns.lab" {
        type master;
        allow-transfer { key "zonetransfer.key"; };
        file "/etc/named/named.dns.lab";
    };
    ...
```

Тоже проверим на ns01, для удобства откроем второй терминал и зайдём на ns02
```
vagrant ssh ns02
sudo -i
cat /etc/named.conf

    ...
    // lab's zone
    zone "dns.lab" {
        type slave;
        masters { 192.168.50.10; };
        file "/etc/named/named.dns.lab";
    };
    ...
```

Проверим на хосте ns01 файл /etc/named/named.dns.lab с настройкой зоны
```
cat /etc/named/named.dns.lab

    $TTL 3600
    $ORIGIN dns.lab.
    @               IN      SOA     ns01.dns.lab. root.dns.lab. (
                                2711201407 ; serial
                                3600       ; refresh (1 hour)
                                600        ; retry (10 minutes)
                                86400      ; expire (1 day)
                                600        ; minimum (10 minutes)
                            )

                    IN      NS      ns01.dns.lab.
                    IN      NS      ns02.dns.lab.

    ; DNS Servers
    ns01            IN      A       192.168.50.10
    ns02            IN      A       192.168.50.11
```

Именно в этот файл нам потребуется добавить имена

Допишем в конец файла cледующие строки и изменим число в строке "2711201407 ; serial", чтобы slave-сервер обновил свои файлы с зонами
```
nano /etc/named/named.dns.lab

    2711201407 заменим на 2711201408

    ;Web
    web1 IN A 192.168.50.15
    web2 IN A 192.168.50.16
```

После изменения выглядеть будет так
````
cat /etc/named/named.dns.lab

    $TTL 3600
    $ORIGIN dns.lab.
    @               IN      SOA     ns01.dns.lab. root.dns.lab. (
                                2711201408 ; serial
                                3600       ; refresh (1 hour)
                                600        ; retry (10 minutes)
                                86400      ; expire (1 day)
                                600        ; minimum (10 minutes)
                            )

                    IN      NS      ns01.dns.lab.
                    IN      NS      ns02.dns.lab.

    ; DNS Servers
    ns01            IN      A       192.168.50.10
    ns02            IN      A       192.168.50.11
    ;Web
    web1 IN A 192.168.50.15
    web2 IN A 192.168.50.16
```

Перезапустим службу named
```
systemctl restart named
```

Выполним проверку с клиента, для этого откроем третий терминал и зайдём на client
```
vagrant ssh client
dig @192.168.50.10 web1.dns.lab

    ; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.10 <<>> @192.168.50.10 web1.dns.lab
    ; (1 server found)
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 54641
    ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;web1.dns.lab.                  IN      A

    ;; ANSWER SECTION:
    web1.dns.lab.           3600    IN      A       192.168.50.15

    ;; AUTHORITY SECTION:
    dns.lab.                3600    IN      NS      ns02.dns.lab.
    dns.lab.                3600    IN      NS      ns01.dns.lab.

    ;; ADDITIONAL SECTION:
    ns01.dns.lab.           3600    IN      A       192.168.50.10
    ns02.dns.lab.           3600    IN      A       192.168.50.11

    ;; Query time: 1 msec
    ;; SERVER: 192.168.50.10#53(192.168.50.10)
    ;; WHEN: Sun Dec 04 09:46:15 UTC 2022
    ;; MSG SIZE  rcvd: 127
```

Выполним проверку для web2.dns.lab
```
dig @192.168.50.11 web2.dns.lab

    ; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.10 <<>> @192.168.50.11 web2.dns.lab
    ; (1 server found)
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 57801
    ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;web2.dns.lab.                  IN      A

    ;; ANSWER SECTION:
    web2.dns.lab.           3600    IN      A       192.168.50.16

    ;; AUTHORITY SECTION:
    dns.lab.                3600    IN      NS      ns02.dns.lab.
    dns.lab.                3600    IN      NS      ns01.dns.lab.

    ;; ADDITIONAL SECTION:
    ns01.dns.lab.           3600    IN      A       192.168.50.10
    ns02.dns.lab.           3600    IN      A       192.168.50.11

    ;; Query time: 1 msec
    ;; SERVER: 192.168.50.11#53(192.168.50.11)
    ;; WHEN: Sun Dec 04 09:48:24 UTC 2022
    ;; MSG SIZE  rcvd: 127
```

### Создание новой зоны и добавление в неё записей

Чтобы прописать на DNS-серверах новую зону нам потребуется:

На хосте ns01 добавить зону в файл /etc/named.conf
```
// lab's newdns zone
zone "newdns.lab" {
type master;
allow-transfer { key "zonetransfer.key"; };
allow-update { key "zonetransfer.key"; };
file "/etc/named/named.newdns.lab";
};
```

На хосте ns02 также добавить зону и указать с какого сервера запрашивать информацию об этой зоне
```
// lab's newdns zone
zone "newdns.lab" {
type slave;
masters { 192.168.50.10; };
file "/etc/named/named.newdns.lab";
};
```

На хосте ns01 создадим файл /etc/named/named.newdns.lab
```
nano /etc/named/named.newdns.lab

    $TTL 3600
    $ORIGIN newdns.lab.
    @ IN SOA ns01.dns.lab. root.dns.lab. (
    2711201007 ; serial
    3600 ; refresh (1 hour)
    600 ; retry (10 minutes)
    86400 ; expire (1 day)
    600 ; minimum (10 minutes)
    )
    IN NS ns01.dns.lab.
    IN NS ns02.dns.lab.
    ; DNS Servers
    ns01 IN A 192.168.50.10
    ns02 IN A 192.168.50.11
    ;WWW
    www IN A 192.168.50.15
    www IN A 192.168.50.16
```

Назначаем на файл владельца, группу и права
```
chown root:named /etc/named/named.newdns.lab && chmod 660 /etc/named/named.newdns.lab
ls -l /etc/named/named.newdns.lab

    -rw-rw----. 1 root named 343 Dec  4 09:54 /etc/named/named.newdns.lab
```

Изменим число в строке "2711201007 ; serial", чтобы slave-сервер обновил свои файлы с зонами
```
nano /etc/named/named.newdns.lab

    2711201007 заменим на 2711201008
```

Перезапустим службу named
```
systemctl restart named
```













### Настройка Split-DNS

У нас уже есть прописанные зоны dns.lab и newdns.lab, однако по заданию client1 должен видеть запись web1.dns.lab и не видеть запись web2.dns.lab

Client2 может видеть обе записи из домена dns.lab, но не должен видеть записи домена newdns.lab

Осуществить данные настройки нам поможет технология Split-DNS

Для настройки Split-DNS нужно создать дополнительный файл зоны dns.lab, в котором будет прописана только одна запись
```
nano /etc/named/named.dns.lab.client

$TTL 3600
$ORIGIN dns.lab.
@ IN SOA ns01.dns.lab. root.dns.lab. (
2711201407 ; serial
3600 ; refresh (1 hour)
600 ; retry (10 minutes)
86400 ; expire (1 day)
600 ; minimum (10 minutes)
)
IN NS ns01.dns.lab.
IN NS ns02.dns.lab.
; DNS Servers
ns01 IN A 192.168.50.10
ns02 IN A 192.168.50.11
;Web
web1 IN A 192.168.50.15
```

Назначаем на файл владельца, группу и права
```
chown root:named /etc/named/named.dns.lab.client && chmod 660 /etc/named/named.dns.lab.client
ls -l /etc/named/named.dns.lab.client

    -rw-rw----. 1 root named 318 Dec  4 10:35 /etc/named/named.dns.lab.client
```

Внести изменения в файл /etc/named.conf на хостах ns01 и ns02

Прежде всего нужно сделать access листы для хостов client и client2

Сначала сгенерируем ключи для хостов client и client2, для этого на хосте ns01 запустим утилиту tsig-keygen
```
tsig-keygen

    key "tsig-key" {
            algorithm hmac-sha256;
            secret "8uC5FRCAux6/vy3wHr/Os0ESsfbG8h6WdHCy3c7/YFE=";
    };

tsig-keygen

    key "tsig-key" {
            algorithm hmac-sha256;
            secret "kX+Fc7HXBNkyefDzbwPrsWyUG79MC60pmqSbGK2bF00=";
    };
```

После генерации, мы увидем ключ (secret) и алгоритм с помощью которого он был сгенерирован?, оба этих параметра нам потребуются в access листе

Всего нам потребуется 2 таких ключа, после их генерации добавим блок с access листами в конец файла /etc/named.conf
```
nano /etc/named.conf

    # Описание ключа для хоста client
    key "tsig-key" {
            algorithm hmac-sha256;
            secret "8uC5FRCAux6/vy3wHr/Os0ESsfbG8h6WdHCy3c7/YFE=";
    };

    # Описание ключа для хоста client2
    key "tsig-key" {
            algorithm hmac-sha256;
            secret "kX+Fc7HXBNkyefDzbwPrsWyUG79MC60pmqSbGK2bF00=";
    };

    # Описание access-листов
    acl client { !key client2-key; key client-key; 192.168.50.15; };
    acl client2 { !key client-key; key client2-key; 192.168.50.16; };
```

Технология Split-DNS реализуется с помощью описания представлений (view), для каждого отдельного acl

В каждое представление (view) добавляются только те зоны, которые разрешено видеть хостам, адреса которых указаны в access листе

Все ранее описанные зоны должны быть перенесены в модули view. Вне view зон быть недолжно, зона any должна всегда находиться в самом низу

После применения всех вышеуказанных правил на хосте ns01 мы получим следующее содержимое файла /etc/named.conf

Теперь можно внести правки в /etc/named.conf
```
nano /etc/named.conf


```













### ![#008000](https://placehold.co/15x15/008000/008000.png) ![#f03c15](https://placehold.co/15x15/f03c15/f03c15.png) ![#1589F0](https://placehold.co/15x15/1589F0/1589F0.png)
### Благодарю за проверку!
