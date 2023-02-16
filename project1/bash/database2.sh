#!/bin/bash

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
echo " *** Добавляется задание в cron (каждый день в 1 час ночи) с проверкой от дублирования ***"
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
user=root
password=123456

[mariabackup]
user=mariabackup
password=123456
EOF

echo ""
echo " *** Изменяются права доступа к файлу ***"
echo ""
chmod 600 /root/.my.cnf

echo ""
echo " *** Включается автозапуск mariadb ***"
echo ""
systemctl enable mariadb

echo ""
echo " *** Стартует mariadb ***"
echo ""
systemctl start mariadb

echo ""
echo " *** stop slave на database1, если запустили восстановление сервера database2 ***"
echo ""
mysql -h 192.168.90.15 -e 'stop slave'

echo ""
echo " *** Разрешается в SELinux удалённое подключение к mariadb ***"
echo ""
setsebool -P httpd_can_network_connect_db 1

echo ""
echo " *** Запуск mysql_secure_installation с подготовленными ответами для автоматизации ***"
echo ""
/usr/bin/mysql_secure_installation <<EOF
 
y
123456
123456
y
n
y
y
EOF

echo ""
echo " *** Разрешение на удалённое подключение к mariadb (с любого IP) и создаётся пользователь с разрешением на репликацию ***"
echo ""
mysql <<EOF
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '123456';
GRANT replication slave ON *.* TO "replicatuser"@"192.168.90.15" IDENTIFIED BY "passuser";
EOF

echo ""
echo " *** Создаётся БД project1 ***"
echo ""
mysql -e 'CREATE DATABASE project1'

echo ""
echo " *** Получаем в переменные окружения строки File (имя файла) и Position (номер позиции) из состояния двоичных файлов журнала сервера database1 ***"
echo ""
stroka=`mysql -h 192.168.90.15 -e 'SHOW MASTER STATUS \G' | grep 'File';` ; eval $(echo $stroka | sed 's:^:V3=":; /File: / s::";V1=": ;s:$:":')
stroka=`mysql -h 192.168.90.15 -e 'SHOW MASTER STATUS \G' | grep 'Position';` ; eval $(echo $stroka | sed 's:^:V4=":; /Position: / s::";V2=": ;s:$:":')

echo ""
echo " *** Экспортируется БД из database1 ***"
echo ""
sshpass -p 1 ssh -o StrictHostKeyChecking=no root@192.168.90.15 <<EOF
mysqldump --single-transaction project1 > /home/vagrant/restore_bd.sql
chown vagrant:vagrant /home/vagrant/restore_bd.sql
exit
EOF

echo ""
echo " *** Копируется файла дампа с сервера database1 на сервер database2 ***"
echo ""
sshpass -p vagrant scp -o StrictHostKeyChecking=no -P 22 vagrant@192.168.90.15:/home/vagrant/restore_bd.sql /home/vagrant/restore_bd.sql

echo ""
echo " *** Импортируется БД в database2 ***"
echo ""
mysql project1 < /home/vagrant/restore_bd.sql

echo ""
echo " *** Создаётся запись на сервере database2 для настройки репликации в качестве slave (database1 - Master) ***"
echo ""
mysql -e 'change master to master_host = "192.168.90.15", master_user = "replicatuser", master_password = "passuser", master_log_file = "'$V1'", master_log_pos = '$V2''

echo ""
echo " *** Запускается репликация на сервере database2 ***"
echo ""
mysql -e 'start slave'

#---------------------------------------------------------

echo ""
echo " *** Получаем в переменные окружения строки File (имя файла) и Position (номер позиции) из состояния двоичных файлов журнала сервера database2 ***"
echo ""
stroka=`mysql -e 'SHOW MASTER STATUS \G' | grep 'File';` ; eval $(echo $stroka | sed 's:^:V3=":; /File: / s::";V1=": ;s:$:":')
stroka=`mysql -e 'SHOW MASTER STATUS \G' | grep 'Position';` ; eval $(echo $stroka | sed 's:^:V4=":; /Position: / s::";V2=": ;s:$:":')

echo ""
echo " *** Создаётся запись на сервере database1 для настройки репликации в качестве slave (database2 - Master) ***"
echo ""
mysql -h 192.168.90.15 -e 'change master to master_host = "192.168.90.16", master_user = "replicatuser", master_password = "passuser", master_log_file = "'$V1'", master_log_pos = '$V2''

echo ""
echo " *** Запускается репликация на сервере database1 ***"
echo ""
mysql -h 192.168.90.15 -e 'start slave'
