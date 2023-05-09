# Проектная работа

### Для запуска стенда, обязательно нужен включенный VPN с заграничным IP-адресом !!!

### В Logstash в конфиг файле, в секции output в строке index, не появляются индексы в Elasticsearch, если значение написано с большой буквы (index => "backend1") !!!

## **Prerequisite**

### Host ###
- Ubuntu Desktop 20.04.5
- VirtualBox: 6.1.40
- Vagrant: 2.3.2

### Guest ###
- CentOS 8.3.2011
- Nginx 1.14.1
- PHP 7.2.24
- MariaDB 10.3.2
- Filebeat 8.6.1
- Elasticsearch 8.6.1
- Kibana 8.6.1
- Logstash 8.6.1
- Metricbeat 8.6.2

## **Содержание Проектной работы**

Веб проект с развертыванием нескольких виртуальных машин должен отвечать следующим требованиям:

- включен https

- основная инфраструктура в DMZ зоне

- файрвалл на входе

- сбор метрик и настроенный алертинг

- везде включен selinux

- организован централизованный сбор логов

- организован backup

## **Состав проекта:**

**Всего виртуальных серверов 12**

![Shema](https://github.com/andrey21x6/dz-otus/blob/main/project1/scrin/Shema.svg)

1 Nginx вебсервер frontend, настроен HTTPS, настроен iptables, разрешены входящие соединения по портам 22, 80, 443
Работает в режиме обратного прокси и балансировщика нагрузки, то есть, отправляет запросы на backend 1 и backend 2 по очереди

**Правила iptables**

![iptables_](https://github.com/andrey21x6/dz-otus/blob/main/project1/scrin/iptables_.jpg)

**2 и 3** Nginx вебсервер + PHP-fpm, backend 1 и backend 2, отправляют свои запросы в базу данных по очереди, если одна из БД не доступна, 
то backend работает с одной БД, но проверяет доступность отвалившейся и как только БД становится доступной, 
то начинает работать с обеими как и раньше

**4 и 5** База данных MariaDB, Database 1 и Database 2, настроена репликация master - master и backup логический и физический с обеих БД

**6** Backup server, в данном случае обычная виртуалка, на которую копируются архивы с бэкапами, по нормальному должен быть СХД

**7, 8 и 9** Elasticsearch в кластере из 3 нод, каждый может быть мастером

**10 и 11** Logstash с настроенными фильтрами логов, создаёт индексы для Elasticsearch

**12** Kibana, веб морда для Elasticsearch

## **Выполнение проектной работы**

Запускаем стенд командой
```
vagrant up
```

В результате запускается 12 виртуальных серверов, выполняется provision для их настройки

Каждая команда описана в файлах

Можно "пристрелить" любой виртуальный сервер. например
```
vagrant halt database1
vagrant destroy database1
```

Затем развернуть его заново, например
```
vagrant up database1
```

Виртуальный сервер поднимется с актуальной БД, даже, если в то время, когда он был удалён, велась какая-то запись в БД database2

В случае с Elasticsearch, если "пристрелить" master, то мастером автоматически становиться один из ведомых

### ![#008000](https://placehold.co/15x15/008000/008000.png) ![#f03c15](https://placehold.co/15x15/f03c15/f03c15.png) ![#1589F0](https://placehold.co/15x15/1589F0/1589F0.png)
### Благодарю за проверку!