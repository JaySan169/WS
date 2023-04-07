#!/bin/bash
set -e
COMPONENT=shipping
source components/common.sh

echo -n "Installing $COMPONENT:"
yum install maven -y &>> $LOGFILE
stat $?


echo -n "Configuring $COMPONENT repo:"
cd /home/roboshop
curl -s -L -o /tmp/$COMPONENT.zip "https://github.com/stans-robot-project/$COMPONENT/archive/main.zip"
unzip /tmp/$COMPONENT.zip &>> $LOGFILE
mv $COMPONENT-main $COMPONENT
cd $COMPONENT
stat $?

echo -n "Cleaning package:"
mvn clean package &>> $LOGFILE
mv target/$COMPONENT-1.0.jar $COMPONENT.jar 
stat $?

echo -n "Copying the $COMPONENT files:"
mv /home/roboshop/$COMPONENT/systemd.service /etc/systemd/system/$COMPONENT.service
stat $?

echo -n "Starting $COMPONENT service:"
systemctl daemon-reload
systemctl start $COMPONENT 
systemctl enable $COMPONENT
stat $?

echo -n -e "\e[32m___________ $COMPONENT installation completed______________\e[0m"