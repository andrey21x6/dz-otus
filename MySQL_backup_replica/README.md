# MySQL: Backup + Репликация

## **Prerequisite**

### Host ###
- Ubuntu Desktop 20.04.5
- VirtualBox: 6.1.40
- Vagrant: 2.3.2

### Guest ###
- CentOS 8.3.2011
- MariaDB 10.3.2

## **Содержание Проектной работы**

- Настроить GTID репликацию

- Рабочий вагрантафайл

- Скрины или логи SHOW TABLES

- Конфиги

- Пример в логе изменения строки и появления строки на реплике

## **Выполнение ДЗ**

Запускаем стенд
```
vagrant up
```

Развёрнуто два виртуальных сервера с БД MariaDB

Настроена репликация Master - Master

Настроен Backup логический (mysqldump) и физический (mariabackup) с помощью cron

Запуск в Vagrant построен так, что если удалить одну из виртуалок 
(vagrant halt database1 или database2; vagrant destroy database1 или database2), 
то при запуске (vagrant up database1 или database2), развернётся виртуалка с актуально БД, 
даже если во время развёртывания удалённой, производили какие-либо манипуляции с БД

**Демонстрация работы репликации на скпиншоте**

![replica_db](https://user-images.githubusercontent.com/91377497/219869945-0e06df98-1a59-437f-abce-2bea0013f382.jpg)

**Демонстрация работы Backup на скпиншотах**

![backup_1](https://user-images.githubusercontent.com/91377497/219869949-573fbc63-2859-48a1-960f-34ac48ac9537.jpg)

![backup_2](https://user-images.githubusercontent.com/91377497/219869954-4f9a4f7a-7752-4ac9-9eb9-17d18655483b.jpg)

### ![#008000](https://placehold.co/15x15/008000/008000.png) ![#f03c15](https://placehold.co/15x15/f03c15/f03c15.png) ![#1589F0](https://placehold.co/15x15/1589F0/1589F0.png)
### Благодарю за проверку!
