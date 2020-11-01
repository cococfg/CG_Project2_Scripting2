#!/bin/bash

#### Header

# File: CG_Project_Scripting2
# Brief Description: Script for CSI-230-01 Project 2
# Author: Courtney Grimes
# Due Date: October 22, 2020

#### Constants
email_file=$1 #sets the input file as the constant email_file

#### Functions

root_user() #require sudo access to run program, exit with error if not root
{
  if [ $(id -u) != "0" ]; then
       echo "Must run as root!"
       exit
  fi
}

create_group() #checks to see if a group already exists, if it does not then creates the group
{
  egrep -q -i "CSI230" /etc/group;
  if [ $? -eq 0 ]; then
    :
  else
   $(groupadd CSI230)
  fi
}

email_user() #emails the user their username and password, passing in the username ($1) password ($2) and email ($3) as parameters
{
  echo "Your account has been created with the username of $1 and your inital password has been set as $2" | mail -s "Account Credentials" $3
}

create_users() #creates user accounts with a random password or updates a users password if the user account already exists
{
  while read -r email; do
     username=$(echo $email | cut -d "@" -f 1) #parses out the username
     password=$(openssl rand -base64 12) #creates a random password

     if id $username >/dev/null 2>&1; then #checks to see if user already exists and either changes the password if they do or creates the user if they don't
        echo "$username already exists, changing the password"
        echo "${username}:${password}" | chpasswd
     else
        echo "$username does not exist, creating account"
        $(useradd $username -m -p $(openssl passwd -1 $password) -s /bin/bash)
     fi

     usermod -aG CSI230 $username #adds the user to the CSI230 group
     chage -d 0 $username # requires user to change password immediately after logging in for the first time

     email_user $username $password $email #calls the email_user function passing in the username, password and email as parameters

 done < $email_file
}

#### MAIN

root_user #calls the root_user function
create_group #calls the create_group function
create_users #calls the create_users function


