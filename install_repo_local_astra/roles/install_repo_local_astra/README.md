
# Роль install_repo_local_astra, для установки локального репозитория, работает по протоколам FTP и HTTP.

### Внимание !!! Перед запуском ansible-playbook, при установке сервера репозиторий НЕ apt-mirror, файлы /root/{{ astra_iso_name }} и /root/{{ astra_base_archive }} должны быть на целевой машине (т. е. на repo02)! А при установки apt-mirror должен быть интернет на целевой машине (т. е. на repo02)!

--------------

Установка локального репозитория производится в нескольких вариантах:

- по протоколу FTP, каталоги main и base (mirror_enable: 0, ftp_enable: 1, http_enable: 0)

- по протоколу HTTP, каталоги main и base (mirror_enable: 0, ftp_enable: 0, http_enable: 1)

- по протоколу FTP и HTTP, каталоги main и base (mirror_enable: 0, ftp_enable: 1, http_enable: 1)

- по протоколу FTP и HTTP, каталог apt-mirror (mirror_enable: 1, ftp_enable: 0, http_enable: 0)

--------------

**В файле /etc/apt/sources.list у клиента по FTP**
```
deb ftp://ip_adress_repo02/main stable main contrib non-free
deb ftp://ip_adress_repo02/base stable main contrib non-free
```

**В файле /etc/apt/sources.list у клиента по HTTP**
```
deb http://ip_adress_repo02/repo/alse/main stable main contrib non-free
deb http://ip_adress_repo02/repo/alse/base stable main contrib non-free
```

**В файле /etc/apt/sources.list у клиента по FTP для apt-mirror**
```
deb ftp://ip_adress_repo02/apt-mirror/mirror/dl.astralinux.ru/astra/stable/1.7_x86-64/repository-main 1.7_x86-64 main contrib non-free
deb ftp://ip_adress_repo02/apt-mirror/skel/dl.astralinux.ru/astra/stable/1.7_x86-64/repository-main 1.7_x86-64 main contrib non-free
```

**В файле /etc/apt/sources.list у клиента по HTTP для apt-mirror**
```
deb http://ip_adress_repo02/repo/alse/apt-mirror/mirror/dl.astralinux.ru/astra/stable/1.7_x86-64/repository-main 1.7_x86-64 main contrib non-free
deb http://ip_adress_repo02/repo/alse/apt-mirror/skel/dl.astralinux.ru/astra/stable/1.7_x86-64/repository-main 1.7_x86-64 main contrib non-free
```

**В файле /etc/apt/sources.list на сервере repo02**
```
deb file:/srv/repo/alse/main stable main contrib non-free
deb file:/srv/repo/alse/base stable main contrib non-free
```

**В файле /etc/apt/sources.list cтандартные записи**
```
#deb cdrom:[OS Astra Linux 1.7.2 1.7_x86-64 DVD ]/ 1.7_x86-64 contrib main non-free

deb https://download.astralinux.ru/astra/stable/1.7_x86-64/repository-main/ 1.7_x86-64 main contrib non-free
deb https://download.astralinux.ru/astra/stable/1.7_x86-64/repository-update/ 1.7_x86-64 main contrib non-free

deb https://download.astralinux.ru/astra/stable/1.7_x86-64/repository-base/ 1.7_x86-64 main contrib non-free
deb https://download.astralinux.ru/astra/stable/1.7_x86-64/repository-extended/ 1.7_x86-64 main contrib non-free
```

--------------

**Передача файла на целевую машину, примеры**
```
apt instal sshpass
sshpass -p 12345678 scp -o StrictHostKeyChecking=no -P 22 1.7.2-11.08.2022_15.28.iso root@192.168.0.242:/root/1.7.2-11.08.2022_15.28.iso
scp -o StrictHostKeyChecking=no -P 22 -i ~/.ssh/priv_key 1.7.2-11.08.2022_15.28.iso root@192.168.0.242:/root/1.7.2-11.08.2022_15.28.iso
```

--------------

**В файле /etc/fstab пример**
```
/root/1.7.2-11.08.2022_15.28.iso /srv/repo/alse/main iso9660 defaults,loop 0 0
```

--------------

mount -o loop /root/1.7.2-11.08.2022_15.28.iso /srv/repo/alse/main

nano /etc/vsftpd.conf

systemctl restart vsftpd

systemctl status vsftpd

nano /etc/apache2/apache2.conf

nano /etc/apache2/sites-available/000-default.conf

systemctl restart apache2

systemctl status apache2

ls -l /var/www/html

nano /etc/apt/sources.list

tar -xzvf /root/base-1.7.2-11.08.2022_15.28.tgz -C /srv/repo/alse/base

--------------

### Example Playbook

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }
