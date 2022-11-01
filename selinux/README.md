# Сбор и анализ логов.

# **Prerequisite**

- Host OS: Ubuntu Desktop 20.04.4
- Guest OS: Cent OS 8.5.2111
- VirtualBox: 6.1.36
- Vagrant: 2.3.0-1
- nginx: 1.18.0

# **Содержание ДЗ**

* В вагранте поднимаем 2 машины web и log
* На web поднимаем nginx
* На log настраиваем центральный лог сервер на любой системе на выбор rsyslog
* Настраиваем аудит, следящий за изменением конфигов нжинкса
* Все критичные логи с web должны собираться и локально и удаленно.
* Все логи с nginx должны уходить на удаленный сервер (локально только критичные).
* Логи аудита должны также уходить на удаленную систему.

# **Выполнение**

Для начала проверим, что в ОС отключен файервол
```
systemctl status firewalld

	● firewalld.service - firewalld - dynamic firewall daemon
	   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; disabled; vendor preset: enabled)
	   Active: inactive (dead)
		 Docs: man:firewalld(1)
```

Также можно проверить, что конфигурация nginx настроена без ошибок
```
nginx -t

	nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
	nginx: configuration file /etc/nginx/nginx.conf test is successful
```

Проверим режим работы SELinux
```
getenforce

	Enforcing
```

Разрешим в SELinux работу nginx на порту TCP 4881 c помощью переключателей setsebool

Находим в логах (/var/log/audit/audit.log) информацию о блокировании порта 4881
```
cat /var/log/audit/audit.log | grep 4881

	type=AVC msg=audit(1667117742.634:878): avc:  denied  { name_bind } for  pid=3033 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0
```

Установим audit2why
```
yum install policycoreutils-python
```

Копируем время, в которое был записан этот лог, и, с помощью утилиты audit2why смотрим информации о запрете
```
grep 1667117742.634:878 /var/log/audit/audit.log | audit2why

	type=AVC msg=audit(1667117742.634:878): avc:  denied  { name_bind } for  pid=3033 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0

        Was caused by:
        The boolean nis_enabled was set incorrectly.
        Description:
        Allow nis to enabled

        Allow access by executing:
        # setsebool -P nis_enabled 1
```

Утилита audit2why покажет почему трафик блокируется. Исходя из вывода утилиты, мы видим, что нам нужно поменять параметр nis_enabled.

Включим параметр nis_enabled и перезапустим nginx
```
setsebool -P nis_enabled on
systemctl restart nginx
```

Проверим статус nginx
```
systemctl status nginx

	● nginx.service - The nginx HTTP and reverse proxy server
	   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
	   Active: active (running) since Tue 2022-11-01 07:11:30 UTC; 6s ago
	  Process: 23504 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
	  Process: 23502 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
	  Process: 23501 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
	 Main PID: 23506 (nginx)
	   CGroup: /system.slice/nginx.service
			   ├─23506 nginx: master process /usr/sbin/nginx
			   └─23509 nginx: worker process

	Nov 01 07:11:30 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
	Nov 01 07:11:30 selinux nginx[23502]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
	Nov 01 07:11:30 selinux nginx[23502]: nginx: configuration file /etc/nginx/nginx.conf test is successful
	Nov 01 07:11:30 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.
```

Заходим в браузер на хостовой машине по адресу http://127.0.0.1:4881


