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

Полученный в ходе работы `Vagrantfile` помещен в публичный репозиторий:
- **GitHub** - https://github.com/andrey21x6/dz-otus/tree/main/nfs
