USERID=$(id -u)
LOGFILE=/tmp/$COMPONENT.log
APPUSER=roboshop

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

PYTHON() {
    
echo -n "Installing Python for $COMPONENT service:"
yum install python36 gcc python3-devel -y &>> $LOGFILE
stat $?

CREATE_USER

DOWNLOAD_AND_EXTRACT

echo -n "Installing $COMPONENT service:"
cd /home/$APPUSER/$COMPONENT 
pip3 install -r requirements.txt &>> $LOGFILE
stat $?

CONFIGURE_SERVICE

}

MAVEN_INSTALL()
{

echo -n "Cleaning package:"
cd /home/$APPUSER/$COMPONENT
mvn clean package &>> $LOGFILE
stat $?

echo -n "Moving the $COMPONENT files:"
mv target/$COMPONENT-1.0.jar $COMPONENT.jar &>> $LOGFILE
stat $?
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
sed -i -e 's/MONGO_DNSNAME/172.31.5.219/' -e 's/MONGO_ENDPOINT/172.31.5.219/' -e 's/REDIS_ENDPOINT/172.31.85.39/' -e 's/CATALOGUE_ENDPOINT/172.31.6.205/' -e 's/CARTENDPOINT/172.31.87.152/' -e 's/DBHOST/172.31.5.219/' -e 's/CARTHOST/172.31.87.152/' -e 's/USERHOST/172.31.92.212/' -e 's/AMQPHOST/172.31.86.75/' /home/$APPUSER/$COMPONENT/systemd.service
mv /home/$APPUSER/$COMPONENT/systemd.service /etc/systemd/system/$COMPONENT.service
stat $?


echo -n "Starting $COMPONENT service"
systemctl daemon-reload
systemctl start $COMPONENT
systemctl enable $COMPONENT &>> $LOGFILE
stat $?
} 








