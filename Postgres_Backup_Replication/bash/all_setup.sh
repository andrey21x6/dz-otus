#!/bin/bash

echo ""
echo " *** Установка временной зоны Asia/Yekaterinburg ***"
echo ""
timedatectl set-timezone Asia/Yekaterinburg

echo ""
echo " *** Перезапуск сервиса cron после смены часового пояса ***"
echo ""
systemctl restart crond.service

echo ""
echo " *** Настройка репозитория ***"
echo ""
sed -i -e "s|mirrorlist=|#mirrorlist=|g" /etc/yum.repos.d/CentOS-*
sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g" /etc/yum.repos.d/CentOS-*
dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y

echo ""
echo " *** Настройка кодировки UTF-8 ***"
echo ""
localectl set-locale LANG=en_US.UTF-8
dnf install langpacks-en glibc-all-langpacks -y

echo ""
echo " *** Установка mc ***"
echo ""
dnf install mc -y

echo ""
echo " *** Установка nano ***"
echo ""
dnf install nano -y

echo ""
echo " *** Установка net-tools ***"
echo ""
dnf install net-tools -y

echo ""
echo " *** Установка telnet ***"
echo ""
dnf install telnet -y

echo ""
echo " *** Установка htop ***"
echo ""
dnf install htop -y

echo ""
echo " *** Включение SSH по паролю ***"
echo ""
sed -i -e "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config

echo ""
echo " *** Установка пароля root ***"
echo ""
echo root:1 | /usr/sbin/chpasswd
#yes 1 | passwd root

echo ""
echo " *** Рестарт службы SSH ***"
echo ""
systemctl restart sshd



#systemctl status postgresql
#psql
###\l - список БД
###create database demodb;
###\c demodb - подключение к БД demodb
###\db - список табличных пространств
###\dt - список таблиц
###\d tab01 - содержимое таблицы tab01
###\du - вывод пользователей
###\q выход
#nano /var/lib/pgsql/data/postgresql.conf



dnf install postgresql-server -y

postgresql-setup --initdb

# Включить автозапуск и запустить (--now) postgresql
systemctl enable postgresql --now



mkdir archive_{c,b}

cp /var/lib/pgsql/data/postgresql.conf /var/lib/pgsql/data/postgresql.conf_bak
cp /var/lib/pgsql/data/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf_bak

sed -i -e "s/#listen_addresses = 'localhost'/listen_addresses = '192.168.80.11'/g" /var/lib/pgsql/data/postgresql.conf

echo "host    replication    repluser         192.168.80.12/32        trust" >> /var/lib/pgsql/data/pg_hba.conf

sed -i -e "s/#wal_level = replica/wal_level = replica/g" /var/lib/pgsql/data/postgresql.conf

sed -i -e "s/#archive_mode = off/archive_mode = on/g" /var/lib/pgsql/data/postgresql.conf

sed -i -e "s/#archive_command = ''/archive_command = 'test ! -f \/var\/lib\/pgsql\/archive_c\/%f \&\& cp %p \/var\/lib\/pgsql\/archive_c\/%f'/g" /var/lib/pgsql/data/postgresql.conf

sed -i -e "s/#hot_standby_feedback = off/hot_standby_feedback = on/g" /var/lib/pgsql/data/postgresql.conf

systemctl restart postgresql



# Переход в пользователя postgres
su - postgres

createuser --replication -P repluser
123456
123456

pg_basebackup -D archive_b/ -Ft -z

psql

create database demodb;

create table tab01 (col01 int, col02 varchar(20));

insert into tab01 values (1, 'MariaDB'), (2, 'PostgreSQL');

select * from tab01;

\q



exit

pg_dump demodb > backups/demodb.dump
# Когда импорт, то сначало нужно создать пустую БД (create database demodb;), запускаем с ключом -1 для предотвращение импорта, если есть ошибки в файле дампа
psql -1 demodb < backups/demodb.dump



========================================== slave =======================================



systemctl stop postgresql

rm -rf /var/lib/pgsql/data/*

pg_basebackup -P --host=192.168.80.11 --username=repluser --pgdata=/var/lib/pgsql/data/ --progress --checkpoint=fast --wal-method=stream --write-recovery-conf
#su - postgres -c "pg_basebackup -P --host=192.168.80.11 --username=repluser --pgdata=/var/lib/pgsql/data/ --progress --checkpoint=fast --wal-method=stream --write-recovery-conf"

chown -R postgres:postgres /var/lib/pgsql/data/

sed -i -e "s/listen_addresses = '192.168.80.11'/listen_addresses = '192.168.80.12'/g" /var/lib/pgsql/data/postgresql.conf

systemctl start postgresql

# На мастере
#select * from pg_stat_replication;

# На slave
#select * from pg_stat_wal_receiver;

# На мастере
su - postgres -c "psql"