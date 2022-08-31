# Инициализация системы. Systemd.

# **Prerequisite**

- Host OS: Ubuntu Desktop 20.04.4
- Guest OS: Cent OS 8.5.2111
- VirtualBox: 6.1.36
- Vagrant: 2.3.0-1

# **Содержание ДЗ**

* Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/sysconfig).
* Из репозитория epel установить spawn-fcgi и переписать init-скрипт на unit-файл (имя service должно называться так же: spawn-fcgi).
* Дополнить unit-файл httpd (он же apache) возможностью запустить несколько инстансов сервера с разными конфигурационными файлами.

# **Выполнение**

### Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова ALERT

Создаём файл с конфигурацией для сервиса в директории /etc/sysconfig
```
vi /etc/sysconfig/watchlog

  WORD="ALERT"
  LOG=/var/log/watchlog.log
```

Создаем файл /var/log/watchlog.log
```
vi /var/log/watchlog.log
```

Создадим скрипт и включим выполнение
```
vi /opt/watchlog.sh

  #!/bin/bash
  WORD=$1
  LOG=$2
  DATE=`date`
  if grep $WORD $LOG &> /dev/null
  then
  logger "$DATE: I found word, Master!"
  else
  exit 0
  fi
  
chmod +x /opt/watchlog.sh
```

Создадим юнит для сервиса
```
vi /usr/lib/systemd/system/watchlog.service

  [Unit]
  Description=My watchlog service
  
  [Service]
  Type=oneshot
  EnvironmentFile=/etc/sysconfig/watchlog
  ExecStart=/opt/watchlog.sh $WORD $LOG
```

Создадим юнит для таймера
```
vi /usr/lib/systemd/system/watchlog.timer

  [Unit]
  Description=Run watchlog script every 30 second
  
  [Timer]
  OnUnitActiveSec=30
  Unit=watchlog.service
  
  [Install]
  WantedBy=multi-user.target
```

Стартуем таймер
```
systemctl start watchlog.timer
```

Смотрим журнал
```
journalctl -f

  Started Run watchlog script every 30 second.
  Wed Aug 31 08:50:50 UTC 2022: I found word, Master!
  Aug 31 08:50:50 systemdhost systemd[1]: watchlog.service: Succeeded.
  Aug 31 08:50:50 systemdhost systemd[1]: Started My watchlog service.
  Aug 31 08:51:49 systemdhost systemd[1]: Starting My watchlog service...
  Aug 31 08:51:49 systemdhost root[4051]: Wed Aug 31 08:51:49 UTC 2022: I found word, Master!
  Aug 31 08:51:49 systemdhost systemd[1]: watchlog.service: Succeeded.
  Aug 31 08:51:49 systemdhost systemd[1]: Started My watchlog service.
  Aug 31 08:52:59 systemdhost systemd[1]: Starting My watchlog service...
  Aug 31 08:52:59 systemdhost root[4056]: Wed Aug 31 08:52:59 UTC 2022: I found word, Master!
  Aug 31 08:52:59 systemdhost systemd[1]: watchlog.service: Succeeded.
  Aug 31 08:52:59 systemdhost systemd[1]: Started My watchlog service.
  Aug 31 08:53:59 systemdhost systemd[1]: Starting My watchlog service...
  Aug 31 08:53:59 systemdhost root[4061]: Wed Aug 31 08:53:59 UTC 2022: I found word, Master!
  Aug 31 08:53:59 systemdhost systemd[1]: watchlog.service: Succeeded.
  Aug 31 08:53:59 systemdhost systemd[1]: Started My watchlog service.
  Aug 31 08:54:37 systemdhost systemd[1]: Starting My watchlog service...
  Aug 31 08:54:37 systemdhost root[4068]: Wed Aug 31 08:54:37 UTC 2022: I found word, Master!
  Aug 31 08:54:37 systemdhost systemd[1]: watchlog.service: Succeeded.
  Aug 31 08:54:37 systemdhost systemd[1]: Started My watchlog service.
  Aug 31 08:55:59 systemdhost systemd[1]: Starting My watchlog service...
  Aug 31 08:55:59 systemdhost root[4073]: Wed Aug 31 08:55:59 UTC 2022: I found word, Master!
  Aug 31 08:55:59 systemdhost systemd[1]: watchlog.service: Succeeded.
  Aug 31 08:55:59 systemdhost systemd[1]: Started My watchlog service.
```

