# Управление пакетами

# **Prerequisite**
- Host OS: Ubuntu Desktop 20.04.4
- Guest OS: Cent OS 7.5.1804
- VirtualBox: 6.1.36
- Vagrant: 2.3.0-1

# **Содержание ДЗ**

* создать свой RPM (можно взять свое приложение, либо собрать к примеру апач с определенными опциями)
* создать свой репо и разместить там свой RPM
* реализовать это все либо в вагранте, либо развернуть у себя через nginx и дать ссылку на репо
* реализовать дополнительно пакет через docker

# **Выполнение**


Установка пакетов
```
yum install rpmdevtools rpm-build -y
rpmdev-setuptree
```

Устанавливаем wget
```
yum install wget -y
```

Скачиваем пакет с исходниками nginx
```
wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.22.0-1.el7.ngx.src.rpm
```

Распаковываем архив с исходниками
```
rpm -i nginx-1.22.0-1.el7.ngx.src.rpm
```

Переходим в директорию rpmbuild
```
cd /root/rpmbuild
```

Выполняем команду собрать RPM
```
rpmbuild -bb SPECS/nginx.spec
```

Вывод
```
error: Failed build dependencies:
        openssl-devel >= 1.0.2 is needed by nginx-1.22.0-1.el7.ngx.src.rpm
        zlib-devel is needed by nginx-1.22.0-1.el7.ngx.src.rpm
        pcre2-devel is needed by nginx-1.22.0-1.el7.ngx.src.rpm
```

Устанавливаем недостающее
```
yum install openssl-devel zlib-devel pcre2-devel -y
```

Выполняем команду собрать RPM
```
rpmbuild -bb SPECS/nginx.spec
```

Посмотрим, что получилось
```
find RPMS

RPMS
RPMS/x86_64
RPMS/x86_64/nginx-1.22.0-1.el7.ngx.x86_64.rpm
RPMS/x86_64/nginx-debuginfo-1.22.0-1.el7.ngx.x86_64.rpm
```

### Создаём репозиторий

Установка

```
sudo yum install nginx createrepo -y
```

Создаём каталог

```
sudo mkdir -p /repos/CentOS/7/
```

Настройка репозитория

```
sudo createrepo /repos/CentOS/7/

Spawning worker 0 with 1 pkgs
Workers Finished
Saving Primary metadata
Saving file lists metadata
Saving other metadata
Generating sqlite DBs
Sqlite DBs complete
```

Проверяем, что получилось

```
ls -la /repos/CentOS/7/repodata/

total 32
drwxr-xr-x. 2 root root 4096 авг 27 10:43 .
drwxr-xr-x. 3 root root   60 авг 27 10:43 ..
-rw-r--r--. 1 root root  342 авг 27 10:43 1d8b3d9e51f42341b6dbe810f50726227040c205e3914130637a2ae6f6b9be8d-filelists.xml.gz
-rw-r--r--. 1 root root 1705 авг 27 10:43 248766cc70446a2161667e22174ffeb223136d3cf27919d3e41ea76e38af634c-primary.sqlite.bz2
-rw-r--r--. 1 root root 1173 авг 27 10:43 30415e7a2efba6ed2066c223eeecc49a3391bbe4e2abc9cf19e6363026923128-other.sqlite.bz2
-rw-r--r--. 1 root root  832 авг 27 10:43 56b36c1dd198ae04334450d61e80b513471cac656fed7c5b4e8da0c291704828-filelists.sqlite.bz2
-rw-r--r--. 1 root root  702 авг 27 10:43 a83ef2d4a25480a894d91d28cd3010a07b63a7d0946f25ea8d2146e9ba89e5d5-primary.xml.gz
-rw-r--r--. 1 root root  575 авг 27 10:43 e51ea145536efed716864edbd5538ec2b71c7efa10e3ab382a3eed51863aeb05-other.xml.gz
-rw-r--r--. 1 root root 2965 авг 27 10:43 repomd.xml
```

Создаём файл и вписываем туда

```
sudo vi /etc/yum.repos.d/local.repo

[local]
name=Local
baseurl=file:///repos/CentOS/7/
enabled=1
gpgcheck=0
```

Настройка репозитория

```
sudo yum repolist enabled

Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirrors.datahouse.ru
 * extras: mirrors.datahouse.ru
 * updates: mirror.sale-dedic.com
local                                                                                                                                             | 2.9 kB  00:00:00
local/primary_db                                                                                                                                  | 1.7 kB  00:00:00
repo id                                                                         repo name                                                                          status
base/7/x86_64                                                                   CentOS-7 - Base                                                                    10 072
extras/7/x86_64                                                                 CentOS-7 - Extras                                                                     512
local                                                                           Local                                                                                   1
updates/7/x86_64                                                                CentOS-7 - Updates                                                                  4 135
repolist: 14 720
```

```
sudo yum reinstall
Loaded plugins: fastestmirror
Error: Need to pass a list of pkgs to reinstall
 Mini usage:

reinstall PACKAGE...

reinstall a package
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

Полученный в ходе работы `Vagrantfile` помещен в публичный репозиторий:
- **GitHub** - https://github.com/andrey21x6/dz-otus/tree/main/nfs