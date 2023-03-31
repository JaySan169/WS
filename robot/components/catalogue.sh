#!/bin/bash
set -e
COMPONENT=catalogue
source components/common.sh
APPUSER=roboshop

echo -n "Configuring libstdc++ :"
yum install libstdc++ &>> $LOGFILE
stat $?

echo -n "Configuring Node JS :"
yum install node
curl –sL https://rpm.nodesource.com/setup_10.x | sudo bash -
yum install –y nodejs
#curl –s -L "https://rpm.nodesource.com/setup_10.x" | bash &>> $LOGFILE
stat $?

echo -n "Installing Node JS :"
yum install nodejs -y &>> $LOGFILE
stat $?

id $APPUSER &>> $LOGFILE
if [ $? -ne 0 ] : then 
    echo -n "Creating app user :"
    useradd $APPUSER
    stat $?
fi

echo -n "Downloading $COMPONENT :"
curl -s -L -o /tmp/catalogue.zip "https://github.com/stans-robot-project/catalogue/archive/main.zip" &>> $LOGFILE
stat $?

echo -n "moving files :"
cd /home/$APPUSER
unzip /tmp/catalogue.zip &>> $LOGFILE
stat $?

echo -n "Performing cleanup :"
rm -rf $COMPONENT
mv catalogue-main catalogue
cd /home/$APPUSERop/catalogue
stat $?

echo -n "Installing Dependancies:"
npm install &>> $LOGFILE
stat $?

echo -n "Changing Permissions to  $APPUSER"
chown $APPUSER:$APPUSER /home/$APPUSER/$COMPONENT && chmod -R 775 /home/$APPUSER/$COMPONENT
stat $?

echo -n "configuring $COMPONENT service"
sed -e -i 's/MONGO_DNSNAME/172.31.53.28/' /home/$APPUSER/$COMPONENT/systemd.service
mv /home/$APPUSER/$COMPONENT/systemd.service /etc/systemd/system/$COMPONENT.service
stat $?


echo -n "Starting $COMPONENT service"
systemctl daemon-reload
systemctl start catalogue
systemctl enable catalogue
stat $?

echo -n -e "\e[32m___________ $COMPONENT installation completed______________\e[0m"