# Пользователи и группы. Авторизация и аутентификация.

# **Prerequisite**

- Host OS: Debian 11.4

# **Содержание ДЗ**

* Запретить всем пользователям, кроме группы admin логин в выходные (суббота и воскресенье), без учета праздников.

# **Выполнение**

Создаём файл, в котором прописываем группу admin
```
nano /etc/login.group
   admin
```

Открываем для редактирования файл sshd
```
nano /etc/security/time.conf
```

Добавляем сверху файла следующие строки, то есть. запрет авторизации по ssh всем в выходные дни
```
sshd;*;*;Wk0000-2400
```

Открываем для редактирования файл sshd
```
nano /etc/pam.d/sshd
```

Добавляем сверху файла следующие строки
```
auth    [success=1 default=ignore]      pam_unix.so nullok
auth    requisite                       pam_deny.so
auth    required                        pam_permit.so
account [success=1 default=ignore] pam_listfile.so onerr=fail item=group sense=allow file=/etc/login.group
account required pam_time.so debug
```

В этом файле описаны правила так, что группа admin, указанная в файле login.group, игнорирует следующий подключенный модуль pam_time.so, а все остальные попадают под его действие.
