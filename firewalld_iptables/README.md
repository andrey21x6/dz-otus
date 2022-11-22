# Архитектура сетей

# **Prerequisite**

- Host OS: Ubuntu Desktop 20.04.4
- Guest OS: 7.8.2003
- VirtualBox: 6.1.36
- Vagrant: 2.3.0-1

# **Содержание ДЗ**

1. Реализовать knocking port, centralRouter может попасть на ssh inetRouter через knock скрипт

2. Добавить inetRouter2, который виден(маршрутизируется (host-only тип сети для виртуалки)) с хоста или форвардится порт через локалхост

3. Запустить nginx на centralServer

4. Пробросить 80й порт на inetRouter2 8080

5. Дефолт в инет оставить через inetRouter

6. Реализовать проход на 80й порт без маскарадинга

# **Выполнение ДЗ**

