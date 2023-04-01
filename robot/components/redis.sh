#!/bin/bash
set -e
COMPONENT=redis
source components/common.sh

echo -n "configuring $COMPONENT repo:"
#yum install epel-release yum-utils -y &>> $LOGFILE
#yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y &>> $LOGFILE
#yum-config-manager --enable remi &>> $LOGFILE
curl -L "https://raw.githubusercontent.com/stans-robot-project/$COMPONENT/main/redis.repo" -o /etc/yum.repos.d/redis.repo &>> $LOGFILE
stat $?


echo -n "Installing $COMPONENT:"
#yum install redis -y &>> $LOGFILE
yum install redis-6.2.7 -y &>> $LOGFILE
stat $?

echo -n "whitelisting redis to others :"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf &>> $LOGFILE
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis/redis.conf &>> $LOGFILE
stat $?

echo -n "Starting redis service:"
systemctl daemon-reload
systemctl start redis
stat $?