#!/bin/bash
COMPONENT=shipping
source components/common.sh

MAVEN

echo -n "Cleaning package:"
cd /home/$APPUSER/$COMPONENT
mvn clean package &>> $LOGFILE
stat $?

echo -n "Copying the $COMPONENT files:"
mv target/$COMPONENT-1.0.jar $COMPONENT.jar &>> $LOGFILE
stat $?

