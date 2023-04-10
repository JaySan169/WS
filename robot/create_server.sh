#!/bin/bash/
LOGFILE=/tmp/server.log

if [ -z $1 ] ; then
echo "enter service name: "
exit 1
fi

COMPONENT=$1

AMI_ID="$(aws ec2 describe-images --region us-east-1 --filters "Name=name,Values=DevOps-LabImage-CentOS7" | jq '.Images[].ImageId' | sed -e 's/"//g')"
SGID="$(aws ec2 describe-security-groups   --filters Name=group-name,Values=sg3 | jq '.SecurityGroups[].GroupId' | sed -e 's/"//g')"

echo "AMI ID Used to launch instance is : $AMI_ID"
echo "SG ID Used to launch instance is : $SGID"
echo $COMPONENT

create_server()
{
aws ec2 run-instances --image-id $AMI_ID --instance-type t2.micro --security-group-ids $SGID | jq &>> $LOGFILE
}

if [ "$1" == "all" ] ; then
    for comp in frontend catalogue cart user shipping payment mongodb mysql rabbitmq redis; do 
        COMPONENT=$comp
        create_server
        echo "Server Created...Successfully..."
    done 
else 
        create_server 
        echo "Server Created...Successfully..."
fi 