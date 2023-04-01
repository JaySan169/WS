#!/bin/bash
set -e
COMPONENT=redis
source components/common.sh

echo -n "configuring $COMPONENT repo:"
wget https://download.redis.io/releases/redis-6.2.7.tar.gz &>> $LOGFILE
tar -xvf redis-6.2.7.tar.gz &>> $LOGFILE
cd ./redis-6.2.7/
stat $?


echo -n "Installing $COMPONENT:"
yum install redis-* -y &>> $LOGFILE
stat $?

echo -n "whitelisting redis to others :"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf &>> $LOGFILE
stat $?

echo -n "Starting redis service:"
systemctl daemon-reload
systemctl start redis
stat $?