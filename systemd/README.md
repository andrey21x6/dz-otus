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

Проверим
```
systemctl list-timers

  NEXT                         LEFT          LAST                         PASSED       UNIT                         ACTIVATES
  Wed 2022-08-31 10:05:29 UTC  11s left      Wed 2022-08-31 10:04:59 UTC  18s ago      watchlog.timer               watchlog.service
  Wed 2022-08-31 10:10:00 UTC  4min 41s left Wed 2022-08-31 10:00:48 UTC  4min 29s ago sysstat-collect.timer        sysstat-collect.service
  Wed 2022-08-31 10:30:22 UTC  25min left    Wed 2022-08-31 08:59:59 UTC  1h 5min ago  dnf-makecache.timer          dnf-makecache.service
  Wed 2022-08-31 11:00:00 UTC  54min left    Wed 2022-08-31 10:00:48 UTC  4min 29s ago mlocate-updatedb.timer       mlocate-updatedb.service
  Thu 2022-09-01 00:00:00 UTC  13h left      Wed 2022-08-31 07:00:13 UTC  3h 5min ago  unbound-anchor.timer         unbound-anchor.service
  Thu 2022-09-01 00:07:00 UTC  14h left      n/a                          n/a          sysstat-summary.timer        sysstat-summary.service
  Thu 2022-09-01 07:15:49 UTC  21h left      Wed 2022-08-31 07:15:49 UTC  2h 49min ago systemd-tmpfiles-clean.timer systemd-tmpfiles-clean.service

  7 timers listed.
  Pass --all to see loaded but inactive timers, too.
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

Для запуска нескольких экземпляров сервиса будем использовать шаблон в конфигурации файла окружения
Копируем файл сервиса
```
cp /usr/lib/systemd/system/httpd.service /usr/lib/systemd/system/httpd@.service
```

Приводим к виду
```
vi /usr/lib/systemd/system/httpd@.service

  [Unit]
  Description=The Apache HTTP Server
  Wants=httpd-init.service
  After=network.target remote-fs.target nss-lookup.target httpd-init.service
  Documentation=man:httpd.service(8)

  [Service]
  Type=notify
  #Environment=LANG=C
  EnvironmentFile=/etc/sysconfig/httpd-%I

  ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
  ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
  # Send SIGWINCH for graceful stop
  KillSignal=SIGWINCH
  KillMode=mixed
  PrivateTmp=true

  [Install]
  WantedBy=multi-user.target
```

В файлах окружения задаём опции для запуска веб-сервера с необходимым конфигурационным файлом
```
vi /etc/sysconfig/httpd-first

  OPTIONS=-f conf/first.conf
  
vi /etc/sysconfig/httpd-second

  OPTIONS=-f conf/second.conf
```

Создаём pid файлы с разными PID-ами
```
vi /var/run/httpd-first.pid
vi /var/run/httpd-second.pid
```

В директории /etc/httpd/conf/ копируем два файла
```
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/first.conf
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/second.conf
```

В них устанавливаем два параметра
```
vi  /etc/httpd/conf/first.conf

  PidFile /var/run/httpd-first.pid
  Listen 8081
  
vi  /etc/httpd/conf/second.conf

  PidFile /var/run/httpd-second.pid
  Listen 8082
```

Запускаем
```
systemctl start httpd@first
systemctl start httpd@second
```

Проверим
```
ss -tunlp | grep httpd

  tcp   LISTEN 0      128          0.0.0.0:8081        0.0.0.0:*    users:(("httpd",pid=8997,fd=3),("httpd",pid=8996,fd=3),("httpd",pid=8995,fd=3),("httpd",pid=8994,fd=3),("httpd",pid=8992,fd=3))
  
  tcp   LISTEN 0      128          0.0.0.0:8082        0.0.0.0:*    users:(("httpd",pid=8854,fd=3),("httpd",pid=8853,fd=3),("httpd",pid=8852,fd=3),("httpd",pid=8851,fd=3),("httpd",pid=8850,fd=3))
```

# **Результаты**

- Полученный в ходе работы `Vagrantfile` помещен в публичный репозиторий:
**GitHub** - https://github.com/andrey21x6/dz-otus/tree/main/systemd
- Написал service, который раз в 30 секунд мониторить лог на предмет наличия ключевого слова
- Из репозитория epel установил spawn-fcgi и переписал init-скрипт на unit-файл
- Дополнил unit-файл httpd возможностью запустить несколько инстансов сервера с разными конфигурационными файлами
