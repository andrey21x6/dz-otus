#!/bin/bash

# Настройка репозитория
sed -i -e "s|mirrorlist=|#mirrorlist=|g" /etc/yum.repos.d/CentOS-*
sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g" /etc/yum.repos.d/CentOS-*

# Настройка кодировки
localectl set-locale LANG=en_US.UTF-8
dnf install langpacks-en glibc-all-langpacks -y

# Установка программ
dnf install mc nano telnet net-tools -y

# Установка mariadb
dnf install mariadb mariadb-server -y

# Включение SSH по паролю
sed -i -e "s/\PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config

# Установка пароля
echo root:1 | /usr/sbin/chpasswd
#yes 1 | passwd root

# Рестарт службы SSH
systemctl restart sshd

# Разрешить доступ к БД с любого IP по порту 3306
sed -i -e "s/\#bind-address=0.0.0.0/bind-address=0.0.0.0/g" /etc/my.cnf.d/mariadb-server.cnf

# Для настройки репликации master-master
sed -i '/'bind-address=0.0.0.0'/a server-id = 1'  /etc/my.cnf.d/mariadb-server.cnf
sed -i '/'"server-id = 1"'/a log_bin = /var/log/mariadb/mariadb-bin.log'  /etc/my.cnf.d/mariadb-server.cnf

# Разрешение в SELinux на на удалённое подключение к mariadb
setsebool -P httpd_can_network_connect_db 1

# Старт mariadb
systemctl start mariadb

# Запуск mysql_secure_installation с подготовленными ответами для автоматизации
sh /home/vagrant/msi.sh

# Разрешение на удалённое подключение к mariadb (с любого IP)
mysql -h 127.0.0.1 -uroot -p123456 <<EOF
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '123456';
EOF

# Создание БД project1
mysql -h 127.0.0.1 -uroot -p123456 <<EOF
CREATE DATABASE project1;
EOF

# Импорт БД project1
mysql -u root -p123456 project1 < /home/vagrant/project1.sql



STR=`mysql -h 192.168.90.15 -u root -p123456 -e 'SHOW MASTER STATUS \G' | grep 'Position';` ; eval $(echo $STR | sed 's:^:V1=":; /Position: / s::";V2=": ;s:$:":')
STR=`mysql -h 192.168.90.15 -u root -p123456 -e 'SHOW MASTER STATUS \G' | grep 'File';` ; eval $(echo $STR | sed 's:^:V3=":; /File: / s::";V4=": ;s:$:":')
mysql -h 127.0.0.1 -u root -p123456 -e 'GRANT replication slave ON *.* TO "replicatuser"@"192.168.90.15" IDENTIFIED BY "passuser"'
mysql -h 127.0.0.1 -u root -p123456 -e 'change master to master_host = "192.168.90.15", master_user = "replicatuser", master_password = "passuser", master_log_file = "$V4", master_log_pos = '$V2''
mysql -h 127.0.0.1 -u root -p123456 -e 'start slave'
