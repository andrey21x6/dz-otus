#!/bin/bash

ipDb1=192.168.80.11
ipDb2=192.168.80.12
hostNameDb1=database1
hostNameDb2=database2
loginReplicatuser=repluser
nameDb=demodb

#============================================================= УСЛОВИЯ IF ELSE ===============================================================================================

if [ "${HOSTNAME}" = "${hostNameDb1}" ]; then   #-------------------------------------------- Если hostNameDb1 ---------------------------------------------------------------

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
	
    fi

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