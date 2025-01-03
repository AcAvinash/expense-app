#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log

# Color codes
R="\e[31m"  # Red for errors
G="\e[32m"  # Green for success messages (changed from yellow to green for clarity)
N="\e[0m"   # Reset color

USER_ID=$(id -u)

# Check if the script is run as root
if [ $USER_ID -ne 0 ]; then
  echo -e "$R Error: This script must be run as root $N"
  exit 1
fi

# Validation function
VALIDATE(){
    if [ $1 -ne 0 ];
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

dnf install mysql-server -y &>> $LOGFILE

VALIDATE $? "Installing mysql-server"

systemctl enable mysqld &>> $LOGFILE

VALIDATE $? "Enabling mysqld"

systemctl start mysqld &>> $LOGFILE

VALIDATE $? "Starting mysqld"

mysql_secure_installation --set-root-pass ExpenseApp@1 &>> $LOGFILE

VALIDATE $? "setting up root password"
