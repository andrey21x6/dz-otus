# Backup

# **Prerequisite**

- Host OS: Ubuntu Desktop 20.04.4
- Guest OS: 7.8.2003 (backup)
- Guest OS: 7.8.2003 (client)
- VirtualBox: 6.1.36
- Vagrant: 2.2.3
- borg 1.1.18
- rsyslogd 8.24.0-52.el7

# **Содержание ДЗ**

* Настроить стенд Vagrant с двумя виртуальными машинами: backup_server и client.
* Настроить удаленный бекап каталога /etc c сервера client при помощи borgbackup. Резервные копии должны соответствовать следующим критериям:

	директория для резервных копий /var/backup. Это должна быть отдельная точка монтирования. В данном случае для демонстрации размер не принципиален, достаточно будет и 2GB;
	репозиторий дле резервных копий должен быть зашифрован ключом или паролем - на ваше усмотрение;
	имя бекапа должно содержать информацию о времени снятия бекапа;
	глубина бекапа должна быть год, хранить можно по последней копии на конец месяца, кроме последних трех. Последние три месяца должны содержать копии на каждый день. Т.е. должна быть правильно настроена политика удаления старых бэкапов;
	резервная копия снимается каждые 5 минут. Такой частый запуск в целях демонстрации;
	написан скрипт для снятия резервных копий. Скрипт запускается из соответствующей Cron джобы, либо systemd timer-а - на ваше усмотрение;
	настроено логирование процесса бекапа. Для упрощения можно весь вывод перенаправлять в logger с соответствующим тегом. Если настроите не в syslog, то обязательна ротация логов.
	
* Запустите стенд на 30 минут.
* Убедитесь что резервные копии снимаются.
* Остановите бекап, удалите (или переместите) директорию /etc и восстановите ее из бекапа.
* Для сдачи домашнего задания ожидаем настроенные стенд, логи процесса бэкапа и описание процесса восстановления.

# **Выполнение**

При запуске стенда в Vagrant файле создаётся дополнительный диск на 3 Гб.

А так же в файлах backup.sh и client.sh прописаны следующие команды

для сервера backup:

```
# Подключаем EPEL репозиторий с дополнительными пакетами
yum install -y epel-release

# Устанавливаем на client и backup сервере borgbackup
yum install -y borgbackup mc nano

# Cоздаем пользователя
useradd -m borg

# Cоздаем каталог и назначаем 
sudo mkdir /var/backup

# Назначаем владельца borg
sudo chown -R borg:borg /var/backup/

# Создаем каталог .ssh в каталоге /home/borg
sudo mkdir /home/borg/.ssh

# Создаем файл
sudo touch /home/borg/.ssh/authorized_keys

# Назначем права и владельца на каталог и файл
sudo chmod 700 /home/borg/.ssh
sudo chmod 600 /home/borg/.ssh/authorized_keys
sudo chown -R borg:borg  /home/borg/.ssh
```

для сервера client:

```
# Подключаем EPEL репозиторий с дополнительными пакетами
yum install -y epel-release

# Устанавливаем на client и backup сервере borgbackup
yum install -y borgbackup mc nano

# Создаем сервис

sudo touch /etc/systemd/system/borg-backup.service

sudo cat <<EOT >> /etc/systemd/system/borg-backup.service
[Unit]
Description=Borg Backup

[Service]
Type=oneshot

# Парольная фраза
Environment=BORG_PASSPHRASE=1

# Репозиторий
Environment=REPO=borg@192.168.11.160:/var/backup/

# Что бэкапим
Environment=BACKUP_TARGET=/etc

# Создание бэкапа
ExecStart=/bin/borg create \\
--stats \\
\${REPO}::etc-{now:%%Y-%%m-%%d_%%H:%%M:%%S} \${BACKUP_TARGET}

# Проверка бэкапа
ExecStart=/bin/borg check \${REPO}

# Очистка старых бэкапов
ExecStart=/bin/borg prune \\
--keep-daily 90 \\
--keep-monthly 12 \\
--keep-yearly 1 \\
\${REPO} 
EOT

# Создаем таймер

sudo touch /etc/systemd/system/borg-backup.timer

sudo cat <<EOT >> /etc/systemd/system/borg-backup.timer
[Unit]
Description=Borg Backup

[Timer]
OnUnitActiveSec=5min
Unit=borg-backup.service

[Install]
WantedBy=timers.target
EOT
```

После запуска стенда (vagrant up) заходим на сервер backup
```
vagrant ssh backup
```

Смотрим диски
```
lsblk

	NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
	sda      8:0    0  40G  0 disk
	`-sda1   8:1    0  40G  0 part /
	sdb      8:16   0   3G  0 disk
```

Заходим в fdisk для настройки дополнительного диска sdb
```
sudo -i
fdisk /dev/sdb

Command (m for help): n

Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
Select (default p): p
Partition number (1-4, default 1): 1
First sector (2048-6291455, default 2048):
Using default value 2048
Last sector, +sectors or +size{K,M,G} (2048-6291455, default 6291455):
Using default value 6291455
Partition 1 of type Linux and of size 3 GiB is set

Command (m for help): t

Selected partition 1
Hex code (type L to list all codes): 83
Changed type of partition 'Linux' to 'Linux'

Command (m for help): p

Disk /dev/sdb: 3221 MB, 3221225472 bytes, 6291456 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x9cdc7190
   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1            2048     6291455     3144704   83  Linux

