#!/bin/bash

ipDb1=192.168.80.11
ipDb2=192.168.80.12
hostNameDb1=database1
loginReplicatuser=repluser
nameDb=demodb

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
echo " *** Установка wget ***"
echo ""
dnf install wget -y

echo ""
echo " *** Скачивается файл sshpass-1.09-4.el8.x86_64.rpm ***"
echo ""
wget -O /home/vagrant/sshpass-1.09-4.el8.x86_64.rpm http://mirror.centos.org/centos/8-stream/AppStream/x86_64/os/Packages/sshpass-1.09-4.el8.x86_64.rpm

echo ""
echo " *** Установка sshpass ***"
echo ""
rpm -ivh /home/vagrant/sshpass-1.09-4.el8.x86_64.rpm

echo ""
echo " *** Установка postgresql-server ***"
echo ""
dnf install postgresql-server -y

echo ""
echo " *** Иницилизация postgresql-server ***"
echo ""
postgresql-setup --initdb

echo ""
echo " *** Создаются каталоги archive_{c,b} ***"
echo ""
su - postgres -c "mkdir archive_{c,b}"

echo ""
echo " *** Включить автозапуск и запустить (--now) postgresql-server ***"
echo ""
systemctl enable postgresql --now

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

#============================================================= УСЛОВИЯ IF ELSE ===============================================================================================

if [ "${HOSTNAME}" = "${hostNameDb1}" ]; then   #-------------------------------------------- Если hostNameDb1 ---------------------------------------------------------------

echo ""
echo " *** Разрешение на выполнение backup.sh u+x ***"
echo ""
chmod u+x /home/vagrant/backup.sh

echo ""
echo " *** Добавляется в cron задание (каждый день в 1 час ночи backup) ***"
echo ""
echo "00 1 * * * root /home/vagrant/backup.sh" >> /etc/crontab
#echo "0 * * * * root /home/vagrant/backup.sh" >> /etc/crontab
#echo "* * * * * root /home/vagrant/backup.sh" >> /etc/crontab

echo ""
echo " *** Изменение в конфиг файле postgresql.conf значения listen_addresses ***"
echo ""
sed -i -e "s/#listen_addresses = 'localhost'/listen_addresses = '${ipDb1}'/g" /var/lib/pgsql/data/postgresql.conf

echo ""
echo " *** Добавление в конфиг файл pg_hba.conf значения host ***"
echo ""
echo "host    replication    ${loginReplicatuser}         ${ipDb2}/32        trust" >> /var/lib/pgsql/data/pg_hba.conf

echo ""
echo " *** Изменение в конфиг файле postgresql.conf значения wal_level ***"
echo ""
sed -i -e "s/#wal_level = replica/wal_level = replica/g" /var/lib/pgsql/data/postgresql.conf

echo ""
echo " *** Изменение в конфиг файле postgresql.conf значения archive_mode ***"
echo ""
sed -i -e "s/#archive_mode = off/archive_mode = on/g" /var/lib/pgsql/data/postgresql.conf

echo ""
echo " *** Изменение в конфиг файле postgresql.conf значения archive_command ***"
echo ""
sed -i -e "s/#archive_command = ''/archive_command = 'test ! -f \/var\/lib\/pgsql\/archive_c\/%f \&\& cp %p \/var\/lib\/pgsql\/archive_c\/%f'/g" /var/lib/pgsql/data/postgresql.conf

echo ""
echo " *** Изменение в конфиг файле postgresql.conf значения hot_standby_feedback ***"
echo ""
sed -i -e "s/#hot_standby_feedback = off/hot_standby_feedback = on/g" /var/lib/pgsql/data/postgresql.conf

echo ""
echo " *** Перезапуск postgresql ***"
echo ""
systemctl restart postgresql

echo ""
echo " *** Создание пользователя БД ${loginReplicatuser} для репликации ***"
echo ""
su - postgres -c "createuser --replication ${loginReplicatuser}"

echo ""
echo " *** Создание копии БД в архиве в каталоге archive_b ***"
echo ""
su - postgres -c "pg_basebackup -D archive_b/ -Ft -z"

echo ""
echo " *** Создание БД ${nameDb} ***"
echo ""
su - postgres -c "psql -c 'create database ${nameDb}'"

echo ""
echo " *** Создание таблицы ***"
echo ""
su - postgres -c "psql" <<EOF
\c ${nameDb}
create table tab01 (col01 int, col02 varchar(20));
EOF

echo ""
echo " *** Вставка записи в таблицу ***"
echo ""
su - postgres -c "psql" <<EOF
\c ${nameDb}
insert into tab01 values (1, 'MariaDB'), (2, 'PostgreSQL');
EOF

echo ""
echo " *** Создание логической копии БД ${nameDb} в каталоге backups ***"
echo ""
su - postgres -c "pg_dump ${nameDb} > backups/${nameDb}.dump"

else   #-------------------------------------------------------------------- Иначе если hostNameDb2 --------------------------------------------------------------------------

echo ""
echo " *** Остановка postgresql ***"
echo ""
systemctl stop postgresql

echo ""
echo " *** Удаление каталогов и файлов в каталоге БД /var/lib/pgsql/data ***"
echo ""
rm -rf /var/lib/pgsql/data/*

echo ""
echo " *** Копируется каталоги и файлы БД c ${hostNameDb1} ***"
echo ""
su - postgres -c "pg_basebackup -P --host=${ipDb1} --username=${loginReplicatuser} --pgdata=/var/lib/pgsql/data/ --progress --checkpoint=fast --wal-method=stream --write-recovery-conf"

echo ""
echo " *** Изменение прав на каталоги и файлы БД /var/lib/pgsql/data ***"
echo ""
chown -R postgres:postgres /var/lib/pgsql/data/

echo ""
echo " *** Изменение в конфиг файле postgresql.conf значения listen_addresses ***"
echo ""
sed -i -e "s/listen_addresses = '${ipDb1}'/listen_addresses = '${ipDb2}'/g" /var/lib/pgsql/data/postgresql.conf

echo ""
echo " *** Старт postgresql ***"
echo ""
systemctl start postgresql

fi

#============================================================= КОНЕЦ УСЛОВИЯ IF ELSE =========================================================================================