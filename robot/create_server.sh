#!/bin/bash/

if [ -z $1 ] ; then
echo "enter service name: "
exit 1
fi

COMPONENT=$1

ZONE_ID=""

