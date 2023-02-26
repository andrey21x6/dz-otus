# Postgres: Backup + Репликация

## **Prerequisite**

### Host ###
- Ubuntu Desktop 20.04.5
- VirtualBox: 6.1.40
- Vagrant: 2.3.2

### Guest ###
- CentOS 8.3.2011
- PostgreSQL 10.17
- Django 2.2.3

## **Содержание ДЗ**

- Настроить hot_standby репликацию с использованием слотов

- Настроить правильное резервное копирование

- Для сдачи работы присылаем ссылку на репозиторий, в котором должны обязательно быть

- Vagranfile (2 машины)

- Плейбук Ansible

- Конфигурационные файлы postgresql.conf, pg_hba.conf и recovery.conf, конфиг barman, либо скрипт резервного копирования

- Команда "vagrant up" должна поднимать машины с настроенной репликацией и резервным копированием

- Рекомендуется в README.md файл вложить результаты (текст или скриншоты) проверки работы репликации и резервного копирования.

## **Выполнение ДЗ**

Запускаем стенд
```
vagrant up
```

Развёрнуто два виртуальных сервера с БД PostgreSQL

Настроена репликация Master - Slave

Настроен Backup логический (pg_dump) и физический (pg_basebackup) с помощью cron

**Демонстрация работы репликации на скриншотах**

![replica_db](https://github.com/andrey21x6/dz-otus/blob/main/Postgres_Backup_Replication/scrin/master_slave.jpg)

![replica_db](https://github.com/andrey21x6/dz-otus/blob/main/Postgres_Backup_Replication/scrin/create_db.jpg)

**Демонстрация работы Backup на скриншоте, для проверки, можно запустить команду ниже**

```
/home/vagrant/backup.sh
```

![backup_1](https://github.com/andrey21x6/dz-otus/blob/main/Postgres_Backup_Replication/scrin/backup.jpg)

**Содержимое автоматически созданного файла recovery.conf на Database 2 (реплика slave)**

![backup_1](https://github.com/andrey21x6/dz-otus/blob/main/Postgres_Backup_Replication/scrin/recovery.conf.jpg)

В конфигурационных файлах postgresql.conf и pg_hba.conf вносятся изменения в процессе выполнения команды vagrant up

В файле каждая команда описана, можно посмотреть тут

https://github.com/andrey21x6/dz-otus/blob/main/Postgres_Backup_Replication/bash/setup.sh

**Корректность скрипта bash проверено на сайте shellcheck.net**

![backup_1](https://github.com/andrey21x6/dz-otus/blob/main/Postgres_Backup_Replication/scrin/shellcheck.net.jpg)



### ![#008000](https://placehold.co/15x15/008000/008000.png) ![#f03c15](https://placehold.co/15x15/f03c15/f03c15.png) ![#1589F0](https://placehold.co/15x15/1589F0/1589F0.png)
### Благодарю за проверку!
