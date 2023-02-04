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
echo " *** Для настройки репликации прописываем server-id для database1 равное 1 ***"
echo ""
sed -i '/'bind-address=0.0.0.0'/a server-id = 1'  /etc/my.cnf.d/mariadb-server.cnf

echo ""
echo " *** Для настройки репликации прописываем файл лога ***"
echo ""
sed -i '/'"server-id = 1"'/a log_bin = /var/log/mariadb/mariadb-bin.log'  /etc/my.cnf.d/mariadb-server.cnf

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
GRANT replication slave ON *.* TO "replicatuser"@"192.168.90.16" IDENTIFIED BY "passuser";
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
#(crontab -l; echo "00 1 * * * /home/vagrant/backup.sh") | sort -u | crontab -
echo "00 1 * * * root /home/vagrant/backup.sh" >> /etc/crontab

#echo ""
#echo " *** Добавляем в cron задание (каждый час) с проверкой от дублирования ***"
#echo ""
#(crontab -l; echo "0 * * * * /home/vagrant/backup.sh") | sort -u | crontab -

#echo ""
#echo " *** Добавляем в cron задание (каждую минуту) с проверкой от дублирования ***"
#echo ""
#(crontab -l; echo "* * * * * /home/vagrant/backup.sh") | sort -u | crontab -
