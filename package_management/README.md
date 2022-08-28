# Управление пакетами

# **Prerequisite**
- Host OS: Ubuntu Desktop 20.04.4
- Guest OS: Cent OS 7.5.1804
- VirtualBox: 6.1.36
- Vagrant: 2.3.0-1
- Виртульный сервер на CentOS7 для развёртывания своего репозитория

# **Содержание ДЗ**

* создать свой RPM (можно взять свое приложение, либо собрать к примеру апач с определенными опциями)
* создать свой репо и разместить там свой RPM
* реализовать это все либо в вагранте, либо развернуть у себя через nginx и дать ссылку на репо

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

### Настройка репозитория на собственном сервере

Установка и настройка nginx

```
yum install nginx
systemctl start nginx
systemctl enable nginx
```

Отображать файлы
```
vi /etc/nginx/nginx.conf

        location /repo {
                 autoindex on; 
        }
```

Переключаем режим
```
vi /etc/selinux/config

        SELINUX=disabled
```

Создаём каталоги и в rpm копирум файл rpm, который собрал
```
mkdir -p /usr/share/nginx/html/repo/rpm
```

Устанавливаем createrepo
```
yum install createrepo
```


Создаём репозиторий
```
createrepo /usr/share/nginx/html/repo/rpm/

        Spawning worker 0 with 1 pkgs
        Workers Finished
        Saving Primary metadata
        Saving file lists metadata
        Saving other metadata
        Generating sqlite DBs
        Sqlite DBs complete
```

Перезагрузка
```
shutdown -r now
```

### Подключаем репозиторий в виртуалке Vagranta



Проверяем подключенные репозитории
```
yum repolist

        Loaded plugins: fastestmirror
        Loading mirror speeds from cached hostfile
         * base: mirror.docker.ru
         * extras: mirror.sale-dedic.com
         * updates: mirror.corbina.net
        repo id                                                       repo name                                                                         status
        base/7/x86_64                                                 CentOS-7 - Base                                                                   10 072
        extras/7/x86_64                                               CentOS-7 - Extras                                                                    512
        updates/7/x86_64                                              CentOS-7 - Updates                                                                 4 135
        repolist: 14 720
```

Добавляем наш репозиторий
```
sudo yum-config-manager --add-repo http://82.148.18.18/repo/rpm/
```
Проверяем подключенные репозитории
```
yum repolist

        Loaded plugins: fastestmirror
        Loading mirror speeds from cached hostfile
         * base: mirror.docker.ru
         * extras: mirror.sale-dedic.com
         * updates: mirror.corbina.net
        repo id                                                       repo name                                                                         status
        82.148.18.18_repo_rpm_                                        added from: http://82.148.18.18/repo/rpm/                                              1
        base/7/x86_64                                                 CentOS-7 - Base                                                                   10 072
        extras/7/x86_64                                               CentOS-7 - Extras                                                                    512
        updates/7/x86_64                                              CentOS-7 - Updates                                                                 4 135
        repolist: 14 720
```

Можно попробовать установить
```
sudo yum install nginx

        Loaded plugins: fastestmirror
        Loading mirror speeds from cached hostfile
         * base: mirrors.datahouse.ru
         * extras: mirror.sale-dedic.com
         * updates: ftp.nsc.ru
        Resolving Dependencies
        --> Running transaction check
        ---> Package nginx.x86_64 1:1.22.0-1.el7.ngx will be installed
        --> Finished Dependency Resolution

        Dependencies Resolved

        ================================================================================================================================================
         Package                     Arch                         Version                                  Repository                                    Size
        ================================================================================================================================================
        Installing:
         nginx                       x86_64                       1:1.22.0-1.el7.ngx                       82.148.18.18_repo_rpm_                       795 k

        Transaction Summary
        ================================================================================================================================================
        Install  1 Package

        Total download size: 795 k
        Installed size: 2.8 M
        Is this ok [y/d/N]:
```

# **Результаты**

Создал RPM пакет из исходников. 

Развернул веб сервер, закачал созданный файл и создал свой репозитроий. 

Подключил этот репозиторий в виртуалке на Vagrante. 

Ссылка на репозиторий: http://82.148.18.18/repo/rpm/
