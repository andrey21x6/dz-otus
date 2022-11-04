#!/bin/bash

# Подключаем EPEL репозиторий с дополнительными пакетами
yum install -y epel-release

# Устанавливаем на client и backup сервере borgbackup
yum install -y borgbackup mc nano

# Cоздаем пользователя
useradd -m borg

# Cоздаем каталог
sudo mkdir /var/backup

# Назначаем права
sudo chown borg:borg /var/backup/

# Создаем каталог .ssh в каталоге /home/borg
sudo mkdir /home/borg/.ssh

# Создаем файл
sudo touch /home/borg/.ssh/authorized_keys

# Назначем права на каталог и файл
sudo chmod 700 /home/borg/.ssh
sudo chmod 600 /home/borg/.ssh/authorized_keys

###########################################################

#mount -w /dev/sdb /var/backup/
#nano /etc/fstab
#/dev/sdb            /var/backup                    ext4     defaults        0 0
