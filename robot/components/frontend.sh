#!/bin/bash
set -e
COMPONENT=frontend

USERID=$(id -u)

if [ $USERID -ne 0 ] ; then
    echo -e "\e[31m be a root user or use sudo \e[0m"
    exit 1
fi

stat() {
    if [ $? -eq 0 ] ; then
        echo -e "\e[32m Success \e[0m"
    else
        echo -e "\e[31m Failure \e[0m"
    fi
}

echo -n "installing nginx :"
yum install nginx -y &>> /tmp/$COMPONENT.log
stat $?

echo -n "downloading component :"
curl -s -L -o /tmp/$COMPONENT.zip "https://github.com/stans-robot-project/$COMPONENT/archive/main.zip"
stat $?

echo -n "performing cleanup"
rm -rf /usr/share/nginx/html/* &>> /tmp/$COMPONENT.log
stat $?

cd /usr/share/nginx/html

echo -n "unzipping component :"
unzip /tmp/$COMPONENT.zip &>> /tmp/$COMPONENT.log
stat $?

mv $COMPONENT-main/* .
mv static/* . 
rm -rf $COMPONENT-master README.md

echo -n "configuring server proxies :"
mv localhost.conf /etc/nginx/default.d/roboshop.conf
stat $?

systemctl enable nginx &>> /tmp/$COMPONENT.log
systemctl start nginx