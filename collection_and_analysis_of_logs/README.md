# Сбор и анализ логов.

# **Prerequisite**

- Host OS: Ubuntu Desktop 20.04.4
- Guest OS: Cent OS 8.5.2111
- VirtualBox: 6.1.36
- Vagrant: 2.3.0-1
- rsyslogd: 8.2001.0
- nginx: 1.18.0
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

После строки: $IncludeConfig /etc/rsyslog.d/*.conf

Добавить адрес и порт сервера rsyslog для отправки критических ошибок (crit)
```
*.crit @192.168.100.209:514
```

Создать файл
```
 sudo nano /etc/audit/rules.d/audit.rules
```

Добавить туда строки для контроля изменений перечисленных файлов (кофиги nginx)
```
-w /etc/nginx/nginx.conf -p wa -k nginx_conf
-w /etc/nginx/default.d/ -p wa -k nginx_conf
-w /etc/nginx/conf.d/ -p wa -k nginx_conf
```

Перезапускаем auditd
```
sudo systemctl restart auditd
```

Открываем файл конфига nginx для редактирования
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

#### СЕРВЕР сервер log

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

Раскоментируем для того, чтобы rsyslog стал сервером и принимал запросы на 514 порту
```
module(load="imudp")
input(type="imudp" port="514")
module(load="imtcp")
input(type="imtcp" port="514")
```

### ss -tulnp
```
Netid       State        Recv-Q       Send-Q                               Local Address:Port             Peer Address:Port       Process
udp         UNCONN       0            0                                          0.0.0.0:514                   0.0.0.0:*
udp         UNCONN       0            0                                    127.0.0.53%lo:53                    0.0.0.0:*
udp         UNCONN       0            0                                   10.0.2.15%eth0:68                    0.0.0.0:*
udp         UNCONN       0            0                                             [::]:514                      [::]:*
udp         UNCONN       0            0                  [fe80::a00:27ff:febe:90b3]%eth1:546                      [::]:*
tcp         LISTEN       0            25                                         0.0.0.0:514                   0.0.0.0:*
tcp         LISTEN       0            4096                                 127.0.0.53%lo:53                    0.0.0.0:*
tcp         LISTEN       0            128                                        0.0.0.0:22                    0.0.0.0:*
tcp         LISTEN       0            25                                            [::]:514                      [::]:*
tcp         LISTEN       0            128                                           [::]:22                       [::]:*
```

После module(load="imklog" permitnonkernelfacility="on") добавить для получения удалённых логов, в том числе с аудита конфигов nginx
```
$template RemoteLogs,"/var/log/rsyslog/%HOSTNAME%/%PROGRAMNAME%.log"
*.* ?RemoteLogs
& ~

$template HostAudit, "/var/log/rsyslog/%HOSTNAME%/audit.log"
local6.* ?HostAudit
```

Перезапуск rsyslog
```
sudo systemctl restart rsyslog
```

Через некоторое время, в каталоге /var/log/rsyslog появятся каталоги log и web (по названию хостов) и там будут лог-файлы.

```
sudo ls /var/log/rsyslog/log -l
   total 32
   -rw-r--r-- 1 syslog syslog   361 Oct 27 12:05 50-motd-news.log
   -rw-r--r-- 1 syslog syslog 10872 Oct 27 12:25 CRON.log
   -rw-r--r-- 1 syslog syslog  1992 Oct 27 11:52 rsyslogd.log
   -rw-r--r-- 1 syslog syslog  7713 Oct 27 12:28 sudo.log
   -rw-r--r-- 1 syslog syslog  1606 Oct 27 12:18 systemd.log

sudo ls /var/log/rsyslog/web -l
   total 84
   -rw-r--r-- 1 syslog syslog  1535 Oct 27 12:25 CRON.log
   -rw-r--r-- 1 syslog syslog  1209 Oct 27 08:15 nginx_access.log
   -rw-r--r-- 1 syslog syslog  1141 Oct 27 11:54 rsyslogd.log
   -rw-r--r-- 1 syslog syslog  1283 Oct 27 12:14 sudo.log
   -rw-r--r-- 1 syslog syslog   295 Oct 27 11:51 systemd.log
   -rw-r--r-- 1 syslog syslog 58067 Oct 27 12:25 tag_audit_log.log
```

