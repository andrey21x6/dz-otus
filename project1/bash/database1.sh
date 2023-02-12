#!/bin/bash

echo ""
echo " *** Установка mariadb ***"
echo ""
dnf install mariadb mariadb-server -y

echo ""
echo " *** Установка fping ***"
echo ""
dnf install fping -y

echo ""
echo " *** Установка wget ***"
echo ""
dnf install wget -y

echo ""
echo " *** Скачивается sshpass ***"
echo ""
wget -O /home/vagrant/sshpass-1.09-4.el8.x86_64.rpm http://mirror.centos.org/centos/8-stream/AppStream/x86_64/os/Packages/sshpass-1.09-4.el8.x86_64.rpm

echo ""
echo " *** Установка sshpass ***"
echo ""
rpm -ivh /home/vagrant/sshpass-1.09-4.el8.x86_64.rpm

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
echo " *** Включаем автозапуск mariadb ***"
echo ""
systemctl enable mariadb

echo ""
echo " *** Старт mariadb ***"
echo ""
systemctl start mariadb

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
echo " *** Созданём БД project1 ***"
echo ""
mysql -e 'CREATE DATABASE project1'






#---------- Первый запуск или восстановление ------------

pingOtvet=`fping 192.168.90.16`

if [ "$pingOtvet" = "192.168.90.16 is alive" ]; then

    echo ""
	echo " *** stop slave на database2, если запустили восстановление сервера database1 ***"
	echo ""
	mysql -h 192.168.90.16 -e 'stop slave'
	
else

    echo ""
	echo " *** Импорт БД project1 ***"
	echo ""
	mysql project1 < project1.sql
	
fi

#--------------------------------------------------------








echo ""
echo " *** Разрешение в SELinux на на удалённое подключение к mariadb ***"
echo ""
setsebool -P httpd_can_network_connect_db 1



echo ""
echo " *** Разрешение на удалённое подключение к mariadb (с любого IP) и создаём пользователя с разрешением на репликацию ***"
echo ""
mysql <<EOF
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '123456';
GRANT replication slave ON *.* TO "replicatuser"@"192.168.90.16" IDENTIFIED BY "passuser";
EOF

echo ""
echo " *** Копируем новый файл repo ***"
echo ""
cp /home/vagrant/elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo

echo ""
echo " *** Устанавливаем filebeat ***"
echo ""
dnf install filebeat -y

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
