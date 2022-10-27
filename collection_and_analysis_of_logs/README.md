# Сбор и анализ логов.

# **Prerequisite**

- Host OS: Ubuntu Desktop 20.04.4
- Guest OS: Cent OS 8.5.2111
- VirtualBox: 6.1.36
- Vagrant: 2.3.0-1
- auditd 1:2.8.5-2ubuntu6 amd64

# **Содержание ДЗ**

* В вагранте поднимаем 2 машины web и log
* На web поднимаем nginx
* На log настраиваем центральный лог сервер на любой системе на выбор rsyslog
* Настраиваем аудит, следящий за изменением конфигов нжинкса
* Все критичные логи с web должны собираться и локально и удаленно.
* Все логи с nginx должны уходить на удаленный сервер (локально только критичные).
* Логи аудита должны также уходить на удаленную систему.

# **Выполнение**

### КЛИЕНТ сервер web

Открываем файл конфига rsyslog
```
sudo nano /etc/rsyslog.conf
```

После $WorkDirectory /var/spool/rsyslog

Добавить для Nginx
```
$ModLoad imfile
```

После строки: $IncludeConfig /etc/rsyslog.d/*.conf

Добавить адрес и порт сервера rsyslog для отправки критических ошибок (crit)
```
*.crit @192.168.100.209:514
```

Создать файл
```
 sudo nano /etc/audit/rules.d/audit.rules
```

Добавить туда строки для контроля изменений перечисленных файлов
```
-w /etc/nginx/nginx.conf -p wa -k nginx_conf
-w /etc/nginx/default.d/ -p wa -k nginx_conf
-w /etc/nginx/conf.d/ -p wa -k nginx_conf
```

Перезапускаем auditd
```
sudo systemctl restart auditd
```

Открываем файл для редактирования
```
sudo nano /etc/nginx/nginx.conf
```

И приводим к виду строки с логами, чтобы все логи с nginx уходили на удаленный сервер, а локально только критические (crit)
```
access_log syslog:server=192.168.100.209:514,tag=nginx_access;
error_log syslog:server=192.168.100.209:514,tag=nginx_error,severity=info;
access_log /var/log/nginx/access.log;
error_log  /var/log/nginx/error.log,severity=crit;
```

Перезапускаем nginx
```
sudo systemctl restart nginx
```

Перезапускаем rsyslog
```
sudo systemctl restart rsyslog
```

### СЕРВЕР

Создаём каталог
```
sudo mkdir /var/log/rsyslog
```

Назначаем владельцем rsyslog
```
sudo chown -R syslog:syslog /var/log/rsyslog
```

Открываем файл конфига rsyslog
```
sudo nano /etc/rsyslog.conf
```

Раскоментировать для того, чтобы rsyslog стал сервером и слушал порт 514 по TCP
```
module(load="imtcp")
input(type="imtcp" port="514")
```

После module(load="imklog" permitnonkernelfacility="on")

Добавить
```
$template RemoteLogs,"/var/log/rsyslog/%HOSTNAME%/%PROGRAMNAME%.log"
*.* ?RemoteLogs
& ~
```

Перезапуск rsyslog
```
sudo systemctl restart rsyslog
```

Статус rsyslog
```
sudo systemctl status rsyslog
```

