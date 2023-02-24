#!/bin/bash

ipDb1=192.168.90.15
ipDb2=192.168.90.16
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

if [ "${HOSTNAME}" = "${hostNameDb1}" ]; then
    serverid=1
    replicatuserIp="${ipDb2}"
else
    serverid=2
    replicatuserIp="${ipDb1}"
fi

echo ""
echo " *** Установка mariadb ***"
echo ""
dnf install mariadb mariadb-server -y

echo ""
echo " *** Установка mariadb-backup ***"
echo ""
dnf install mariadb-backup -y

echo ""
echo " *** Установка fping ***"
echo ""
dnf install fping -y

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

# Изменение логики использования файла подкачки
# 0: подкачка отключена
# 1: минимальный объем подкачки без полного отключения
# 10: рекомендуемое значение для повышения производительности при наличии достаточного объема памяти в системе
# 100: агрессивная подкачка

echo ""
echo " *** Изменение логики использования файла подкачки, устанавливаем vm.swappiness=1 ***"
echo ""
sysctl -w vm.swappiness=1
echo vm.swappiness = 1 >> /etc/sysctl.conf

echo ""
echo " *** Создаётся каталог mariabackup ***"
echo ""
mkdir -p /home/vagrant/BACKUP/mariabackup

echo ""
echo " *** Создаётся каталог SQL ***"
echo ""
mkdir -p BACKUP/SQL

echo ""
echo " *** Разрешение на выполнение backup.sh +x ***"
echo ""
chmod +x backup.sh

echo ""
echo " *** Добавляется в cron задание (каждый день в 1 час ночи backup) ***"
echo ""
echo "00 1 * * * root /home/vagrant/backup.sh" >> /etc/crontab
#echo "0 * * * * root /home/vagrant/backup.sh" >> /etc/crontab
#echo "* * * * * root /home/vagrant/backup.sh" >> /etc/crontab

echo ""
echo " *** Разрешить доступ к БД с любого IP (порт 3306) ***"
echo ""
sed -i -e "s/\#bind-address=0.0.0.0/bind-address=0.0.0.0/g" /etc/my.cnf.d/mariadb-server.cnf

echo ""
echo " *** Для настройки репликации параметр server-id равное 1 в файле mariadb-server.cnf для ${HOSTNAME} ***"
echo ""
sed -i '/'bind-address=0.0.0.0'/a server-id = '"${serverid}"''  /etc/my.cnf.d/mariadb-server.cnf

echo ""
echo " *** Для настройки репликации прописывается путь к файлу bin-лога mariadb-bin.log ***"
echo ""
sed -i '/'"server-id = ${serverid}"'/a log_bin = /var/log/mariadb/mariadb-bin.log'  /etc/my.cnf.d/mariadb-server.cnf

echo ""
echo " *** Создаётся файл с логинами и паролями для подключения к mysql ***"
echo ""
touch /root/.my.cnf

echo ""
echo " *** Прописываются логины и пароли для подключения к mysql ***"
echo ""
cat > /root/.my.cnf <<EOF
[client]
user=${loginDb}
password=${passDb}

[mariabackup]
user=${loginBackup}
password=${passBackup}
EOF

echo ""
echo " *** Изменяются права доступа к файлу .my.cnf 600 ***"
echo ""
chmod 600 /root/.my.cnf

echo ""
echo " *** Временно блокируется доступ к ${HOSTNAME} с интерфейса ${interfaceLan} ***"
echo ""
iptables -A INPUT -i ${interfaceLan} -m tcp -p tcp --dport 3306 -j DROP

echo ""
echo " *** Автозапуск mariadb ***"
echo ""
systemctl enable mariadb

echo ""
echo " *** Старт mariadb ***"
echo ""
systemctl start mariadb

echo ""
echo " *** Разрешение в SELinux на на удалённое подключение к mariadb httpd_can_network_connect_db 1 ***"
echo ""
setsebool -P httpd_can_network_connect_db 1

echo ""
echo " *** Запуск mysql_secure_installation с подготовленными автоответами ***"
echo ""
/usr/bin/mysql_secure_installation <<EOF
 
y
${passDb}
${passDb}
y
n
y
y
EOF

echo ""
echo " *** Создаётся пользователь БД и устанавливаются права для работы с mariabackup ***"
echo ""
mysql <<EOF
CREATE USER '${loginBackup}'@'localhost' IDENTIFIED BY '${passBackup}';
GRANT RELOAD, PROCESS, LOCK TABLES, REPLICATION CLIENT ON *.* TO '${loginBackup}'@'localhost';
GRANT CREATE ON PERCONA_SCHEMA.* TO '${loginBackup}'@'localhost';
GRANT INSERT ON PERCONA_SCHEMA.* TO '${loginBackup}'@'localhost';
EOF

