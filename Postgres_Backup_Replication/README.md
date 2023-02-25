# MySQL: Backup + Репликация

## **Prerequisite**

### Host ###
- Ubuntu Desktop 20.04.5
- VirtualBox: 6.1.40
- Vagrant: 2.3.2

### Guest ###
- CentOS 8.3.2011
- PostgreSQL 10.17

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

Настроен Backup логический (pg_dump) и физический (mariabackup) с помощью cron

Запуск в Vagrant построен так, что если удалить одну из виртуалок 
(vagrant halt database1 или database2; vagrant destroy database1 или database2), 
то при запуске (vagrant up database1 или database2), развернётся виртуалка с актуальной БД, 
даже если во время развёртывания удалённой виртуалки, производили какие-либо манипуляции с БД

**Демонстрация работы репликации на скриншоте**

![replica_db](https://github.com/andrey21x6/dz-otus/blob/main/MySQL_backup_replica/scrin/replica_db.jpg)

**Демонстрация состояния slave репликации на скриншотах**
```
mysql -e 'SHOW SLAVE STATUS \G'
```

![replica_slave_1](https://github.com/andrey21x6/dz-otus/blob/main/MySQL_backup_replica/scrin/replica_slave_1.jpg)

![replica_slave_2](https://github.com/andrey21x6/dz-otus/blob/main/MySQL_backup_replica/scrin/replica_slave_2.jpg)

**Демонстрация работы Backup на скриншотах, для проверки, можно запустить команду ниже**

```
/home/vagrant/backup.sh
```

![backup_1](https://github.com/andrey21x6/dz-otus/blob/main/MySQL_backup_replica/scrin/backup_1.jpg)

![backup_2](https://github.com/andrey21x6/dz-otus/blob/main/MySQL_backup_replica/scrin/backup_2.jpg)



### ![#008000](https://placehold.co/15x15/008000/008000.png) ![#f03c15](https://placehold.co/15x15/f03c15/f03c15.png) ![#1589F0](https://placehold.co/15x15/1589F0/1589F0.png)
### Благодарю за проверку!


