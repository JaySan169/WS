#!/bin/bash
set -e
COMPONENT=user
source components/common.sh
APPUSER=roboshop


echo -n "Configuring Node JS :"
curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash -  &>> $LOGFILE
stat $?

echo -n "Installing Node JS :"
yum install nodejs -y &>> $LOGFILE
stat $?

#id $APPUSER &>> $LOGFILE
#    if [ $? -ne 0 ]; then 
#        echo -n "Creating app user :"
#        useradd roboshop
#        stat $?
#    fi

useradd roboshop

echo -n "Downloading $COMPONENT :"
curl -s -L -o /tmp/$COMPONENT.zip "https://github.com/stans-robot-project/$COMPONENT/archive/main.zip" &>> $LOGFILE
stat $?

echo -n "moving files :"
cd /home/$APPUSER/
unzip -o /tmp/$COMPONENT.zip &>> $LOGFILE
stat $?

echo -n "Performing cleanup :"
rm -rf $COMPONENT
mv $COMPONENT-main $COMPONENT
stat $?

echo -n "Installing Dependancies:"
cd $COMPONENT
npm install &>> $LOGFILE
stat $?

echo -n "Changing Permissions to  $APPUSER"
chown $APPUSER:$APPUSER /home/$APPUSER/$COMPONENT && chmod -R 775 /home/$APPUSER/$COMPONENT
stat $?

echo -n "configuring $COMPONENT service"
sed -i -e 's/MONGO_ENDPOINT/172.31.5.219/' -e 's/REDIS_ENDPOINT/172.31.87.210/' /home/$APPUSER/$COMPONENT/systemd.service
mv /home/$APPUSER/$COMPONENT/systemd.service /etc/systemd/system/$COMPONENT.service
stat $?


echo -n "Starting $COMPONENT service"
systemctl daemon-reload
systemctl start $COMPONENT
systemctl enable $COMPONENT &>> $LOGFILE
stat $?

echo -n -e "\e[32m___________ $COMPONENT installation completed______________\e[0m"