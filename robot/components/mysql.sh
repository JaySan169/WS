#!/bin/bash

COMPONENT=mysql
source components/common.sh


echo -n "configuring the $COMPONENT repo:" 
curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/stans-robot-project/mysql/main/mysql.repo &>> $LOGFILE
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
DEF_ROOT_PASSWORD=$(grep 'A temporary password' /var/log/mysqld.log | awk -F ' ' '{print $NF}') &>> $LOGFILE
stat $?

echo show databases | mysql -u root -pRoboshop@1 &>> $LOGFILE
if [ $? -ne 0 ] ; then
echo -n "Reset root password:"
echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Roboshop@1';" | mysql --connect-expired-password -u root -p"${DEF_ROOT_PASSWORD}" &>> $LOGFILE
stat $?
fi

echo show plugins | mysql -u root -pRoboshop@1 | grep validate_password; &>> $LOGFILE
if [ $? -eq 0 ] ; then
echo -n "uninstalling password validate plugin"
echo "uninstall plugin validate_password;" | mysql --connect-expired-password -uroot -pRoboshop@1
stat $?
fi

echo -n "Downloading the $COMPONENT Schema: "
cd /tmp
curl -s -L -o /tmp/mysql.zip "https://github.com/stans-robot-project/mysql/archive/main.zip"
unzip -o $COMPONENT.zip &>> $LOGFILE
stat $?

echo -n "Injecting the $COMPONENT Schema: "
cd /tmp/$COMPONENT-main
mysql -u root -pRoboshop@1 < shipping.sql &>> $LOGFILE
stat $?

echo -n -e "\e[32m___________ $COMPONENT installation completed______________\e[0m"