![Screenshot of up-and-running server](http://i.imgur.com/TP1i9Zd.png)


Проверить статус параметра можно с помощью команды
```
getsebool -a | grep nis_enabled

	nis_enabled --> on
```

Вернём запрет работы nginx на порту 4881 обратно. Для этого отключим
nis_enabled
```
setsebool -P nis_enabled off
```
После отключения nis_enabled nginx снова не запустится.

```
systemctl restart nginx

	Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl -xe" for details.
```

Теперь разрешим в SELinux работу nginx на порту TCP 4881 c помощью добавления нестандартного порта в имеющийся тип.

Поиск имеющегося типа, для http трафика
```
semanage port -l | grep http

	http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
	http_cache_port_t              udp      3130
	http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
	pegasus_http_port_t            tcp      5988
	pegasus_https_port_t           tcp      5989
```

Добавим порт в тип http_port_t
```
semanage port -a -t http_port_t -p tcp 4881
```

Проверим
```
semanage port -l | grep http_port_t

	http_port_t                    tcp      4881, 80, 81, 443, 488, 8008, 8009, 8443, 9000
	pegasus_http_port_t            tcp      5988
```

Теперь перезапустим службу nginx и проверим её работу
```
systemctl restart nginx
systemctl status nginx

	● nginx.service - The nginx HTTP and reverse proxy server
	   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
	   Active: active (running) since Tue 2022-11-01 12:26:09 UTC; 13s ago
	  Process: 6579 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
	  Process: 6577 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
	  Process: 6576 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
	 Main PID: 6581 (nginx)
	   CGroup: /system.slice/nginx.service
			   ├─6581 nginx: master process /usr/sbin/nginx
			   └─6582 nginx: worker process

	Nov 01 12:26:09 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
	Nov 01 12:26:09 selinux nginx[6577]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
	Nov 01 12:26:09 selinux nginx[6577]: nginx: configuration file /etc/nginx/nginx.conf test is successful
	Nov 01 12:26:09 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.
```

Через браузер тоже открывается.

Удалить нестандартный порт из имеющегося типа можно с помощью команды
```
semanage port -d -t http_port_t -p tcp 4881
```

Проверим
```
semanage port -d -t http_port_t -p tcp 4881

	ValueError: Port tcp/4881 is not defined
	
semanage port -l | grep http_port_t

	http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
	pegasus_http_port_t            tcp      5988
```

После удаления порта nginx снова не запустится.

```
systemctl restart nginx

	Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl -xe" for details.
```

Разрешим в SELinux работу nginx на порту TCP 4881 c помощью формирования и установки модуля SELinux.

Посмотрим логи SELinux, которые относятся к nginx
```
grep nginx /var/log/audit/audit.log

	type=SERVICE_START msg=audit(1667305862.059:1501): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=nginx comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
	type=AVC msg=audit(1667306057.433:1502): avc:  denied  { name_bind } for  pid=7008 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0
	type=SYSCALL msg=audit(1667306057.433:1502): arch=c000003e syscall=49 success=no exit=-13 a0=6 a1=55daa4a57688 a2=10 a3=7fff2fea7420 items=0 ppid=1 pid=7008 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="nginx" exe="/usr/sbin/nginx" subj=system_u:system_r:httpd_t:s0 key=(null)
	type=SERVICE_START msg=audit(1667306057.445:1503): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=nginx comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
```

Воспользуемся утилитой audit2allow для того, чтобы на основе логов SELinux сделать модуль, разрешающий работу nginx на нестандартном порту
```
grep nginx /var/log/audit/audit.log | audit2allow -M nginx

	******************** IMPORTANT ***********************
	To make this policy package active, execute:

	semodule -i nginx.pp
```

Audit2allow сформировал модуль, и сообщил нам команду, с помощью которой можно применить данный модуль
```
semodule -i nginx.pp
```

Теперь запустим службу nginx и проверим её работу
```
systemctl start nginx
systemctl status nginx

	● nginx.service - The nginx HTTP and reverse proxy server
	   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
	   Active: active (running) since Tue 2022-11-01 12:39:48 UTC; 19s ago
	  Process: 7302 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
	  Process: 7299 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
	  Process: 7298 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
	 Main PID: 7304 (nginx)
	   CGroup: /system.slice/nginx.service
			   ├─7304 nginx: master process /usr/sbin/nginx
			   └─7306 nginx: worker process

	Nov 01 12:39:48 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
	Nov 01 12:39:48 selinux nginx[7299]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
	Nov 01 12:39:48 selinux nginx[7299]: nginx: configuration file /etc/nginx/nginx.conf test is successful
	Nov 01 12:39:48 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.
```

После добавления модуля nginx запустился без ошибок. При использовании модуля изменения сохранятся после перезагрузки.

Просмотр всех установленных модулей
```
semodule -l
```

Для удаления модуля воспользуемся командой
```
semodule -r nginx

	libsemanage.semanage_direct_remove_key: Removing last nginx module (no other nginx module exists at another priority).
```