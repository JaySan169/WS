#!/bin/bash

echo line1
echo line2
echo line3

echo -e "\e[32m I am printing Green Color \e[0m"
echo -e "\e[31m I am printing Red Color \e[0m"
echo -e "\e[33m I am printing Yellow Color \e[0m"
echo -e "\e[34m I am printing Blue Color \e[0m"
echo -e "\e[43;32m I am printing Green Color with YELLOW as Background \e[0m"


a=10
b=20
c=30

echo $a
echo ${b}
echo "$c"
echo "value of d: $d"

today=$(date)
echo -e "\n\e[31;44m Today's Date : $today \e[0m"

x=100

echo -e "\nValue of a is $x"

echo "Name of the script is : $0"     # Gives the name of the script you're running  

echo first value is $1
echo second value is $2 
echo third value is $3

echo -e "PID:$$"

read -p "Enter Name: " Name

stat()
{

echo -e "\nWelcome,\e[31m $Name \e[0m you are working on process id:\e[32m $$ \e[0m"

}

echo -e "\n\ncalling ur function...."
stat


z=47

echo "$z"
echo '$z'
echo "$?"


read -p "Enter Option to Start or Stop ur service... : " opt

case $opt in
    start)
        echo -e "\e[32m Starting...\e[0m"
        ;;
    stop)
        echo -e "\e[31m Stopping...\e[0m"
        ;;
    *)
	    echo "InValid...(Enter start  or stop)"
        ;;
esac


if [ 1 -gt 0 ]; then
            echo "true"
    fi 































