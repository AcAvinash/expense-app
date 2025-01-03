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
dnf module disable nodejs -y &>>$LOGFILE

VALIDATE $? "node is disable or not"

dnf module enable nodejs:20 -y &>>$LOGFILE

VALIDATE $? "node 20 is enabled"

dnf install -y nodejs &>>$LOGFILE

VALIDATE $? "node 20 is installed"

if id -u expense &>/dev/null; then
  echo -e "User expense already exists. Removing user." 
  userdel -r expense &>>$LOGFILE
  if [ $? -eq 0 ]; then
    echo -e "User expense removed successfully." 
  else
    echo -e "Failed to remove user expense." 
    exit 1
  fi
fi

useradd expense &>>$LOGFILE
if [ $? -eq 0 ]; then
  echo -e "User expense created successfully" 
else
  echo -e "Failed to create user expense" 
fi


VALIDATE $? "Creating user expense..."

mkdir /app &>>$LOGFILE

curl -o /tmp/backend.zip https://expense-artifacts.s3.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE

VALIDATE $? "Downloading backend.zip..."

cd /app &>>$LOGFILE

VALIDATE $? "Moving into app directory"

unzip /tmp/backend.zip &>>$LOGFILE

VALIDATE $? "Extracting backend.zip..."

npm install &>>$LOGFILE

VALIDATE $? "Installing dependencies..."

cp /home/ec2-user/expense-app/backend.service /etc/systemd/system/backend.service &>>$LOGFILE

VALIDATE $? "Copying backend.service..."

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "Reloading systemd..."

systemctl enable backend &>>$LOGFILE

VALIDATE $? "Enabling backend..."

systemctl start backend &>>$LOGFILE

VALIDATE $? "Starting backend..."

dnf install mysql -y &>>$LOGFILE

VALIDATE $? "Installing mysql..."

mysql -h 172.31.87.139 -uroot -pExpenseApp@1 < /app/schema/backend.sql 

mysql -h 172.31.87.139 -uroot -pExpenseApp@1

systemctl restart backend &>>$LOGFILE