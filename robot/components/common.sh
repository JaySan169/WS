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