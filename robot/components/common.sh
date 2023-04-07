USERID=$(id -u)
LOGFILE=/tmp/$COMPONENT.log

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

NODEJS() {

echo -n "Configuring Node JS :"
curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash -  &>> $LOGFILE
stat $?

echo -n "Installing Node JS :"
yum install nodejs -y &>> $LOGFILE
stat $?

#calling function to create user
CREATE_USER

#Downloading the code 
DOWNLOAD_AND_EXTRACT

#performing npm install
NPM_INSTALL

#configuring service
CONFIGURE_SERVICE

}

MAVEN() {

echo -n "Installing Maven:"
yum install maven -y &>> $LOGFILE
stat $?

#calling function to create user
CREATE_USER

#Downloading the code 
DOWNLOAD_AND_EXTRACT

#configuring service
CONFIGURE_SERVICE

}

CREATE_USER() {

id $APPUSER &>> $LOGFILE
    if [ $? -ne 0 ]; then 
        echo -n "Creating app user :"
        useradd $APPUSER
        stat $?
    fi
}

DOWNLOAD_AND_EXTRACT() {
echo -n "Downloading $COMPONENT :"
curl -s -L -o /tmp/$COMPONENT.zip "https://github.com/stans-robot-project/$COMPONENT/archive/main.zip" &>> $LOGFILE
stat $?

echo -n "Performing cleanup :"
rm -rf /home/$APPUSER/$COMPONENT
cd /home/$APPUSER/
unzip -o /tmp/$COMPONENT.zip &>> $LOGFILE && mv $COMPONENT-main $COMPONENT &>> $LOGFILE
stat $?

echo -n "Changing Permissions to  $APPUSER"
chown $APPUSER:$APPUSER /home/$APPUSER/$COMPONENT && chmod -R 775 /home/$APPUSER/$COMPONENT
stat $?
}

NPM_INSTALL() {
echo -n "installing $COMPONENT dependencies:"
cd $COMPONENT
npm install &>> $LOGFILE
stat $?
}

CONFIGURE_SERVICE() {

echo -n "configuring $COMPONENT service"
sed -i -e 's/MONGO_DNSNAME/172.31.5.219/' -e 's/MONGO_ENDPOINT/172.31.5.219/' -e 's/REDIS_ENDPOINT/172.31.85.39/' -e 's/CATALOGUE_ENDPOINT/172.31.6.205/' /home/$APPUSER/$COMPONENT/systemd.service
mv /home/$APPUSER/$COMPONENT/systemd.service /etc/systemd/system/$COMPONENT.service
stat $?


echo -n "Starting $COMPONENT service"
systemctl daemon-reload
systemctl start $COMPONENT
systemctl enable $COMPONENT &>> $LOGFILE
stat $?
} 


echo -n -e "\e[32m___________ $COMPONENT installation completed______________\e[0m"





