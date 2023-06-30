#!/bin/bash 

if [ $(id -u) -ne 0 ]; then 
    echo -e "You should perform this as root user"
    exit 1
fi 
Stat() {
    if [ $1 -ne 0 ]; then 
        echo "Installation Failed :  Check log /tmp/jinstall.log"
        exit 2 
    fi 
}

yum install fontconfig java-11-openjdk-devel wget -y  &>/tmp/jinstall.log
echo "java-11-openjdk-devel.... Installed"

sudo curl –sL https://rpm.nodesource.com/setup_10.x | sudo bash &>/tmp/jinstall.log
echo "npm.... Installed"

sudo yum install –y nodejs &>/tmp/jinstall.log
echo "nodejs.... Installed"

npm i jslint &>/tmp/jinstall.log
echo "jslint.... Installed"

sudo bash install_sonar_scanner.sh &>/tmp/jinstall.log
echo "sonar-scanner.... Installed"
Stat $?

pip install boto &>/tmp/jinstall.log
echo "boto.... Installed"
Stat $?

wget --no-check-certificate -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo &>>/tmp/jinstall.log 
Stat $?

rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key &>>/tmp/jinstall.log 
Stat $?

yum install jenkins --nogpgcheck -y &>>/tmp/jinstall.log
Stat $?

systemctl enable jenkins  &>>/tmp/jinstall.log 
Stat $?

systemctl start jenkins  &>>/tmp/jinstall.log 
Stat $?

echo -e "\e[32m INSTALLATION SUCCESSFUL\e[0m"

mkdir -p /var/lib/jenkins/.ssh
echo 'Host *
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking no' >/var/lib/jenkins/.ssh/config
chown jenkins:jenkins /var/lib/jenkins/.ssh -R
chmod 400 /var/lib/jenkins/.ssh/config
