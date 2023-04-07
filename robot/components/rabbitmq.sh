#!/bin/bash
COMPONENT=rabbitmq
source components/common.sh


echo -n "Configuring $COMPONENT repo:"
yum install https://github.com/$COMPONENT/erlang-rpm/releases/download/v23.2.6/erlang-23.2.6-1.el7.x86_64.rpm -y &>> $LOGFILE
curl -s https://packagecloud.io/install/repositories/$COMPONENT/$COMPONENT-server/script.rpm.sh | sudo bash &>> $LOGFILE
stat $?


echo -n "installing $COMPONENT:"
yum install $COMPONENT-server -y &>> $LOGFILE
stat $?

echo -n "Starting $COMPONENT:"
systemctl enable $COMPONENT-server &>> $LOGFILE
systemctl start $COMPONENT-server
stat $?

echo -n "Configuring User and permissons:"
rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE
rabbitmqctl set_user_tags roboshop administrator &>> $LOGFILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"  &>> $LOGFILE
stat $?



