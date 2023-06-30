#!/bin/bash 

if [ -z "$1" ]; then 
    echo -e "\e[31m Component name is required \n example usage is: \n\t bash create_server.sh componentName \e[0m"   
    exit 1 
fi 

COMPONENT=$1
ENV=$2
ZONE_ID="Z044318916WL2NSIWQC4A"
#AMI_ID="ami-0c1d144c8fdd8d690"
#SGID="sg-09c4f9587ca8ec0f1"

AMI_ID="$(aws ec2 describe-images --region us-east-1 --filters "Name=name,Values=DevOps-LabImage-CentOS7" | jq '.Images[].ImageId' | sed -e 's/"//g')"
SGID="$(aws ec2 describe-security-groups   --filters Name=group-name,Values=sg3 | jq '.SecurityGroups[].GroupId' | sed -e 's/"//g')"
echo "AMI ID Used to launch instance is : $AMI_ID"
echo "SG ID Used to launch instance is : $SGID"
echo "$COMPONENT"

createServer() {
    PRIVATE_IP=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t2.micro --security-group-ids $SGID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${COMPONENT}}]"| jq '.Instances[].PrivateIpAddress' | sed -e 's/"//g')

    sed -e "s/IPADDRESS/${PRIVATE_IP}/" -e "s/COMPONENT/$COMPONENT/" route53.json > /tmp/dns.json 

    echo -n "Creating the DNS Record..."
    aws route53 change-resource-record-sets --hosted-zone-id $ZONE_ID --change-batch file:///tmp/dns.json | jq 
}

if [ "$1" == "all" ]; then 
    for component in frontend catalogue cart user shipping payment mongodb mysql rabbitmq redis; do 
        COMPONENT=$component
        createServer
    done 
else 
        createServer 
fi 