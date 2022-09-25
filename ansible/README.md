# Ansible

# **Prerequisite**

- Host OS: Ubuntu Desktop 20.04.4
- GNU bash, version 5.0.17(1)-release-(x86_64-pc-linux-gnu)
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



# **Результаты**

Подготовил стенд на Vagrant с двумя серверами. Использовал Ansible, развернул nginx.

Ссылка на Git по ДЗ: https://github.com/andrey21x6/dz-otus/tree/main/ansible
