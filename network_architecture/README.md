# Архитектура сетей

# **Prerequisite**

- Host OS: Ubuntu Desktop 20.04.4
- Guest OS: 7.8.2003
- VirtualBox: 6.1.36
- Vagrant: 2.3.0-1

# **Содержание ДЗ**

Построить следующую архитектуру

Сеть office1
- 192.168.2.0/26    - dev
- 192.168.2.64/26   - test servers
- 192.168.2.128/26  - managers
- 192.168.2.192/26  - office hardware

Сеть office2
- 192.168.1.0/25    - dev
- 192.168.1.128/26  - test servers
- 192.168.1.192/26  - office hardware


Сеть central
- 192.168.0.0/28   - directors
- 192.168.0.32/28  - office hardware
- 192.168.0.64/26  - wifi

```
Office1 ---\
      -----> Central --IRouter --> internet
Office2----/
```

Итого должны получится следующие сервера

- inetRouter
- centralRouter
- office1Router
- office2Router
- centralServer
- office1Server
- office2Server

# Теоретическая часть

- Найти свободные подсети
- Посчитать сколько узлов в каждой подсети, включая свободные
- Указать broadcast адрес для каждой подсети
- Проверить нет ли ошибок при разбиении

# Практическая часть

- Соединить офисы в сеть согласно схеме и настроить роутинг
- Все сервера и роутеры должны ходить в инет черз inetRouter
- Все сервера должны видеть друг друга
- У всех новых серверов отключить дефолт на нат (eth0), который вагрант поднимает для связи
- При нехватке сетевых интервейсов добавить по несколько адресов на интерфейс

# **Выполнение ДЗ**

### Теоретическая часть

----------------------------------------------------------------------------

192.168.2.0/26 - 62 хоста, Network 192.168.2.0, Broadcast 192.168.2.63

192.168.2.64/26 - 62 хоста, Network 192.168.2.64, Broadcast 192.168.2.126

192.168.2.128/26 - 62 хоста, Network 192.168.2.128, Broadcast 192.168.2.191

192.168.2.192/26 - 62 хоста, Network 192.168.2.192, Broadcast 192.168.2.254


Свободных нет.

----------------------------------------------------------------------------

192.168.1.0/25 - 126 хоста, Network 192.168.1.0, Broadcast 192.168.1.127

192.168.1.128/26 - 62 хоста, Network 192.168.1.128, Broadcast 192.168.1.191

192.168.1.192/26 - 62 хоста, Network 192.168.1.192, Broadcast 192.168.1.254


Свободных нет.

----------------------------------------------------------------------------

192.168.0.0/28 - 14 хоста, Network 192.168.0.0, Broadcast 192.168.0.15

192.168.0.32/28 - 14 хоста, Network 192.168.0.32, Broadcast 192.168.0.47

192.168.0.64/26 - 62 хоста, Network 192.168.0.64, Broadcast 192.168.0.127


Свободные:

192.168.0.16/28 - 14 хоста, Network 192.168.0.16, Broadcast 192.168.0.31

192.168.0.48/28 - 14 хоста, Network 192.168.0.48, Broadcast 192.168.0.63

192.168.0.128/25 - 126 хоста, Network 192.168.0.128, Broadcast 192.168.0.254


----------------------------------------------------------------------------

### Практическая часть


#### office1Server

![office1Server-1](https://github.com/andrey21x6/dz-otus/blob/main/network_architecture/scrin/office1Server-1.jpg)

![office1Server-2](https://github.com/andrey21x6/dz-otus/blob/main/network_architecture/scrin/office1Server-2.jpg)

#### office2Server

![office2Server-1](https://github.com/andrey21x6/dz-otus/blob/main/network_architecture/scrin/office2Server-1.jpg)

![office2Server-2](https://github.com/andrey21x6/dz-otus/blob/main/network_architecture/scrin/office2Server-2.jpg)

#### centralServer

![centralServer-1](https://github.com/andrey21x6/dz-otus/blob/main/network_architecture/scrin/centralServer-1.jpg)

![centralServer-2](https://github.com/andrey21x6/dz-otus/blob/main/network_architecture/scrin/centralServer-2.jpg)
