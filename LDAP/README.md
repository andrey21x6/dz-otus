# LDAP. Централизованная авторизация и аутентификация 

## **Prerequisite**

### Host ###
- Ubuntu Desktop 20.04.5
- VirtualBox: 6.1.40
- Vagrant: 2.3.2

### Guest ###
- CentOS 8.3.2011
- 

## **Содержание ДЗ**

- Установить FreeIPA

- Написать Ansible playbook для конфигурации клиента

- Настроить аутентификацию по SSH-ключам (**)

- Firewall должен быть включен на сервере и на клиенте (**)

- Формат сдачи ДЗ - vagrant + ansible

## **Выполнение ДЗ**

Запускаем стенд
```
vagrant up
```

В результате выполняются Vagrantfile и ansible playbook. 

Разворачивается два виртуальных сервера, на первом FreeIPA сервер, на втором клиент с авторизацией по ключу

После выполнения vagrant up, необходимо в /etc/hosts на хостовой машине добавить запись 192.168.50.10 server.test.local, чтобы зайти на веб-интерфейс https://server.test.local/ipa/ui/

Логин: admin

Пароль: qwe!23asd

![ldap_1](https://github.com/andrey21x6/dz-otus/blob/main/LDAP/screenshots/ldap_1.jpg)


![ldap_2](https://github.com/andrey21x6/dz-otus/blob/main/LDAP/screenshots/ldap_2.jpg)


![ldap_3](https://github.com/andrey21x6/dz-otus/blob/main/LDAP/screenshots/ldap_3.jpg)


![ldap_4](https://github.com/andrey21x6/dz-otus/blob/main/LDAP/screenshots/ldap_4.jpg)

***Для проверки, авторизовался по ключу с хостовой машины***

![ldap_5](https://github.com/andrey21x6/dz-otus/blob/main/LDAP/screenshots/ldap_5.jpg)


### ![#008000](https://placehold.co/15x15/008000/008000.png) ![#f03c15](https://placehold.co/15x15/f03c15/f03c15.png) ![#1589F0](https://placehold.co/15x15/1589F0/1589F0.png)
### Благодарю за проверку!
