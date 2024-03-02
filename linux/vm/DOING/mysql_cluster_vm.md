 
---
title : Linux: Install Linux under Windows
author : Mark Nielsen  
copyright : Feburary 2024  
---


Linux: Install Linux under Windows
==============================

_**by Mark Nielsen
Original Copyright February 2024**_


1. [Links](#links)
2. [wls2](#wsl2)


* * *
<a name=Links></a>Links
-----

* [WSL](https://learn.microsoft.com/en-us/windows/wsl/install)
* [Basic commands for WSL](https://learn.microsoft.com/en-us/windows/wsl/basic-commands)
* [How To Use Multiple WSL Instances For Development](https://wpclouddeploy.com/how-to-use-multiple-wsl-instances-for-development/)

* * *
<a name=wsl2>WSL2</a>
-----

Info Commands is Windows Shell or Powershell

* Open Shell as administrator
    * wsl --install --distribution  Ubuntu-22.04
       * It will ask for a username and password
    * If you leave , you can reenter by :
```bash
  # This sets the default doe wsl
wsl --set-default Ubuntu-22.04
wsl

  # ot if you didn't set the default
wsl --distribution Ubuntu-22.04

  # Once in Linux
  # to get to your home directory in Linux and not the Windows hom directory
cd
```

Do first things:
* Put your account into sudoers file.

```text


  # Next time you login it will go to your linux home directory
  # instead of windows. 
echo "" >> ~/.bashrc
echo "cd" >> ~/.bashrc

echo 'nohup sh -c "  while true; do  sleep 10; done " > /tmp/run.out 2>&1 &' > run_continuous.sh
echo 'exit' >> run_continuous.sh
chmod 755 run_continuous.sh

  # sudo to root
sudo bash

  # Add yourself to sudoers file passwordless
echo "$SUDO_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

echo "I am user $USER"
sudo bash
apt-get update
apt-get install emacs screen
apt-get install nmap
apt install net-tools
apt-get install ssh
echo "I am user $SUDO_USER"


  # Set the default user.
echo '[user]' >> /etc/wsl.conf
echo "default = $SUDO_USER" >> /etc/wsl.conf

  # Star ssh, mysql, and command are startup
echo '[boot]' >> /etc/wsl.conf
echo 'command = /etc/start_services.sh' >> /etc/wsl.conf

  # Make start script
echo "#!/usr/bin/bash" > /etc/start_services.sh
echo "" >> /etc/start_services.sh
echo 'service ssh start' >> /etc/start_services.sh
echo "service mysql start' >> /etc/start_services.sh
echo 'nohup -c "  while true; do  sleep 10; done " > /tmp/run.out 2>&1 &' >> /etc/start_services.sh
chmod 755 /etc/start_services.sh


  # Have root change to the /root when it logs in
cd /root/
echo "" >> ~/.bashrc
echo "cd" >> ~/.bashrc

user]
default = DemoUser

```

### Install MySQL

```bash
  # as root
apt install curl
curl -O https://repo.percona.com/apt/percona-release_latest.generic_all.deb
apt install gnupg2 lsb-release ./percona-release_latest.generic_all.deb
sudo apt update
sudo percona-release setup ps80

  # It will may ask for password for percona mysql
  # If it does, leave passwored blank and it will allow
  # root authetication by sudo to root only. 
sudo apt install percona-server-server

  # Create root passwordless login for local user.
  # We assume user is also administrator in windows.
echo "CREATE USER '$SUDO_USER'@'localhost' IDENTIFIED WITH auth_socket;" > create_user.sql
echo "grant all privileges on *.* to '$SUDO_USER'@'localhost';" >> create_user.sql


  # or do this to create a normal account
  # You can remove the "2" to keep the uername the same. 
echo "CREATE USER '$SUDO_USER'@'%' IDENTIFIED WITH '$SUDO_USER';" > create_user.sql
echo "grant all privileges on *.* to '$SUDO_USER'@'%';" >> create_user.sql

echo "[mysql]\n user='$SUDO_USER' \npassword='$SUDO_USER' \n": > /home/$SUDO_USER.my.cnf
chown $SUDO_USER /home/$SUDO_USER.my.cnf


  # If it did not ask for a password, it will authenicate by auth_socket
  # which you just sudo to root, and it logins automatically
sudo bash
mysql

source create_user.sql
-- or make a password count
-- source create_user2.sql

  # Then in mysql execute
CREATE FUNCTION fnv1a_64 RETURNS INTEGER SONAME 'libfnv1a_udf.so';
CREATE FUNCTION fnv_64 RETURNS INTEGER SONAME 'libfnv_udf.so';
CREATE FUNCTION murmur_hash RETURNS INTEGER SONAME 'libmurmur_udf.so';

```

* Logout of MySQL
* Log out of root, sudo, or quit DOS or Powershell.
* On a new prompt or if you logged out of root, start mysql and execute "select USER()"
    * The user should NOT be root, but your Windows user.
```bash
mysql
select USER();
```


* * *
<a name=duplicate>Duplicate image three times</a>
-----
```dos

wsl --list --verbose
wsl -t Ubuntu-22.04
wsl --list --verbose

mkdir c:\mywsl\exports
mkdir c:\mywsl\instances
mkdir c:\mywsl\instances\mysql_node1
mkdir c:\mywsl\instances\mysql_node2
mkdir c:\mywsl\instances\mysql_node3


wsl --export Ubuntu-22.04 c:\mywsl\exports\mysql_node
wsl --import mysql_node1 c:\mywsl\instances\mysql_node1 c:\mywsl\exports\mysql_node
wsl --import mysql_node2 c:\mywsl\instances\mysql_node2 c:\mywsl\exports\mysql_node
wsl --import mysql_node3 c:\mywsl\instances\mysql_node3 c:\mywsl\exports\mysql_node
wsl --list --verbose

```

To undo and start again

```dos
del  c:\mywsl\exports\mysql_node
wsl --unregister mysql_node1
wsl --unregister mysql_node2
wsl --unregister mysql_node3
wsl --list --verbose



```


* * *
<a name=wsl2>Run MySQL cluster WSL images indepndently </a>
-----
Repeat this for all 3 images.
Login into image and execute.

```bash
nohup -c "  while true; do  sleep 10; done " > /tmp/run.out 2>&1 &
```

* wsl -d mysql_node1
    * nohup -c "  while true; do  sleep 10; done " > /tmp/run.out 2>&1 &;
    * exit
* wsl -d mysql_node2
    * run : nohup -c "  while true; do  sleep 10; done " > /tmp/run.out 2>&1 &; exit;
* wsl -d mysql_node3
    * run : nohup -c "  while true; do  sleep 10; done " > /tmp/run.out 2>&1 &; exit;
* wait 10 seconds
* wsl --list --verbose
    * and you should see
    


* * *
<a name=wsl2>Port forward </a>
-----


* * *
<a name=wsl2>Setup cluster </a>
-----


