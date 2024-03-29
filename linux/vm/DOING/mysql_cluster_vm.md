 
---
title : MySQL under wsl2
author : Mark Nielsen  
copyright : Feburary 2024  
---


MySQL under wsl2
==============================

_**by Mark Nielsen
Original Copyright February 2024**_


1. [Links](#links)
2. [wls2](#wsl2)

Purpose is to install Percona MySQL under WSL2 For Windows. WSL2 is a Linux emulator.

Limitations:
* When you leave wsl, it closes the Linux OS.
* You normally can only run one environment under wsl2 at a time.
* The ip address may change for the emulated at environment sometimes.

Advantages:
* If you know the ip address, you can connect to mysql from the outside if the environment is running. 

* * *
<a name=Links></a>Links
-----

* [WSL](https://learn.microsoft.com/en-us/windows/wsl/install)
* [Basic commands for WSL](https://learn.microsoft.com/en-us/windows/wsl/basic-commands)
* [How To Use Multiple WSL Instances For Development](https://wpclouddeploy.com/how-to-use-multiple-wsl-instances-for-development/)
* [https://inertz.org/install-windows-subsystem-for-linux-and-setup-clusterssh-to-manage-multiple-ssh/](https://inertz.org/install-windows-subsystem-for-linux-and-setup-clusterssh-to-manage-multiple-ssh/)

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
apt-get update
apt-get install emacs screen -y 
apt-get install nmap -y 
apt-get install net-tools -y
apt-get install ssh -y 
echo "I am sudo user $SUDO_USER"

  # Set the default user.
echo '[user]' >> /etc/wsl.conf
echo "default = $SUDO_USER" >> /etc/wsl.conf

  # Star ssh, mysql, and command are startup
echo '[boot]' >> /etc/wsl.conf
echo 'command = /etc/start_services.sh' >> /etc/wsl.conf

  # Make start script
echo '#!/usr/bin/bash' > /etc/start_services.sh
echo "" >> /etc/start_services.sh
echo 'service ssh start' >> /etc/start_services.sh
echo 'nohup -c "  while true; do  sleep 10; done " > /tmp/run.out 2>&1 &' >> /etc/start_services.sh
chmod 755 /etc/start_services.sh

 /etc/start_services.sh


  # Have root change to the /root when it logs in
cd /root/
echo "" >> ~/.bashrc
echo "cd" >> ~/.bashrc

exit
exit
# You should be logged out of Linux and back to DOS or powershell. 
```

Check it is still running
```dos
wsl --list --verbose
```



### Install MySQL and Create MySQL image

Create Base MySQL Image


```dos
wsl --list --verbose
  # Stop the image
wsl -t Ubuntu-22.04
wsl --list --verbose

mkdir c:\mywsl\exports
mkdir c:\mywsl\instances
wsl --export Ubuntu-22.04 c:\mywsl\exports\ubuntu_base

  # start mysql images
wsl --import mysql_base c:\mywsl\instances\mysql_base c:\mywsl\exports\ubuntu_base
wsl -d mysql_base

```

Install MySQL (percona MySQL)

```bash
  # as root
sudo bash


apt install curl -y 
curl -O https://repo.percona.com/apt/percona-release_latest.generic_all.deb
apt install gnupg2 lsb-release ./percona-release_latest.generic_all.deb -y
sudo apt update 
sudo percona-release setup ps80

  # It will may ask for password for percona mysql
  # If it does, leave passwored blank and it will allow
  # root authetication by sudo to root only. 
sudo apt install percona-server-server -y

  # Optional install a specific version
  # We must have 8.0.36 or earlier, because we download oracle's shell and router at 8.0.36
# apt list -a percona-server-server
# apt install  percona-server-server=8.0.35-27-1.jammy

  # start mysql
echo 'service mysql start' >> /etc/start_services.sh


  # Create root passwordless login for local user.
  # We assume user is also administrator in windows.
echo "CREATE USER '$SUDO_USER'@'localhost' IDENTIFIED WITH auth_socket;" > create_user.sql
echo "grant all privileges on *.* to '$SUDO_USER'@'localhost';" >> create_user.sql


  # or do this to create a normal account
  # You can remove the "2" to keep the uername the same. 
echo "CREATE USER '$SUDO_USER'@'%' IDENTIFIED by '$SUDO_USER';" >> create_user.sql
echo "grant all privileges on *.* to '$SUDO_USER'@'%';" >> create_user.sql
echo "select user,host,plugin,authentication_string from mysql.user where user='$SUDO_USER';" >> create_user.sql

echo -e "[mysql]\nuser='$SUDO_USER' \npassword='$SUDO_USER' \n" > /home/$SUDO_USER/.my.cnf
chown $SUDO_USER /home/$SUDO_USER/.my.cnf


  # If it did not ask for a password, it will authenicate by auth_socket
  # which you just sudo to root, and it logins automatically
mysql
```

Execute these commands in the mysql shelll

```sql
source create_user.sql
-- or make a password count
-- source create_user2.sql

  # Then in mysql execute
CREATE FUNCTION fnv1a_64 RETURNS INTEGER SONAME 'libfnv1a_udf.so';
CREATE FUNCTION fnv_64 RETURNS INTEGER SONAME 'libfnv_udf.so';
CREATE FUNCTION murmur_hash RETURNS INTEGER SONAME 'libmurmur_udf.so';
select user,host,authentication_string from mysql.user where user='$SUDO_USER';
 
exit;

```

* Logout of MySQL and linux
* Log out of root, sudo, or quit DOS or Powershell.
* On a new prompt or if you logged out of root, start mysql and execute "select USER()"
    * The user should NOT be root, but your Windows user.
```bash
wget https://dev.mysql.com/get/Downloads/MySQL-Shell/mysql-shell_8.0.36-1ubuntu22.04_amd64.deb
wget https://dev.mysql.com/get/Downloads/MySQL-Router/mysql-router-community_8.0.36-1ubuntu22.04_amd64.deb

dpkg -i mysql-shell_8.0.36-1ubuntu22.04_amd64.deb
dpkg -i mysql-router-community_8.0.36-1ubuntu22.04_amd64.deb


mysql -e "select USER();"
exit

mysql -e "select USER();"
exit


```

Map a Windows network Drive

* mkdir c:\myqsl\shared

Follow the steps in this article to c:\mywsl\shared as drive Z:
[Turning a folder into a drive letter](https://answers.microsoft.com/en-us/windows/forum/all/turning-a-folder-into-a-drive-letter/13b42aa7-1ea8-43ba-90f7-751eb10deaa7)

Mount Drive Z: to wsl

Follow steps in this article for Drive Z: to /mnt/shared in WSL

[How to Mount Windows Network Drives in WSL](https://www.public-health.uiowa.edu/it/support/kb48568/)

in Powershell

```dos
dir > c:\mywsl\shared\test
wsl -d mysql_base
```

in Linux

```bash
sudo bash


mkdir -p /mnt/shared
echo "Z: /mnt/shared drvfs defaults 0 0" >> /etc/fstab
mount -a
ls -al /mnt/shared
exit


exit

````


* * *
<a name=duplicate>Duplicate image four times</a>
-----
```dos

wsl -t mysql_base
wsl --list --verbose

mkdir c:\mywsl\instances\mysql_node1
mkdir c:\mywsl\instances\mysql_node2
mkdir c:\mywsl\instances\mysql_node3
mkdir c:\mywsl\instances\mysql_router

wsl --export mysql_base c:\mywsl\exports\mysql_base

wsl --import mysql_node1 c:\mywsl\instances\mysql_node1 c:\mywsl\exports\mysql_base
wsl --import mysql_node2 c:\mywsl\instances\mysql_node2 c:\mywsl\exports\mysql_base
wsl --import mysql_node3 c:\mywsl\instances\mysql_node3 c:\mywsl\exports\mysql_base
wsl --import mysql_router c:\mywsl\instances\mysql_router c:\mywsl\exports\mysql_base

wsl --list --verbose

```

To undo and start again

```dos
del  c:\mywsl\exports\mysql_node
wsl --unregister mysql_node1
wsl --unregister mysql_node2
wsl --unregister mysql_node3
wsl --unregister mysql_router
wsl --list --verbose


```


* * *
<a name=wsl2>Run MySQL cluster and Router WSL images indepndently </a>
-----
Repeat this for all 3 images.
Login into image and execute.

```
wsl -d mysql_node1
ifconfig | grep inet | head -n1 | sed -e 's/  */ /g' | cut -d ' ' -f3 > /mnt/shared/1_ip
exit

wsl -d mysql_node2
ifconfig | grep inet | head -n1 | sed -e 's/  */ /g' | cut -d ' ' -f3 > /mnt/shared/2_ip
exit

wsl -d mysql_node3
ifconfig | grep inet | head -n1 | sed -e 's/  */ /g' | cut -d ' ' -f3 > /mnt/shared/3_ip
exit

wsl -d mysql_router
ifconfig | grep inet | head -n1 | sed -e 's/  */ /g' | cut -d ' ' -f3 > /mnt/shared/r_ip
exit
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


