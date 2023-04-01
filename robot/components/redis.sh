#!/bin/bash
set -e
COMPONENT=redis
source components/common.sh

echo -n "configuring $COMPONENT repo:"
curl -L "https://raw.githubusercontent.com/stans-robot-project/$COMPONENT/main/redis.repo" -o /etc/yum.repos.d/redis.repo &>> $LOGFILE
stat $?


echo -n "Installing $COMPONENT:"
yum install redis-6.2.7 -y &>> $LOGFILE
stat $?

echo -n "whitelisting redis to others :"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf &>> $LOGFILE
stat $?

echo -n "Starting redis service:"
systemctl daemon-reload
systemctl enable redis &>> $LOGFILE
systemctl start redis