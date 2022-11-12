#!/bin/bash

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
