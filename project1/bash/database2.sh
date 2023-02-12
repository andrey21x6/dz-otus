#!/bin/bash

echo ""
echo " *** Установка mariadb ***"
echo ""
dnf install mariadb mariadb-server -y

echo ""
echo " *** Создание каталога ***"
echo ""
mkdir BACKUP

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
echo " *** Созданётся БД project1 ***"
echo ""
mysql -e 'CREATE DATABASE project1'

echo ""
echo " *** Экспортируется БД из database1 ***"
echo ""
ssh -o StrictHostKeyChecking=no -i /home/vagrant/database1_private_key vagrant@192.168.90.15 <<EOF
sudo -i
mysqldump --single-transaction project1 > /home/vagrant/restore_bd.sql
chown vagrant:vagrant /home/vagrant/restore_bd.sql
exit
exit
EOF

echo ""
echo " *** Копируется файла дампа с сервера database1 на сервер database2 ***"
echo ""
scp -o StrictHostKeyChecking=no -P 22 -i /home/vagrant/database1_private_key vagrant@192.168.90.15:/home/vagrant/restore_bd.sql /home/vagrant/restore_bd.sql

echo ""
echo " *** Импортируется БД в database2 ***"
echo ""
mysql project1 < /home/vagrant/restore_bd.sql

#=======================================================================================================================================================================================

#echo ""
#echo " *** Получаем в переменные окружения строки File (имя файла) и Position (номер позиции) из состояния двоичных файлов журнала сервера database1 ***"
#echo ""
#stroka=`mysql -h 192.168.90.15 -e 'SHOW MASTER STATUS \G' | grep 'File';` ; eval $(echo $stroka | sed 's:^:V3=":; /File: / s::";V1=": ;s:$:":')
#stroka=`mysql -h 192.168.90.15 -e 'SHOW MASTER STATUS \G' | grep 'Position';` ; eval $(echo $stroka | sed 's:^:V4=":; /Position: / s::";V2=": ;s:$:":')

echo ""
echo " *** Создаётся запись на сервере database2 для настройки репликации в качестве slave (database1 - Master) ***"
echo ""
#mysql -e 'change master to master_host = "192.168.90.15", master_user = "replicatuser", master_password = "passuser", master_log_file = "'$V1'", master_log_pos = '$V2''
mysql -e 'change master to master_host = "192.168.90.15", master_user = "replicatuser", master_password = "passuser", master_use_gtid=current_pos'
#mysql -e 'change master to master_host = "192.168.90.15", master_user = "replicatuser", master_password = "passuser", master_use_gtid=slave_pos'

echo ""
echo " *** Запускается репликация на сервере database2 ***"
echo ""
mysql -e 'start slave'

#--------------------------------------------------------------

#echo ""
#echo " *** Получаем в переменные окружения строки File (имя файла) и Position (номер позиции) из состояния двоичных файлов журнала сервера database2 ***"
#echo ""
#stroka=`mysql -e 'SHOW MASTER STATUS \G' | grep 'File';` ; eval $(echo $stroka | sed 's:^:V3=":; /File: / s::";V1=": ;s:$:":')
#stroka=`mysql -e 'SHOW MASTER STATUS \G' | grep 'Position';` ; eval $(echo $stroka | sed 's:^:V4=":; /Position: / s::";V2=": ;s:$:":')

echo ""
echo " *** Создаётся запись на сервере database1 для настройки репликации в качестве slave (database2 - Master) ***"
echo ""
#mysql -h 192.168.90.15 -e 'change master to master_host = "192.168.90.16", master_user = "replicatuser", master_password = "passuser", master_log_file = "'$V1'", master_log_pos = '$V2''
mysql -h 192.168.90.15 -e 'change master to master_host = "192.168.90.16", master_user = "replicatuser", master_password = "passuser", master_use_gtid=current_pos'
#mysql -h 192.168.90.15 -e 'change master to master_host = "192.168.90.16", master_user = "replicatuser", master_password = "passuser", master_use_gtid=slave_pos'

echo ""
echo " *** Запускается репликация на сервере database1 ***"
echo ""
mysql -h 192.168.90.15 -e 'start slave'

#=======================================================================================================================================================================================

echo ""
echo " *** Копируется новый файл repo ***"
echo ""
cp /home/vagrant/elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo

echo ""
echo " *** Устанавливается filebeat ***"
echo ""
dnf install filebeat -y

echo ""
echo " *** Переименование оригинального конфиг файла filebeat.yml ***"
echo ""
mv /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml_bak

echo ""
echo " *** Копирование нового файла конфига filebeat.yml ***"
echo ""
cp /home/vagrant/filebeat.yml /etc/filebeat/filebeat.yml

echo ""
echo " *** Запускается filebeat и добавляется в автозагрузку ***"
echo ""
systemctl enable --now filebeat