Command (m for help): w

The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.
```

Отформатируем в xfs
```
mkfs -t xfs /dev/sdb1
```

Примонтируем диск в каталог /var/backup
```
mount -w /dev/sdb1 /var/backup/
chown -R borg:borg /var/backup/
```

Проверим
```
mount | grep sdb1

	/dev/sdb1 on /var/backup type xfs (rw,relatime,seclabel,attr2,inode64,noquota)
```

Добавим строку в файл /etc/fstab, чтобы при запуске системы данный диск монтировался
```
#echo "/dev/sdb1            /var/backup                    xfs     defaults        0 0" >> /etc/fstab
sed -i '$a /dev/sdb1            /var/backup                    xfs     defaults        0 0' /etc/fstab
```

Теперь запускаем вторую консоль и заходим на сервер client
```
vagrant ssh client
```

Генерируем ssh-ключ и добавляем его на сервер backup в файл authorized_keys
```
ssh-keygen
```

Проверяем
```
ls -la .ssh

	-rw-------. 1 vagrant vagrant  389 Nov  4 15:15 authorized_keys
	-rw-------. 1 vagrant vagrant 1675 Nov  5 08:18 id_rsa
	-rw-r--r--. 1 vagrant vagrant  396 Nov  5 08:18 id_rsa.pub
```

Скопируем содержимое файла id_rsa.pub и вставим его в файл authorized_keys на сервере backup пользователю borg
```
cat .ssh/id_rsa.pub
```

На сервере backup
```
nano /home/borg/.ssh/authorized_keys
```

Переходим на сервер client.

Инициализируем репозиторий borg на backup сервере с client сервера
```
borg upgrade --disable-tam ssh://borg@192.168.11.160/var/backup
borg init --encryption=repokey borg@192.168.11.160:/var/backup/
```

Задаём пароль.

Запускаем для проверки создания бэкапа
```
borg create --stats --list borg@192.168.11.160:/var/backup/::etc-{now:%Y-%m-%d_%H:%M:%S} /etc
```

Смотрим, что у нас получилось
```
borg list borg@192.168.11.160:/var/backup/

	etc-2022-11-05_11:29:50              Sat, 2022-11-05 11:29:54 [491a5bb88a0562bc47a3145eedd28c4a5d9a9757c240eaba7cbb8e1a06543430]
```

Смотрим список файлов
```
borg list borg@192.168.11.160:/var/backup/::etc-2022-11-05_11:29:50
```

Достаем файл из бекапа
```
borg extract borg@192.168.11.160:/var/backup/::etc-2022-11-05_11:29:50 etc/hostname
```

Смотрим, находясь в домашнем каталоге пользователя Vagrant сервера client
```
cat etc/hostname

	client
```

Автоматизируем создание бэкапов с помощью systemd.
В Vagrant файле, ранее создалось два файла: borg-backup.service (сервис) и borg-backup.timer (таймер).

Включаем и запускаем службу таймера
```
sudo systemctl enable borg-backup.timer
sudo systemctl start borg-backup.timer
```

Проверяем статус
```
sudo systemctl status borg-backup.timer

	● borg-backup.timer - Borg Backup
	   Loaded: loaded (/etc/systemd/system/borg-backup.timer; enabled; vendor preset: disabled)
	   Active: active (waiting) since Mon 2022-11-07 13:44:15 UTC; 1 day 16h ago

	Nov 07 13:44:15 client systemd[1]: Started Borg Backup.
```

Проверяем работу таймера
```
systemctl list-timers --all

	NEXT                         LEFT          LAST                         PASSED      UNIT                         ACTIVATES
	Wed 2022-11-09 06:21:21 UTC  1min 53s left Wed 2022-11-09 06:16:21 UTC  3min 6s ago borg-backup.timer            borg-backup.service
	Wed 2022-11-09 09:23:31 UTC  3h 4min left  Tue 2022-11-08 09:23:31 UTC  20h ago     systemd-tmpfiles-clean.timer systemd-tmpfiles-clean.service
	n/a                          n/a           n/a                          n/a         systemd-readahead-done.timer systemd-readahead-done.service

3 timers listed.
```

Проверяем список бекапов
```
borg list borg@192.168.11.160:/var/backup/

	etc-2022-11-05_11:29:50              Sat, 2022-11-05 11:29:54 [491a5bb88a0562bc47a3145eedd28c4a5d9a9757c240eaba7cbb8e1a06543430]
	etc-2022-11-06_16:16:31              Sun, 2022-11-06 16:16:32 [17463ee523f05a4120afa93c696c7d5a25a14bace31a7903ff5e833ba0d38d92]
	etc-2022-11-07_23:57:24              Mon, 2022-11-07 23:57:25 [935a5dc7c4087524cc8adf42e5622fda36436b6b9f4706eeb0b99403fa76ec66]
	etc-2022-11-08_23:55:35              Tue, 2022-11-08 23:55:36 [7a02d4d74d5fc7ec00e863b3a585fff40530874764a6f4463dddc47073c9ccae]
	etc-2022-11-09_06:11:20              Wed, 2022-11-09 06:11:21 [e780efdcbd733e7676267cee07ec16e1d85095352bc3455119d8ef34ed187fe2]
```

Логи работы сервиса, можно посмотреть
```
sudo journalctl -xeu borg-backup.service
sudo journalctl -u borg-backup.service
```
