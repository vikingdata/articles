 
---
title : MySQL under wsl2
author : Mark Nielsen  
copyright : February 2024  
---


MySQL under wsl2
==============================

_**by Mark Nielsen
Original Copyright February 2024**_


1. [Links](#links)
2. [wls2](#wsl2)
3. [Install MySQL and Create MySQL image](#mysql)
4. [Make final MySQL install](#final)
5. [Other](#other)

Purpose is to install Percona MySQL under WSL2 For Windows. WSL2 is a Linux emulator.

MySQL installed under WSL2 (Windows Subsystem for Linux 2) would typically operate similarly to how it does on a native Linux environment.
You can install MySQL server on WSL2 just like you would on a regular Linux distribution.
You can access MySQL running on WSL2 from applications running on your Windows host (if you know the ip address).

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
* [Managing Multiple Linux Servers with ClusterSSH](https://www.linux.com/training-tutorials/managing-multiple-linux-servers-clusterssh/#:~:text=Installation,the%20ports%20system%20on%20FreeBSD.)

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
  # to get to your home directory in Linux and not the Windows home directory
cd
```

Do first things:
* Put your account into sudoers file.

```text
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
```



* * *
<a name=mysql></a>Install MySQL and Create MySQL image
-----

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

Execute these commands in the mysql shell

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

* Logout of MySQL and Linux
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
<a name=final>Make final MySQL install</a>
-----
```dos

wsl -t mysql_base
wsl --list --verbose

mkdir c:\mywsl\instances\mysql_node1
   # Make an image of your mysql base image
wsl --export mysql_base c:\mywsl\exports\mysql_base
   # Make your final wsl mysql install
wsl --import mysql_node1 c:\mywsl\instances\mysql_node1 c:\mywsl\exports\mysql_base
   # Make this your final default OS for WSL
wsl --set-default mysql_node1

wsl --list --verbose

```

To undo and start again

```dos
del  c:\mywsl\exports\mysql_base
wsl --unregister mysql_node1
wsl --list --verbose


```


* * *
<a name=other>Other </a>
-----

You might want to install csshx as well

```

wsl
```

In Linux
```

echo "" >> /etc/ssh/sshd_config
echo "X11Forwarding yes " >> /etc/ssh/sshd_config
echo "X11DisplayOffset 10" >> /etc/ssh/sshd_config
service sshd restart

mkdir -p .clusterssh/

apt-get install clusterssh -y

```


Also, to keep WSL running when you leave it, you need to run a continuous process.
Start wsl

```dos
wsl
  # or
wsl -d mysql_node1
```


Then inside wsl

```bash
  # Get ip address
  # You can use this to connect to mysql from the outside. 
ifconfig | grep inet | head -n1 | sed -e 's/  */ /g' | cut -d ' ' -f3   

  # Start a process which won't stop and keep wsl running when you leave it. 
./run_continuous.sh
  # or
nohup sh -c "  while true; do  sleep 10; done " > /tmp/run.out 2>&1 &

  # Leave wsl.
exit

```

Wait 30 seconds and execute
```dos
wsl --list --verbose
```

and see if it is still running. 