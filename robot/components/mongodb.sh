#!/bin/bash
set -e
COMPONENT=mongodb
source components/common.sh

echo -n "configuring repo :"
echo '[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc' >/etc/yum.repos.d/mongodb.repo
stat $?

echo -n "installing $COMPONENT :"
yum install -y mongodb-org &>> $LOGFILE
stat $?


echo -n "updating mongodb config file :"
sed -i -e 's/127.0.0.1/0.0.0.0/' mongod.conf
stat $?

echo -n "starting mongodb :"
systemctl enable mongod &>> $LOGFILE
systemctl start mongod
stat $?

echo -n "Downloading $COMPONENT schema:"
curl -s -L -o /tmp/mongodb.zip "https://github.com/stans-robot-project/mongodb/archive/main.zip" &>> $LOGFILE
stat $/

echo -n "Injecting Schema :"
cd /tmp
unzip mongodb.zip &>> $LOGFILE
cd mongodb-main
mongo < catalogue.js &>> $LOGFILE
mongo < users.js &>> $LOGFILE
stat $?
