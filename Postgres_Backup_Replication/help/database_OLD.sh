#!/bin/bash

#systemctl status postgresql
#psql

###\l - список БД
###su - postgres -c "psql -c '\l'"
###create database demodb;
###\c demodb - подключение к БД demodb
###\db - список табличных пространств
###\dt - список таблиц
###\d tab01 - содержимое таблицы tab01
###\du - вывод пользователей
###select * from tab01;
###su - postgres -c "psql -c '\c demodb' -c 'select * from tab01'"
# Когда импорт, то сначало нужно создать пустую БД (create database demodb;), запускаем с ключом -1 для предотвращение импорта, если есть ошибки в файле дампа
###psql -1 demodb < backups/demodb.dump

# На мастере
#su - postgres -c "psql -c '\c demodb' -c 'select * from pg_stat_replication'"

# На slave
#su - postgres -c "psql -c '\c demodb' -c 'select * from pg_stat_wal_receiver'"

#su - postgres -c "/usr/bin/pg_ctl promote -D /var/lib/pgsql/data/"

###\q выход

#nano /var/lib/pgsql/data/postgresql.conf

ipDb1=192.168.80.11
ipDb2=192.168.80.12
hostNameDb1=database1
hostNameDb2=database2
loginDb=root
passDb=123456
loginReplicatuser=replicatuser
passReplicatuser=passuser
loginBackup=mariabackup
passBackup=123456
nameDb=project1
fileDb=restore_bd.sql
interfaceLan=eth1

#============================================================= УСЛОВИЯ IF ELSE ===============================================================================================

if [ "${HOSTNAME}" = "${hostNameDb1}" ]; then   #--------------------------------- Если hostNameDb1 -------------------------------------------------------

echo ""
echo " *** fping ${ipDb2} ${hostNameDb2} ***"
echo ""
pingOtvet=`fping ${ipDb2}`

    if [ "$pingOtvet" = "${ipDb2} is alive" ]; then   #------------------------------- Если восстановление hostNameDb1 ----------------------------------------------
	
echo ""
echo " *** Поключаемся к hostNameDb2 ***"
echo ""
#sshpass -p 1 ssh -o StrictHostKeyChecking=no root@${ipDb2} 'bash -s' < "/home/vagrant/bash1.sh"
sshpass -p 1 ssh -o StrictHostKeyChecking=no root@${ipDb2} << EOF
echo ""
echo " *** Делаем мастером ${hostNameDb2} ***"
echo ""
su - postgres -c "/usr/bin/pg_ctl promote -D /var/lib/pgsql/data/"

echo ""
echo " *** Изменяется конфиг файл pg_hba.conf на ${hostNameDb2} ***"
echo ""
sed -i -e "s/host    replication    repluser         ${ipDb2}\/32        trust/host    replication    repluser         ${ipDb1}\/32        trust/g" /var/lib/pgsql/data/pg_hba.conf

echo ""
echo " *** Создаются каталоги archive_{c,b} на ${hostNameDb2} ***"
echo ""
su - postgres -c "mkdir archive_{c,b}"

echo ""
echo " *** Перезапуск postgresql на ${hostNameDb2} ***"
echo ""
systemctl restart postgresql

echo ""
echo " *** Создаётся основной архив БД в каталоге archive_b на ${hostNameDb2} ***"
echo ""
su - postgres -c "pg_basebackup -D archive_b/ -Ft -z"

echo ""
echo " *** Создаётся user repluser для репликации на ${hostNameDb2} ***"
echo ""
su - postgres -c "createuser --replication repluser"

echo ""
echo " *** Создаётся backup БД в каталог backups/demodb.dump на ${hostNameDb2} ***"
echo ""
su - postgres -c "pg_dump demodb > backups/demodb.dump"
EOF

echo ""
echo " *** Перешли на hostNameDb1 ***"
echo ""

#---------------------------------------------------------

echo ""
echo " *** Остановка postgresql ***"
echo ""
systemctl stop postgresql

