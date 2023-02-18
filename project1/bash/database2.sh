#!/bin/bash

ipDb1=192.168.90.15
ipDb2=192.168.90.16
passDb=123456
loginDb=root
nameDb=project1
fileDb=restore_bd.sql

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
echo " *** Создаём каталог mariabackup ***"
echo ""
mkdir -p /home/vagrant/BACKUP/mariabackup

echo ""
echo " *** Создаём каталог SQL ***"
echo ""
mkdir -p BACKUP/SQL

echo ""
echo " *** Разрешение файла на исполнение ***"
echo ""
chmod +x backup.sh

echo ""
echo " *** Добавляется задание в cron (каждый день в 1 час ночи) ***"
echo ""
echo "00 1 * * * root /home/vagrant/backup.sh" >> /etc/crontab
#echo "0 * * * * root /home/vagrant/backup.sh" >> /etc/crontab
#echo "* * * * * root /home/vagrant/backup.sh" >> /etc/crontab

echo ""
echo " *** Разрешается доступ к БД с любого IP по порту 3306 ***"
echo ""
sed -i -e "s/\#bind-address=0.0.0.0/bind-address=0.0.0.0/g" /etc/my.cnf.d/mariadb-server.cnf

echo ""
echo " *** Изменяются настройки mariadb-server.cnf для репликации, прописывается server-id равное 2 ***"
echo ""
sed -i '/'bind-address=0.0.0.0'/a server-id = 2'  /etc/my.cnf.d/mariadb-server.cnf

echo ""
echo " *** Изменяются настройки mariadb-server.cnf для репликации, прописывается прописывается путь к файлу лога mariadb-bin.log ***"
echo ""
sed -i '/'"server-id = 2"'/a log_bin = /var/log/mariadb/mariadb-bin.log'  /etc/my.cnf.d/mariadb-server.cnf

echo ""
echo " *** Создаётся файл для автоматического подключения к mysql ***"
echo ""
touch /root/.my.cnf

echo ""
echo " *** Прописываются параметры для подключения к mysql ***"
echo ""
cat > /root/.my.cnf <<EOF
[client]
user=${loginDb}
password=${passDb}

[mariabackup]
user=mariabackup
password=123456
EOF

echo ""
echo " *** Изменяются права доступа к файлу ***"
echo ""
chmod 600 /root/.my.cnf

echo ""
echo " *** Временно блокируется доступ к database2 с интерфейса eth1 ***"
echo ""
iptables -A INPUT -i eth1 -m tcp -p tcp --dport 3306 -j DROP

echo ""
echo " *** Включается автозапуск mariadb ***"
echo ""
systemctl enable mariadb

echo ""
echo " *** Стартует mariadb ***"
echo ""
systemctl start mariadb

echo ""
echo " *** stop slave репликации на database1 ***"
echo ""
mysql -h ${ipDb1} -e 'stop slave'

echo ""
echo " *** Разрешается в SELinux удалённое подключение к mariadb ***"
echo ""
setsebool -P httpd_can_network_connect_db 1

echo ""
echo " *** Запуск mysql_secure_installation с подготовленными ответами для автоматизации ***"
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
CREATE USER 'mariabackup'@'localhost' IDENTIFIED BY '123456';
GRANT RELOAD, PROCESS, LOCK TABLES, REPLICATION CLIENT ON *.* TO 'mariabackup'@'localhost';
GRANT CREATE ON PERCONA_SCHEMA.* TO 'mariabackup'@'localhost';
GRANT INSERT ON PERCONA_SCHEMA.* TO 'mariabackup'@'localhost';
EOF

echo ""
echo " *** Создаётся БД ${nameDb} ***"
echo ""
mysql -e 'CREATE DATABASE '"${nameDb}"''

echo ""
echo " *** Разрешение на удалённое подключение к mariadb (с любого IP) и создаётся пользователь с разрешением на репликацию ***"
echo ""
mysql <<EOF
GRANT ALL PRIVILEGES ON *.* TO '${loginDb}'@'%' IDENTIFIED BY '${passDb}';
GRANT replication slave ON *.* TO "replicatuser"@"${ipDb1}" IDENTIFIED BY "passuser";
EOF

echo ""
echo " *** Получаем в переменные окружения строки File (имя файла) и Position (номер позиции) из состояния двоичных файлов журнала сервера database1 ***"
echo ""
stroka=`mysql -h ${ipDb1} -e 'SHOW MASTER STATUS \G' | grep 'File';` ; eval $(echo $stroka | sed 's:^:V3=":; /File: / s::";V1=": ;s:$:":')
stroka=`mysql -h ${ipDb1} -e 'SHOW MASTER STATUS \G' | grep 'Position';` ; eval $(echo $stroka | sed 's:^:V4=":; /Position: / s::";V2=": ;s:$:":')

echo ""
echo " *** Экспортируется БД из database1 ***"
echo ""
sshpass -p 1 ssh -o StrictHostKeyChecking=no root@${ipDb1} <<EOF
mysqldump --single-transaction ${nameDb} > /home/vagrant/${fileDb}
chown vagrant:vagrant /home/vagrant/${fileDb}
exit
EOF

echo ""
echo " *** Копируется файла дампа с сервера database1 на сервер database2 ***"
echo ""
sshpass -p vagrant scp -o StrictHostKeyChecking=no -P 22 vagrant@${ipDb1}:/home/vagrant/${fileDb} /home/vagrant/${fileDb}

echo ""
echo " *** Импортируется БД в database2 ***"
echo ""
mysql ${nameDb} < /home/vagrant/${fileDb}

echo ""
echo " *** Создаётся запись на сервере database2 для настройки репликации в качестве slave (database1 - Master) ***"
echo ""
mysql -e 'change master to master_host = "'${ipDb1}'", master_user = "replicatuser", master_password = "passuser", master_log_file = "'$V1'", master_log_pos = '$V2''

echo ""
echo " *** start slave репликации на сервере database2 ***"
echo ""
mysql -e 'start slave'

echo ""
echo " *** Пауза для завершения репликации с database1 на database2 ...... ***"
echo ""
sleep 10

#---------------------------------------------------------

echo ""
echo " *** Получаем в переменные окружения строки File (имя файла) и Position (номер позиции) из состояния двоичных файлов журнала сервера database2 ***"
echo ""
stroka=`mysql -e 'SHOW MASTER STATUS \G' | grep 'File';` ; eval $(echo $stroka | sed 's:^:V3=":; /File: / s::";V1=": ;s:$:":')
stroka=`mysql -e 'SHOW MASTER STATUS \G' | grep 'Position';` ; eval $(echo $stroka | sed 's:^:V4=":; /Position: / s::";V2=": ;s:$:":')

echo ""
echo " *** Создаётся запись на сервере database1 для настройки репликации в качестве slave (database2 - Master) ***"
echo ""
mysql -h ${ipDb1} -e 'change master to master_host = "'${ipDb2}'", master_user = "replicatuser", master_password = "passuser", master_log_file = "'$V1'", master_log_pos = '$V2''

echo ""
echo " *** Удаление временной блокировки доступа к database2 с интерфейса eth1 ***"
echo ""
iptables -D INPUT -i eth1 -m tcp -p tcp --dport 3306 -j DROP

echo ""
echo " *** start slave репликации на сервере database1 ***"
echo ""
mysql -h ${ipDb1} -e 'start slave'
