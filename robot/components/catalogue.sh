#!/bin/bash
set -e
COMPONENT=catalogue
source components/common.sh
APPUSER=roboshop

echo -n "Configuring & Installing Node JS :"
 echo "1"
stat $?

echo -n "Creating app user :"
if [ $? -ne 0 ] ; then 
    useradd roboshop
    stat $?
fi

echo -n "Downloading $COMPONENT :"
curl -s -L -o /tmp/catalogue.zip "https://github.com/stans-robot-project/catalogue/archive/main.zip" &>> $LOGFILE
stat $?

echo -n "moving files :"
cd /home/roboshop
unzip /tmp/catalogue.zip &>> $LOGFILE
stat $?

echo -n "Performing cleanup :"
rm -rf $COMPONENT
mv catalogue-main catalogue
cd /home/roboshop/catalogue
stat $?

echo -n "Installing Dependancies:"
npm install &>> $LOGFILE
stat $?

echo -n "Changing Permissions to  roboshop"
chown roboshop:roboshop /home/roboshop/$COMPONENT && chmod -R 775 /home/roboshop/$COMPONENT
stat $?

echo -n "configuring $COMPONENT service"
sed -e -i 's/MONGO_DNSNAME/172.31.53.28/' /home/roboshop/$COMPONENT/systemd.service
mv /home/roboshop/$COMPONENT/systemd.service /etc/systemd/system/$COMPONENT.service
stat $?


echo -n "Starting $COMPONENT service"
systemctl daemon-reload
systemctl start catalogue
systemctl enable catalogue
stat $?

echo -n -e "\e[32m___________ $COMPONENT installation completed______________\e[0m"