echo ""
echo " *** Создаётся БД ${nameDb} ***"
echo ""
mysql -e 'CREATE DATABASE '"${nameDb}"''

echo ""
echo " *** Разрешение на удалённое подключение к mariadb (с любого IP) и создаём пользователя с разрешением на репликацию ***"
echo ""
mysql <<EOF
GRANT ALL PRIVILEGES ON *.* TO '${loginDb}'@'%' IDENTIFIED BY '${passDb}';
GRANT replication slave ON *.* TO '${loginReplicatuser}'@'${replicatuserIp}' IDENTIFIED BY '${passReplicatuser}';
EOF

#============================================================= УСЛОВИЯ IF ELSE ===============================================================================================

if [ "${HOSTNAME}" = "${hostNameDb1}" ]; then   #--------------------------------- Условие hostNameDb1 или hostNameDb2 -------------------------------------------------------

echo ""
echo " *** fping ${ipDb2} ${hostNameDb2} ***"
echo ""
pingOtvet=`fping ${ipDb2}`

    # mysqladmin --connect-timeout=1 ping --host=127.0.0.1

    if [ "$pingOtvet" = "${ipDb2} is alive" ]; then   #------------------------------- Условие первый запуск или восстановление ----------------------------------------------

echo ""
echo " *** stop slave репликации на ${hostNameDb2}, если запустили восстановление сервера ${hostNameDb1} ***"
echo ""
mysql -h ${ipDb2} -e 'stop slave'