Проверим статус таймера
```
systemctl status watchlog.timer

  ● watchlog.timer - Run watchlog script every 30 second
     Loaded: loaded (/usr/lib/systemd/system/watchlog.timer; disabled; vendor preset: disabled)
     Active: active (running) since Wed 2022-08-31 08:44:06 UTC; 12min ago
    Trigger: n/a

  Aug 31 08:44:06 systemdhost systemd[1]: Started Run watchlog script every 30 second.
```

### Из репозитория epel установить spawn-fcgi и переписать init-скрипт на unit-файл (имя service должно называться так же: spawn-fcgi).

Устанавливаем spawn-fcgi и необходимые для него пакеты

```
yum install epel-release -y && yum install spawn-fcgi php php-cli mod_fcgid httpd -y
```

Раскомментируем строки с переменными в файле /etc/sysconfig/spawn-fcgi
```
vi /etc/sysconfig/spawn-fcgi

  SOCKET=/var/run/php-fcgi.sock
  OPTIONS="-u apache -g apache -s $SOCKET -S -M 0600 -C 32 -F 1 -P /var/run/spawn-fcgi.pid -- /usr/bin/php-cgi"
```

Создаём файл юнита
```
vi /etc/systemd/system/spawn-fcgi.service

[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target

[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/sysconfig/spawn-fcgi
ExecStart=/usr/bin/spawn-fcgi -n $OPTIONS
KillMode=process

[Install]
WantedBy=multi-user.target
```

Запускаем
```
systemctl start spawn-fcgi
```

Убеждаемся что все успешно работает
```
systemctl status spawn-fcgi

  ● spawn-fcgi.service - Spawn-fcgi startup service by Otus
     Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: disabled)
     Active: active (running) since Wed 2022-08-31 09:52:35 UTC; 8s ago
   Main PID: 5590 (php-cgi)
      Tasks: 33 (limit: 4952)
     Memory: 18.7M
     CGroup: /system.slice/spawn-fcgi.service
             ├─5590 /usr/bin/php-cgi
             ├─5591 /usr/bin/php-cgi
             ├─5592 /usr/bin/php-cgi
             ├─5593 /usr/bin/php-cgi
             ├─5594 /usr/bin/php-cgi
             ├─5595 /usr/bin/php-cgi
             ├─5596 /usr/bin/php-cgi
             ├─5597 /usr/bin/php-cgi
             ├─5598 /usr/bin/php-cgi
             ├─5599 /usr/bin/php-cgi
             ├─5600 /usr/bin/php-cgi
             ├─5601 /usr/bin/php-cgi
             ├─5602 /usr/bin/php-cgi
             ├─5603 /usr/bin/php-cgi
             ├─5604 /usr/bin/php-cgi
             ├─5605 /usr/bin/php-cgi
             ├─5606 /usr/bin/php-cgi
             ├─5607 /usr/bin/php-cgi
             ├─5608 /usr/bin/php-cgi
             ├─5609 /usr/bin/php-cgi
             ├─5610 /usr/bin/php-cgi
             ├─5611 /usr/bin/php-cgi
             ├─5612 /usr/bin/php-cgi
             ├─5613 /usr/bin/php-cgi
             ├─5614 /usr/bin/php-cgi
             ├─5615 /usr/bin/php-cgi
             ├─5616 /usr/bin/php-cgi
             ├─5617 /usr/bin/php-cgi
             ├─5618 /usr/bin/php-cgi
             ├─5619 /usr/bin/php-cgi
             ├─5620 /usr/bin/php-cgi
             ├─5621 /usr/bin/php-cgi
             └─5622 /usr/bin/php-cgi

  Aug 31 09:52:35 systemdhost systemd[1]: Started Spawn-fcgi startup service by Otus.
```






























# **Результаты**

Полученный в ходе работы `Vagrantfile` помещен в публичный репозиторий:
- **GitHub** - https://github.com/andrey21x6/dz-otus/tree/main/system_boot

Получили доступ к системе, не зная пароля root.

Получили переименованный volume group.

Во время загрузки системы будет виден пингвин.

