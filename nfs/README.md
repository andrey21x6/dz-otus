# NFS

# **Prerequisite**
- Host OS: Ubuntu Desktop 20.04.4
- Guest OS: Cent OS 8.4
- VirtualBox: 6.1.36
- Vagrant: 2.3.0-1

# **Содержание ДЗ**

* Настройка сервера NFS
* Настройка клиента NFS

# **Выполнение**

Настройка репозитория

```
sudo sed -i -e "s|mirrorlist=|#mirrorlist=|g" /etc/yum.repos.d/CentOS-*
sudo sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g" /etc/yum.repos.d/CentOS-*
```

Настройка кодировки

```
localectl set-locale LANG=en_US.UTF-8
sudo dnf install langpacks-en glibc-all-langpacks -y
```

Установка утилит для NFS
```
yum install nfs-utils
```

Создаём папку
```
sudo mkdir /var/nfs_share
```

Прописываем в файле exports
```
sudo vi /etc/exports
```
/var/nfs_share/ *(rw,all_squash)

Перезапускаем nfs server
```
sudo systemctl restart nfs-server
```

редактируем файл для работы в версии 3
```
sudo vi /etc/nfs.conf
```
vers3=y
vers4=n
vers4.0=n
vers4.1=n
vers4.2=n

Перезапускаем nfs server
```
sudo systemctl restart nfs-server
```

Включение и настройка файрвола для сервисов NFS
```
sudo systemctl start firewalld
sudo firewall-cmd --zone=public --add-port=111/udp
sudo firewall-cmd --zone=public --add-port=111/tcp
sudo firewall-cmd --zone=public --add-port=2049/udp
sudo firewall-cmd --zone=public --add-port=2049/tcp
sudo firewall-cmd --zone=public --add-port=4045/udp
sudo firewall-cmd --zone=public --add-port=4045/tcp

sudo firewall-cmd --reload
```

Включение сервера NFS
```
systemctl enable nfs --now
```

Проверка прослушиваемых портов сервисами NFS
```
sudo ss -tulpn

udp      UNCONN    0         0                  0.0.0.0:20048            0.0.0.0:*        users:(("rpc.mountd",pid=23585,fd=7))
udp      UNCONN    0         0                  0.0.0.0:111              0.0.0.0:*        users:(("rpcbind",pid=501,fd=5),("systemd",pid=1,fd=90))
udp      UNCONN    0         0                  0.0.0.0:52365            0.0.0.0:*        users:(("rpc.statd",pid=23378,fd=9))
udp      UNCONN    0         0                127.0.0.1:659              0.0.0.0:*        users:(("rpc.statd",pid=23378,fd=7))
udp      UNCONN    0         0                  0.0.0.0:47341            0.0.0.0:*
udp      UNCONN    0         0                127.0.0.1:323              0.0.0.0:*        users:(("chronyd",pid=566,fd=5))
udp      UNCONN    0         0                     [::]:54262               [::]:*        users:(("rpc.statd",pid=23378,fd=11))
udp      UNCONN    0         0                     [::]:54809               [::]:*
udp      UNCONN    0         0                     [::]:20048               [::]:*        users:(("rpc.mountd",pid=23585,fd=9))
udp      UNCONN    0         0                     [::]:111                 [::]:*        users:(("rpcbind",pid=501,fd=7),("systemd",pid=1,fd=92))
udp      UNCONN    0         0                    [::1]:323                 [::]:*        users:(("chronyd",pid=566,fd=6))
tcp      LISTEN    0         64                 0.0.0.0:2049             0.0.0.0:*
tcp      LISTEN    0         128                0.0.0.0:111              0.0.0.0:*        users:(("rpcbind",pid=501,fd=4),("systemd",pid=1,fd=89))
tcp      LISTEN    0         128                0.0.0.0:20048            0.0.0.0:*        users:(("rpc.mountd",pid=23585,fd=8))
tcp      LISTEN    0         64                 0.0.0.0:34229            0.0.0.0:*
tcp      LISTEN    0         128                0.0.0.0:22               0.0.0.0:*        users:(("sshd",pid=696,fd=5))
tcp      LISTEN    0         128                0.0.0.0:45243            0.0.0.0:*        users:(("rpc.statd",pid=23378,fd=10))
tcp      LISTEN    0         128                   [::]:43773               [::]:*        users:(("rpc.statd",pid=23378,fd=12))
tcp      LISTEN    0         64                    [::]:2049                [::]:*
tcp      LISTEN    0         128                   [::]:111                 [::]:*        users:(("rpcbind",pid=501,fd=6),("systemd",pid=1,fd=91))
tcp      LISTEN    0         128                   [::]:20048               [::]:*        users:(("rpc.mountd",pid=23585,fd=10))
tcp      LISTEN    0         128                   [::]:22                  [::]:*        users:(("sshd",pid=696,fd=7))
tcp      LISTEN    0         64                    [::]:46363               [::]:*
```

### Настройка клиента NFS

Настройка репозитория

```
sudo sed -i -e "s|mirrorlist=|#mirrorlist=|g" /etc/yum.repos.d/CentOS-*
sudo sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g" /etc/yum.repos.d/CentOS-*
```

Настройка кодировки

```
localectl set-locale LANG=en_US.UTF-8
sudo dnf install langpacks-en glibc-all-langpacks -y
```

Установка утилит для NFS
```
yum install nfs-utils
```

Создаём папку и назначаем права
```
sudo mkdir /mnt/nfs_share
mkdir /mnt/nfs_share/uploads
chmod o+w /mnt/nfs_share/uploads
```

Настройка автоматического монтирования NFS-ресурса при первом обращении к нему,
используется 3 версия NFS через UDP
```
echo "192.168.56.11:/var/nfs_share /mnt/nfs_share nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" >> /etc/fstab
```

Проверка монтирования
```
[vagrant@nfsc ~]$ mount | grep mnt
systemd-1 on /mnt type autofs (rw,relatime,fd=49,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=25331)
```

# **Результаты**

Полученный в ходе работы `Vagrantfile` и внешние скрипты для shell provisioner помещены в публичный репозиторий:
- **GitHub** - https://github.com/andrey21x6/dz-otus/tree/main/nfs
