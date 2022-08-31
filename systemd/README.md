# Инициализация системы. Systemd.

# **Prerequisite**

- Host OS: Ubuntu Desktop 20.04.4
- Guest OS: Cent OS 7.5.1804
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






















# **Результаты**

Полученный в ходе работы `Vagrantfile` помещен в публичный репозиторий:
- **GitHub** - https://github.com/andrey21x6/dz-otus/tree/main/system_boot

Получили доступ к системе, не зная пароля root.

Получили переименованный volume group.

Во время загрузки системы будет виден пингвин.

