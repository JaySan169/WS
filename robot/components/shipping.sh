#!/bin/bash
COMPONENT=shipping
source components/common.sh

echo -n "Installing Maven:"
yum install maven -y &>> $LOGFILE
stat $?

useradd roboshop

echo -n "Configuring $COMPONENT repo:"
cd /home/roboshop
curl -s -L -o /tmp/shipping.zip "https://github.com/stans-robot-project/shipping/archive/main.zip"
unzip /tmp/shipping.zip &>> $LOGFILE
mv shipping-main shipping
cd shipping
stat $?

echo -n "Cleaning package:"
mvn clean package &>> $LOGFILE
mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
stat $?

echo -n "Copying the $COMPONENT files:"
mv /home/roboshop/$COMPONENT/systemd.service /etc/systemd/system/$COMPONENT.service &>> $LOGFILE
stat $?

echo -n "Starting $COMPONENT service:"
systemctl daemon-reload
systemctl start $COMPONENT 
systemctl enable $COMPONENT
stat $?

echo -n -e "\e[32m___________ $COMPONENT installation completed______________\e[0m"