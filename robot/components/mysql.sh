#!/bin/bash

COMPONENT=user
source components/common.sh

echo -n "configuring the $COMPONENT repo:" 
echo '[mysql57-community]
name=MySQL 5.7 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/7/$basearch/
enabled=1
gpgcheck=0' > /etc/yum.repos.d/mysql.repo &>> $LOGFILE
stat $?

echo -n "Installing $COMPONENT:"
yum remove mariadb-libs -y &>> $LOGFILE
yum install mysql-community-server -y &>> $LOGFILE
stat $?

echo -n "Starting $COMPONENT Service:"
systemctl enable mysqld &>> $LOGFILE
systemctl start mysqld
stat $?

echo -n "Changing the default pasword:"
DEF_ROOT_PASSWORD=$(grep 'A temporary password' var/log/mysqld.log | awk -F ' ' '{print $NF}') &>> $LOGFILE

echo show databases | mysql -uroot -pRoboShop@1
if [ $? -ne 0 ] ; then
echo -n "Reset root password:"
echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'RoboShop@1';" | mysql --connect-expired-password -uroot -p"${DEF_ROOT_PASSWORD}" &>> $LOGFILE
stat $?
fi

echo show plugins | mysql -uroot -pRoboShop@1 | grep validate_password; 
if [ $? -eq 0 ] ; then
echo -n "uninstalling password validate plugin"
echo "uninstall plugin validate_password;" | mysql --connect-expired-password -uroot -pRoboShop@1
stat $?
fi

echo -n "Downloading the $COMPONENT Schema: "
cd /tmp
curl -s -L -o /tmp/mysql.zip "https://github.com/stans-robot-project/mysql/archive/main.zip"
unzip -o $COMPONENT.zip

echo -n "Injecting the $COMPONENT Schema: "
cd /tmp/$COMPONENT-main
mysql -u root -pRoboShop@1 <shipping.sql


echo -n -e "\e[32m___________ $COMPONENT installation completed______________\e[0m"