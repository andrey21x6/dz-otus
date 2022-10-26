# Сбор и анализ логов.

# **Prerequisite**

- Host OS: Ubuntu Desktop 20.04.4
- Guest OS: Cent OS 8.5.2111
- VirtualBox: 6.1.36
- Vagrant: 2.3.0-1

# **Содержание ДЗ**

* В вагранте поднимаем 2 машины web и log
* На web поднимаем nginx
* На log настраиваем центральный лог сервер на любой системе на выбор rsyslog
* Настраиваем аудит, следящий за изменением конфигов нжинкса
* Все критичные логи с web должны собираться и локально и удаленно.
* Все логи с nginx должны уходить на удаленный сервер (локально только критичные).
* Логи аудита должны также уходить на удаленную систему.
* Формат сдачи ДЗ - vagrant + ansible

# **Выполнение**

###КЛИЕНТ

Открываем файл конфига rsyslog
```
sudo nano /etc/rsyslog.conf
```

После $WorkDirectory /var/spool/rsyslog

Добавить для Nginx
```
$ModLoad imfile
```

После $IncludeConfig /etc/rsyslog.d/*.conf

Добавить адрес и порт сервера rsyslog по TCP (@@...), отправляем все логи (*.*)
```
*.* @@192.168.100.209:514
```

Создать
```
sudo nano /etc/rsyslog.d/nginx.conf
```

Добавить
```
# error log
$InputFileName /var/log/nginx/error.log
$InputFileTag nginx:
$InputFileStateFile stat-nginx-error
$InputFileSeverity error
$InputFileFacility local6
$InputFilePollInterval 1
$InputRunFileMonitor
# access log
$InputFileName /var/log/nginx/access.log
$InputFileTag nginx:
$InputFileStateFile stat-nginx-access
$InputFileSeverity notice
$InputFileFacility local6
$InputFilePollInterval 1
$InputRunFileMonitor
```

Перезапуск rsyslog
```
sudo systemctl restart rsyslog
```

Статус rsyslog
```
sudo systemctl status rsyslog
```

###СЕРВЕР

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

