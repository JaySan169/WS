#!/bin/bash

COMPONENT=enable
source components/common.sh

echo -n "Starting $COMPONENT service"
systemctl daemon-reload
systemctl start $COMPONENT
systemctl enable $COMPONENT &>> $LOGFILE
stat $?