# otus-linux-day06
Работа с NFS

# **Prerequisite**
- Host OS: Windows 10.0.19043
- Guest OS: CentOS 7.8.2003
- VirtualBox: 6.1.34
- Vagrant: 2.2.19

# **Содержание ДЗ**

* Настройка сервера NFS
* Настройка клиента NFS

# **Выполнение**

### Настройка сервера NFS

Установка утилит для NFS
```
yum install nfs-utils
```

Включение и настройка файрвола для сервисов NFS
```
systemctl enable firewalld --now
firewall-cmd --add-service="nfs3" --add-service="rpc-bind" --add-service="mountd" --permanent
firewall-cmd --reload
```

Включение сервера NFS
```
systemctl enable nfs --now
```

Проверка прослушиваемых портов сервисами NFS
```
[root@nfss ~]# ss -tnplu | grep -e '2049\|20048\|111'
udp    UNCONN     0      0         *:20048                 *:*                   users:(("rpc.mountd",pid=3429,fd=7))
udp    UNCONN     0      0         *:111                   *:*                   users:(("rpcbind",pid=339,fd=6))
udp    UNCONN     0      0         *:2049                  *:*
udp    UNCONN     0      0      [::]:20048              [::]:*                   users:(("rpc.mountd",pid=3429,fd=9))
udp    UNCONN     0      0      [::]:111                [::]:*                   users:(("rpcbind",pid=339,fd=9))
udp    UNCONN     0      0      [::]:2049               [::]:*
tcp    LISTEN     0      64        *:2049                  *:*
tcp    LISTEN     0      128       *:111                   *:*                   users:(("rpcbind",pid=339,fd=8))
tcp    LISTEN     0      128       *:20048                 *:*                   users:(("rpc.mountd",pid=3429,fd=8))
tcp    LISTEN     0      64     [::]:2049               [::]:*
tcp    LISTEN     0      128    [::]:111                [::]:*                   users:(("rpcbind",pid=339,fd=11))
tcp    LISTEN     0      128    [::]:20048              [::]:*                   users:(("rpc.mountd",pid=3429,fd=10))
```

Настройка и публикация каталога, разрешения для клиента с адресом `192.168.50.11`
```
mkdir -p /srv/share/upload
chown -R nfsnobody:nfsnobody /srv/share
chmod 0777 /srv/share/upload
cat << EOF > /etc/exports
/srv/share 192.168.50.11/32(rw,sync,root_squash)
EOF
exportfs -r
```

Проверка экспорта каталога
```
[root@nfss ~]# exportfs -s
/srv/share  192.168.50.11/32(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
```

### Настройка клиента NFS

Установка утилит для NFS
```
yum install nfs-utils
```

Включение файрвола
```
systemctl enable firewalld --now
```

Настройка автоматического монтирования NFS-ресурса при первом обращении к нему,
используется 3 версия NFS через UDP
```
echo "192.168.50.10:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" >> /etc/fstab
```

Проверка монтирования
```
[vagrant@nfsc ~]$ mount | grep mnt
systemd-1 on /mnt type autofs (rw,relatime,fd=49,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=25331)
```

# **Результаты**

Выполняемые при конфигурировании сервера и клиента команды перенесены в bash-скрипты для автоматического конфигурирования машин при развёртывании.
Полученный в ходе работы `Vagrantfile` и внешние скрипты для shell provisioner помещены в публичный репозиторий:
- **GitHub** - https://github.com/jimidini77/otus-linux-day06