echo ""
echo " *** Удаляются все каталоги и файлы в /var/lib/pgsql/data ***"
echo ""
rm -rf /var/lib/pgsql/data/*

echo ""
echo " *** Тянем backup c 192.168.80.12 ***"
echo ""
su - postgres -c "pg_basebackup -P --host=192.168.80.12 --username=repluser --pgdata=/var/lib/pgsql/data/ --progress --checkpoint=fast --wal-method=stream --write-recovery-conf"

echo ""
echo " *** chown -R postgres:postgres /var/lib/pgsql/data/ ***"
echo ""
chown -R postgres:postgres /var/lib/pgsql/data/

echo ""
echo " *** Удаляется не нужный старый файл recovery.done ***"
echo ""
rm -f /var/lib/pgsql/data/recovery.done

echo ""
echo " *** sed listen_addresses ***"
echo ""
sed -i -e "s/listen_addresses = '192.168.80.12'/listen_addresses = '192.168.80.11'/g" /var/lib/pgsql/data/postgresql.conf

echo ""
echo " *** start postgresql ***"
echo ""
systemctl start postgresql
	
    else   #----------------------------------------------- Иначе, если первый запуск hostNameDb1 -------------------------------------------------------------------

echo ""
echo " *** sed listen_addresses ***"
echo ""
sed -i -e "s/#listen_addresses = 'localhost'/listen_addresses = '192.168.80.11'/g" /var/lib/pgsql/data/postgresql.conf

echo ""
echo " *** host    replication    repluser ***"
echo ""
echo "host    replication    repluser         192.168.80.12/32        trust" >> /var/lib/pgsql/data/pg_hba.conf

echo ""
echo " *** sed wal_level ***"
echo ""
sed -i -e "s/#wal_level = replica/wal_level = replica/g" /var/lib/pgsql/data/postgresql.conf

echo ""
echo " *** sed archive_mode ***"
echo ""
sed -i -e "s/#archive_mode = off/archive_mode = on/g" /var/lib/pgsql/data/postgresql.conf

echo ""
echo " *** sed archive_command ***"
echo ""
sed -i -e "s/#archive_command = ''/archive_command = 'test ! -f \/var\/lib\/pgsql\/archive_c\/%f \&\& cp %p \/var\/lib\/pgsql\/archive_c\/%f'/g" /var/lib/pgsql/data/postgresql.conf

echo ""
echo " *** sed hot_standby_feedback ***"
echo ""
sed -i -e "s/#hot_standby_feedback = off/hot_standby_feedback = on/g" /var/lib/pgsql/data/postgresql.conf

echo ""
echo " *** restart postgresql ***"
echo ""
systemctl restart postgresql

echo ""
echo " *** createuser --replication repluser ***"
echo ""
su - postgres -c "createuser --replication repluser"

echo ""
echo " *** pg_basebackup -D archive_b/ -Ft -z ***"
echo ""
su - postgres -c "pg_basebackup -D archive_b/ -Ft -z"

echo ""
echo " *** create database demodb ***"
echo ""
su - postgres -c "psql -c 'create database demodb'"

echo ""
echo " *** create table tab01 ***"
echo ""
su - postgres -c "psql" <<EOF
\c demodb
create table tab01 (col01 int, col02 varchar(20));
EOF

echo ""
echo " *** insert into tab01 ***"
echo ""
su - postgres -c "psql" <<EOF
\c demodb
insert into tab01 values (1, 'MariaDB'), (2, 'PostgreSQL');
EOF

echo ""
echo " *** pg_dump demodb > backups/demodb.dump ***"
echo ""
su - postgres -c "pg_dump demodb > backups/demodb.dump"
	
    fi

else   #--------------------------------------------------------- Иначе если hostNameDb2 -----------------------------------------------------------------------

echo ""
echo " *** stop postgresql ***"
echo ""
systemctl stop postgresql

echo ""
echo " *** rm -rf /var/lib/pgsql/data/* ***"
echo ""
rm -rf /var/lib/pgsql/data/*

echo ""
echo " *** Тянем backup c 192.168.80.11 ***"
echo ""
su - postgres -c "pg_basebackup -P --host=192.168.80.11 --username=repluser --pgdata=/var/lib/pgsql/data/ --progress --checkpoint=fast --wal-method=stream --write-recovery-conf"

echo ""
echo " *** chown -R postgres:postgres /var/lib/pgsql/data/ ***"
echo ""
chown -R postgres:postgres /var/lib/pgsql/data/

echo ""
echo " *** sed listen_addresses ***"
echo ""
sed -i -e "s/listen_addresses = '192.168.80.11'/listen_addresses = '192.168.80.12'/g" /var/lib/pgsql/data/postgresql.conf

echo ""
echo " *** start postgresql ***"
echo ""
systemctl start postgresql

fi

#============================================================= КОНЕЦ УСЛОВИЯ IF ELSE =========================================================================================



sshpass -p 1 ssh -o StrictHostKeyChecking=no root@$192.168.80.12 << EOF
su - postgres -c "psql -c 'select * from pg_stat_replication'"
EOF


select * from pg_stat_replication;
su - postgres -c "psql -h 192.168.80.12 -c 'select * from pg_stat_replication'" | grep row
su - postgres -c "psql -h 192.168.80.12 -u repluser -c 'select * from pg_stat_replication'" | grep row