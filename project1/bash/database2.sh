#!/bin/bash

echo ""
echo " *** Установка mariadb ***"
echo ""
dnf install mariadb mariadb-server -y

echo ""
echo " *** Разрешить доступ к БД с любого IP по порту 3306 ***"
echo ""
sed -i -e "s/\#bind-address=0.0.0.0/bind-address=0.0.0.0/g" /etc/my.cnf.d/mariadb-server.cnf

echo ""
echo " *** Для настройки репликации прописываем server-id для database2 равное 2 ***"
echo ""
sed -i '/'bind-address=0.0.0.0'/a server-id = 2'  /etc/my.cnf.d/mariadb-server.cnf

echo ""
echo " *** Для настройки репликации прописываем файл лога ***"
echo ""
sed -i '/'"server-id = 2"'/a log_bin = /var/log/mariadb/mariadb-bin.log'  /etc/my.cnf.d/mariadb-server.cnf

echo ""
echo " *** Старт mariadb ***"
echo ""
systemctl start mariadb

echo ""
echo " *** Включаем автозапуск mariadb ***"
echo ""
systemctl enable mariadb

echo ""
echo " *** Разрешение в SELinux на на удалённое подключение к mariadb ***"
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
echo " *** Создаём файл для автоматического подключения к mysql ***"
echo ""
touch /root/.my.cnf

echo ""
echo " *** Прописываем параметры для подключения к mysql ***"
echo ""
cat > /root/.my.cnf <<EOF
[client]
user=root
password=123456
EOF

echo ""
echo " *** Изменяем права доступа к файлу ***"
echo ""
chmod 600 /root/.my.cnf

echo ""
echo " *** Разрешение на удалённое подключение к mariadb (с любого IP) и создаём пользователя с разрешением на репликацию ***"
echo ""
mysql <<EOF
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '123456';
GRANT replication slave ON *.* TO "replicatuser"@"192.168.90.15" IDENTIFIED BY "passuser";
EOF

echo ""
echo " *** Созданём БД project1 ***"
echo ""
mysql -e 'CREATE DATABASE project1'

echo ""
echo " *** Импорт БД project1 ***"
echo ""
mysql project1 < project1.sql

echo ""
echo " *** Создаём каталог ***"
echo ""
mkdir BACKUP

echo ""
echo " *** Разрешаем файл на исполнение ***"
echo ""
chmod +x backup.sh

echo ""
echo " *** Добавляем в cron задание (каждый день в 1 час ночи) с проверкой от дублирования ***"
echo ""
echo "00 1 * * * root /home/vagrant/backup.sh" >> /etc/crontab
#echo "0 * * * * root /home/vagrant/backup.sh" >> /etc/crontab
#echo "* * * * * root /home/vagrant/backup.sh" >> /etc/crontab

#echo ""
#echo " *** Получаем в переменные окружения строки File (имя файла) и Position (номер позиции) из состояния двоичных файлов журнала сервера database1 ***"
#echo ""
#stroka=`mysql -h 192.168.90.15 -e 'SHOW MASTER STATUS \G' | grep 'File';` ; eval $(echo $stroka | sed 's:^:V3=":; /File: / s::";V1=": ;s:$:":')
#stroka=`mysql -h 192.168.90.15 -e 'SHOW MASTER STATUS \G' | grep 'Position';` ; eval $(echo $stroka | sed 's:^:V4=":; /Position: / s::";V2=": ;s:$:":')

echo ""
echo " *** Создаём запись на сервере database2 для настройки репликации в качестве slave (database1 - Master) ***"
echo ""
#mysql -e 'change master to master_host = "192.168.90.15", master_user = "replicatuser", master_password = "passuser", master_log_file = "'$V1'", master_log_pos = '$V2''
mysql -e 'change master to master_host = "192.168.90.15", master_user = "replicatuser", master_password = "passuser", master_use_gtid=slave_pos'

echo ""
echo " *** Запускаем сервер репликации на сервере database2 ***"
echo ""
mysql -e 'start slave'

#echo ""
#echo " *** Получаем в переменные окружения строки File (имя файла) и Position (номер позиции) из состояния двоичных файлов журнала сервера database2 ***"
#echo ""
#stroka=`mysql -e 'SHOW MASTER STATUS \G' | grep 'File';` ; eval $(echo $stroka | sed 's:^:V3=":; /File: / s::";V1=": ;s:$:":')
#stroka=`mysql -e 'SHOW MASTER STATUS \G' | grep 'Position';` ; eval $(echo $stroka | sed 's:^:V4=":; /Position: / s::";V2=": ;s:$:":')

#echo ""
#echo " *** Создаём запись на сервере database1 для настройки репликации в качестве slave (database2 - Master) ***"
#echo ""
#mysql -h 192.168.90.15 -e 'change master to master_host = "192.168.90.16", master_user = "replicatuser", master_password = "passuser", master_log_file = "'$V1'", master_log_pos = '$V2''
#mysql -h 192.168.90.15 -e 'change master to master_host = "192.168.90.16", master_user = "replicatuser", master_password = "passuser", master_use_gtid=slave_pos'

#echo ""
#echo " *** Запускаем сервер репликации на сервере database1 ***"
#echo ""
#mysql -h 192.168.90.15 -e 'start slave'

echo ""
echo " *** Скачивание filebeat ***"
echo ""
curl -L -o /root/filebeat-8.6.1-x86_64.rpm https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.6.1-x86_64.rpm?_gl=1*xsxx36*_ga*NjU4NjU3ODA3LjE2NzU0MjkzNTg.*_ga_Q7TEQDPTH5*MTY3NTQyOTM1OC4xLjEuMTY3NTQyOTU1Ni4wLjAuMA..

echo ""
echo " ***Установка filebeat ***"
echo ""
rpm -ivh ~/filebeat-8.6.1-x86_64.rpm

echo ""
echo " *** Переименовываем оригинальный конфиг filebeat.yml ***"
echo ""
mv /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml_bak

echo ""
echo " *** Копируем новый конфиг filebeat ***"
echo ""
cp /home/vagrant/filebeat.yml /etc/filebeat/filebeat.yml

echo ""
echo " *** Запускаем filebeat и добавляем в автозагрузку ***"
echo ""
systemctl enable --now filebeat
