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
dnf install nginx -y &>>$LOGFILE

VALIDATE $? "Nginx installation"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "Nginx service start"

systemctl enable nginx &>>$LOGFILE

VALIDATE $? "Nginx service enable"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE

VALIDATE $? "HTML directory cleanup"

curl -o /tmp/frontend.zip https://expense-artifacts.s3.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE

VALIDATE $? "Frontend zip download"

cd /usr/share/nginx/html &>>$LOGFILE

VALIDATE $? "Moving to default HTML directory"

unzip /tmp/frontend.zip &>>$LOGFILE

VALIDATE $? "Frontend zip extraction"

cp /home/ec2-user/expense-app/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE

VALIDATE $? "expense.conf configuration"

systemctl restart nginx  &>>$LOGFILE

VALIDATE $? "Restarting Nginx"