echo ""
echo " *** Получаем в переменные окружения строки File (имя файла) и Position (номер позиции) из состояния двоичных файлов журнала сервера ${hostNameDb2} ***"
echo ""
#strFileName=$(mysql -h ${ipDb2} -e 'SHOW MASTER STATUS \G' | grep 'File';) ; arrayFileName=($(echo $strFileName | tr ': ' ' ')) ; fileName=${arrayFileName[1]}
strFileName=$(mysql -h ${ipDb2} -e 'SHOW MASTER STATUS \G' | grep 'File';) ; arrayFileName=(${strFileName//: / }) ; fileName="${arrayFileName[1]}"
strLogPos=$(mysql -h ${ipDb2} -e 'SHOW MASTER STATUS \G' | grep 'Position';) ; arrayLogPos=(${strLogPos//: / }) ; logPos="${arrayLogPos[1]}"
	
echo ""
echo " *** Экспортируется БД из ${hostNameDb2} ***"
echo ""
sshpass -p 1 ssh -o StrictHostKeyChecking=no root@${ipDb2} <<EOF
mysqldump --single-transaction ${nameDb} > /home/vagrant/${fileDb}
chown vagrant:vagrant /home/vagrant/${fileDb}
exit
EOF

echo ""
echo " *** Копируется файла дампа с сервера ${hostNameDb2} на сервер ${hostNameDb1} ***"
echo ""
sshpass -p vagrant scp -o StrictHostKeyChecking=no -P 22 vagrant@${ipDb2}:/home/vagrant/${fileDb} /home/vagrant/${fileDb}

echo ""
echo " *** Импортируется БД в ${hostNameDb1} ***"
echo ""
mysql ${nameDb} < /home/vagrant/${fileDb}

echo ""
echo " *** Создаётся запись на сервере ${hostNameDb1} для настройки репликации в качестве slave ***"
echo ""
mysql -e 'change master to master_host = "'${ipDb2}'", master_user = "'${loginReplicatuser}'", master_password = "'${passReplicatuser}'", master_log_file = "'${fileName}'", master_log_pos = '${logPos}''

echo ""
echo " *** start slave репликации на сервере ${hostNameDb1} ***"
echo ""
mysql -e 'start slave'

echo ""
echo " *** Пауза для завершения репликации с ${hostNameDb2} на ${hostNameDb1} ...... ***"
echo ""
sleep 10

#-------------------------------

echo ""
echo " *** Получаем в переменные окружения строки File (имя файла) и Position (номер позиции) из состояния двоичных файлов журнала сервера ${hostNameDb1} ***"
echo ""
strFileName=$(mysql -e 'SHOW MASTER STATUS \G' | grep 'File';) ; arrayFileName=(${strFileName//: / }) ; fileName="${arrayFileName[1]}"
strLogPos=$(mysql -e 'SHOW MASTER STATUS \G' | grep 'Position';) ; arrayLogPos=(${strLogPos//: / }) ; logPos="${arrayLogPos[1]}"

echo ""
echo " *** Создаётся запись на сервере ${hostNameDb2} для настройки репликации в качестве slave ***"
echo ""
mysql -h ${ipDb2} -e 'change master to master_host = "'${ipDb1}'", master_user = "'${loginReplicatuser}'", master_password = "'${passReplicatuser}'", master_log_file = "'${fileName}'", master_log_pos = '${logPos}''

echo ""
echo " *** Удаление временной блокировки доступа к ${hostNameDb1} с интерфейса ${interfaceLan} ***"
echo ""
iptables -D INPUT -i ${interfaceLan} -m tcp -p tcp --dport 3306 -j DROP

echo ""
echo " *** start slave репликации на сервере ${hostNameDb2} ***"
echo ""
mysql -h ${ipDb2} -e 'start slave'
	
    else   #----------------------------------------------- Иначе условия первый запуск или восстановление -------------------------------------------------------------------

echo ""
echo " *** Импорт БД ${nameDb} ***"
echo ""
mysql ${nameDb} < ${nameDb}.sql

echo ""
echo " *** Удаление временной блокировки доступа к ${hostNameDb1} с интерфейса ${interfaceLan} ***"
echo ""
iptables -D INPUT -i ${interfaceLan} -m tcp -p tcp --dport 3306 -j DROP
	
    fi

else   #--------------------------------------------------------- Иначе условия hostNameDb1 или hostNameDb2 ----------------------------------------------------------------------

echo ""
echo " *** Получаем в переменные окружения строки File (имя файла) и Position (номер позиции) из состояния двоичных файлов журнала сервера ${hostNameDb1} ***"
echo ""
strFileName=$(mysql -h ${ipDb1} -e 'SHOW MASTER STATUS \G' | grep 'File';) ; arrayFileName=(${strFileName//: / }) ; fileName="${arrayFileName[1]}"
strLogPos=$(mysql -h ${ipDb1} -e 'SHOW MASTER STATUS \G' | grep 'Position';) ; arrayLogPos=(${strLogPos//: / }) ; logPos="${arrayLogPos[1]}"

echo ""
echo " *** Экспортируется БД из ${hostNameDb1} ***"
echo ""
sshpass -p 1 ssh -o StrictHostKeyChecking=no root@${ipDb1} <<EOF
mysqldump --single-transaction ${nameDb} > /home/vagrant/${fileDb}
chown vagrant:vagrant /home/vagrant/${fileDb}
exit
EOF

echo ""
echo " *** Копируется файла дампа с сервера ${hostNameDb1} на сервер ${hostNameDb2} ***"
echo ""
sshpass -p vagrant scp -o StrictHostKeyChecking=no -P 22 vagrant@${ipDb1}:/home/vagrant/${fileDb} /home/vagrant/${fileDb}

echo ""
echo " *** Импортируется БД в ${hostNameDb2} ***"
echo ""
mysql ${nameDb} < /home/vagrant/${fileDb}

echo ""
echo " *** Создаётся запись на сервере ${hostNameDb2} для настройки репликации в качестве slave (${hostNameDb1} - Master) ***"
echo ""
mysql -e 'change master to master_host = "'${ipDb1}'", master_user = "'${loginReplicatuser}'", master_password = "'${passReplicatuser}'", master_log_file = "'${fileName}'", master_log_pos = '${logPos}''

echo ""
echo " *** start slave репликации на сервере ${hostNameDb2} ***"
echo ""
mysql -e 'start slave'

echo ""
echo " *** Пауза для завершения репликации с ${hostNameDb1} на ${hostNameDb2} ...... ***"
echo ""
sleep 10

#-------------------------------

echo ""
echo " *** Получаем в переменные окружения строки File (имя файла) и Position (номер позиции) из состояния двоичных файлов журнала сервера ${hostNameDb2} ***"
echo ""
strFileName=$(mysql -e 'SHOW MASTER STATUS \G' | grep 'File';) ; arrayFileName=(${strFileName//: / }) ; fileName="${arrayFileName[1]}"
strLogPos=$(mysql -e 'SHOW MASTER STATUS \G' | grep 'Position';) ; arrayLogPos=(${strLogPos//: / }) ; logPos="${arrayLogPos[1]}"

echo ""
echo " *** Создаётся запись на сервере ${hostNameDb1} для настройки репликации в качестве slave ***"
echo ""
mysql -h ${ipDb1} -e 'change master to master_host = "'${ipDb2}'", master_user = "'${loginReplicatuser}'", master_password = "'${passReplicatuser}'", master_log_file = "'${fileName}'", master_log_pos = '${logPos}''

echo ""
echo " *** Удаление временной блокировки доступа к ${hostNameDb2} с интерфейса ${interfaceLan} ***"
echo ""
iptables -D INPUT -i ${interfaceLan} -m tcp -p tcp --dport 3306 -j DROP

echo ""
echo " *** start slave репликации на сервере ${hostNameDb1} ***"
echo ""
mysql -h ${ipDb1} -e 'start slave'

fi

#============================================================= КОНЕЦ УСЛОВИЯ IF ELSE =========================================================================================