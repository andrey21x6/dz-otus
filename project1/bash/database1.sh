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
	
# Разрешить доступ к БД с любого IP по порту 3306
sed -i -e "s/\#bind-address=0.0.0.0/bind-address=0.0.0.0/g" /etc/my.cnf.d/mariadb-server.cnf

# Старт mariadb
systemctl start mariadb

# Запуск mysql_secure_installation с подготовленными ответами для автоматизации
sh /home/vagrant/msi.sh

# Разрешение на удалённое подключение к mariadb (с любого IP)
mysql -h 127.0.0.1 -uroot -p123456 <<EOF
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '123456';
EOF
