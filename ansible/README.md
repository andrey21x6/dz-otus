# Ansible

# **Prerequisite**

- Host OS: Ubuntu Desktop 20.04.4

- GNU bash, version 5.0.17(1)-release-(x86_64-pc-linux-gnu)
=======
- Guest OS 1: Ubuntu 20.04.5 LTS
- Guest OS 2: Ubuntu 20.04.5 LTS
- nginx_version: 1.18.0
- ansible [core 2.13.4]
- python version = 3.8.10 (default, Jun 22 2022, 20:18:18) [GCC 9.4.0]
- jinja version = 3.1.2

# **Содержание ДЗ**

Подготовить стенд на Vagrant как минимум с одним сервером. На этом сервере используя Ansible необходимо развернуть nginx со следующими условиями:

* необходимо использовать модуль yum/apt;
* конфигурационные файлы должны быть взяты из шаблона jinja2 с перемененными;
* после установки nginx должен быть в режиме enabled в systemd;
* должен быть использован notify для старта nginx после установки;
* сайт должен слушать на нестандартном порту - 8080, для этого использовать переменные в Ansible.


# **Выполнение**

Проверил первый сервер:
```
curl http://192.168.100.201:8080

    <!DOCTYPE html>
    <html>
    <head>
    <title>Welcome to nginx!</title>
    <style>
        body {
            width: 35em;
            margin: 0 auto;
            font-family: Tahoma, Verdana, Arial, sans-serif;
        }
    </style>
    </head>
    <body>
    <h1>Welcome to nginx!</h1>
    <p>If you see this page, the nginx web server is successfully installed and
    working. Further configuration is required.</p>

    <p>For online documentation and support please refer to
    <a href="http://nginx.org/">nginx.org</a>.<br/>
    Commercial support is available at
    <a href="http://nginx.com/">nginx.com</a>.</p>

    <p><em>Thank you for using nginx.</em></p>
    </body>
    </html>
```

Проверил второй сервер:
```
curl http://192.168.100.202:8081

    <!DOCTYPE html>
    <html>
    <head>
    <title>Welcome to nginx!</title>
    <style>
        body {
            width: 35em;
            margin: 0 auto;
            font-family: Tahoma, Verdana, Arial, sans-serif;
        }
    </style>
    </head>
    <body>
    <h1>Welcome to nginx!</h1>
    <p>If you see this page, the nginx web server is successfully installed and
    working. Further configuration is required.</p>

    <p>For online documentation and support please refer to
    <a href="http://nginx.org/">nginx.org</a>.<br/>
    Commercial support is available at
    <a href="http://nginx.com/">nginx.com</a>.</p>

    <p><em>Thank you for using nginx.</em></p>
    </body>
    </html>
```
>>>>>>> d5f77608ee69320b45367ebe76766a0a53f2c8c7

# **Результаты**

Подготовил стенд на Vagrant с двумя серверами. Использовал Ansible, развернул nginx.

Ссылка на Git по ДЗ: https://github.com/andrey21x6/dz-otus/tree/main/ansible
