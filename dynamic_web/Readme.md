# Динамический веб

## **Prerequisite**

### Host ###
- Ubuntu Desktop 20.04.5
- VirtualBox: 6.1.40
- Vagrant: 2.3.2
- Ansible core 2.13.6
- Python 3.8.10
- jinja 3.1.2

### Guest ###
- CentOS 8.3.2011
- Python 3.6.8
- Nginx 1.14.1
- Django 2.2.3
- React 18.2.0

## **Содержание ДЗ**

- Nginx + php-fpm (laravel/wordpress) + python (flask/django) + js(react/angular)

- Nginx + java (tomcat/jetty/netty) + go + ruby

- Можно свои комбинации

- Реализации на выбор

- На хостовой системе через конфиги в /etc

- Деплой через docker-compose

- Для усложнения можно попросить проекты у коллег с курсов по разработке

- К сдаче принимается

- Vagrant стэнд с проброшенными на локалхост портами

- Каждый порт на свой сайт

- Через нжинкс

## **Выполнение ДЗ**

Запускаем стенд
```
vagrant up
```

Запускается виртуалка, выполняетя playbook.yml

На виртуалке стартуют три процесса django react go

В результате работают три независимых веб сервиса через фронт Nginx, к которым можно получить доступ:

***GO:***

http://ip-host-machine:8100

![Go](https://github.com/andrey21x6/dz-otus/blob/main/dynamic_web/scrin/Go.jpg)

***React:***

http://ip-host-machine:8200

![React](https://github.com/andrey21x6/dz-otus/blob/main/dynamic_web/scrin/React.jpg)

***Django:***

http://ip-host-machine:8300

![Django](https://github.com/andrey21x6/dz-otus/blob/main/dynamic_web/scrin/Django.jpg)

### ![#008000](https://placehold.co/15x15/008000/008000.png) ![#f03c15](https://placehold.co/15x15/f03c15/f03c15.png) ![#1589F0](https://placehold.co/15x15/1589F0/1589F0.png)
### Благодарю за проверку!
