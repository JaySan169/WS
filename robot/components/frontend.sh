#!/bin/bash
set -e
COMPONENT=frontend
source components/common.sh

echo -n "installing nginx $(COMPONENT) :"
yum install nginx -y &>> $LOGFILE
stat $?

echo -n "downloading component :"
curl -s -L -o /tmp/$COMPONENT.zip "https://github.com/stans-robot-project/$COMPONENT/archive/main.zip"
stat $?

echo -n "performing cleanup"
rm -rf /usr/share/nginx/html/* &>> $LOGFILE
stat $?

cd /usr/share/nginx/html

echo -n "unzipping component :"
unzip /tmp/$COMPONENT.zip &>> $LOGFILE
stat $?

mv $COMPONENT-main/* .
mv static/* . 
rm -rf $COMPONENT-master README.md

echo -n "configuring server proxies :"
mv localhost.conf /etc/nginx/default.d/roboshop.conf
stat $?

systemctl enable nginx &>> $LOGFILE
systemctl start nginx