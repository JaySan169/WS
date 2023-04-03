#!/bin/bash

COMPONENT=mysql
source components/common.sh

read -p 'Enter MySQl password you wish to configure:' MYSQL_PWD

echo -n "configuring the $COMPONENT repo:" 
curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/stans-robot-project/mysql/main/mysql.repo &>> $LOGFILE
stat $?

echo -n "Installing $COMPONENT:"
yum install mysql-community-server -y &>> $LOGFILE
stat $?

echo -n "Starting $COMPONENT Service:"
systemctl enable mysqld &>> $LOGFILE
systemctl start mysqld
stat $?

echo -n "Changing the default pasword:"
DEF_ROOT_PASSWORD=$(grep 'A temporary password' /var/log/mysqld.log | awk -F ' ' '{print $NF}') &>> $LOGFILE

echo show databases | mysql -uroot -p${MYSQL_PWD} &>> $LOGFILE
if [ $? -ne 0 ] ; then
echo -n "Reset root password:"
echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_PWD}';" | mysql --connect-expired-password -uroot -p"${DEF_ROOT_PASSWORD}" &>> $LOGFILE
stat $?
fi

echo show plugins | mysql -uroot -p${MYSQL_PWD} | grep validate_password; &>> $LOGFILE
if [ $? -eq 0 ] ; then
echo -n "uninstalling password validate plugin"
echo "uninstall plugin validate_password;" | mysql --connect-expired-password -uroot -p${MYSQL_PWD}
stat $?
fi

echo -n "Downloading the $COMPONENT Schema: "
cd /tmp
curl -s -L -o /tmp/mysql.zip "https://github.com/stans-robot-project/mysql/archive/main.zip"
unzip -o $COMPONENT.zip &>> $LOGFILE

echo -n "Injecting the $COMPONENT Schema: "
cd /tmp/$COMPONENT-main
mysql -u root -p${MYSQL_PWD} <shipping.sql &>> $LOGFILE


echo -n -e "\e[32m___________ $COMPONENT installation completed______________\e[0m"