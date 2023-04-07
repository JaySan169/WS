#!/bin/bash
COMPONENT=rabbitmq
source components/common.sh


echo -n "Configuring $COMPONENT repo:"
yum install https://github.com/rabbitmq/erlang-rpm/releases/download/v23.2.6/erlang-23.2.6-1.el7.x86_64.rpm -y &>> $LOGFILE
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>> $LOGFILE
stat $?


echo -n "installing $COMPONENT:"
yum install rabbitmq-server -y &>> $LOGFILE
stat $?

echo -n "Starting $COMPONENT:"
systemctl enable rabbitmq-server &>> $LOGFILE
systemctl start rabbitmq-server
stat $?

echo -n "Configuring User and permissons:"
rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE
rabbitmqctl set_user_tags roboshop administrator &>> $LOGFILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"  &>> $LOGFILE
stat $?



