 
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
3. [Vrgrant](#vagrant)
4. [VirtualBox](#vb)
5. [Docker](#d)
6. [nerdctl](#n)

There are two types of virtualization.
Full virutalzation solutions which run an operating system, which is meant for entire
OS or machines. 
And one that runs containers, which is meant for applications.


* * *
<a name=Links></a>Links
-----

* [Docker vs VirtualBox](https://stackshare.io/stackups/docker-vs-virtualbox#:~:text=Docker%20containers%20start%20up%20quickly,performance%20compared%20to%20Docker%20containers.)
* [WSL](https://learn.microsoft.com/en-us/windows/wsl/install)
* [Basic commands for WSL](https://learn.microsoft.com/en-us/windows/wsl/basic-commands)
* [VirtualBox](https://www.virtualbox.org/)
* [Docker](https://www.docker.com/)
* [Nerdctrl on github](https://github.com/containerd/nerdctl)
* [Installing/Upgrading Rancher](https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade)
* [Getting Started With Vagrant](https://phoenixnap.com/kb/vagrant-beginner-tutorial#:~:text=Before%20you%20start%2C%20make%20sure,%2DV%2C%20and%20custom%20solutions.)
* [Getting Started with Vagrant and VirtualBox](https://www.itu.dk/people/ropf/blog/vagrant_install.html#:~:text=Getting%20Started%20with%20Vagrant%20and,%2C%20MacOS%2C%20Windows%2C%20etc.)

* * *
<a name=wsl2>WSL2</a>
-----

Info Commands is Windows Shell or Powershell
* See what version you are using : wsl -l -v
* See where is installs stuff: wsl pwd
* List versions available : wsl --list --online
* List versions installed : wsl --list --verbose

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

To remove
* wsl --unregister Ubuntu-22.04

Do first things:
* Put your account into sudoers file.

```text


  # Next time you login it will go to your linux home directory
  # instead of windows. 
echo "" >> ~/.bashrc
echo "cd" >> ~/.bashrc

  # sudo to root
sudo bash

  # Add yourself to sudoers file passwordless
echo "$SUDO_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

sudo bash
apt-get update
apt-get install emacs screen
apt-get install nmap

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
echo "CREATE USER '$SUDO_USER'@'localhost' IDENTIFIED WITH '$SUDO_USER';" > create_user.sql
echo "grant all privileges on *.* to '$SUDO_USER'@'localhost';" >> create_user.sql
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

### Install MongoDB

### Install Mutiple MySQL and Mongo instances
https://endjin.com/blog/2021/11/setting-up-multiple-wsl-distribution-instances

### Install Python for MySQL and mongo
* Download Pythong binary from  : [https://dev.mysql.com/downloads/connector/python/](https://dev.mysql.com/downloads/connector/python/)


```bash
sudo bash
apt install python3-pip
pip install mysql-connector-python
exit

   #Check login through socket for passwordless unix so authentication

   # As normal user
python3 -c "import mysql.connector; cnx = mysql.connector.connect(unix_socket='/var/run/mysqld/mysqld.sock'); c = cnx.cursor(); c.execute('select user()'); print (c.fetchone()); "

  # or if you made a an account with a password
python3 -c "import mysql.connector; cnx = mysql.connector.connect(user='$USER', password='$USER'); c = cnx.cursor(); c.execute('select user()'); print (c.fetchone()); "

   # or
echo '#!/usr/bin/python3 

import mysql.connector; 

vars={'unix_socket':'/var/run/mysqld/mysqld.sock'}
   # Uncomment if you made an account with a password.
#vars={'user':'$USER','password':'$USER'}

cnx = mysql.connector.connect(**vars);
c = cnx.cursor(); 
c.execute("select user()"); 
print (c.fetchone()) 
' > check_connect.py

python3 check_connect.py

   # or as a normal user


```

* * *
<a name=vagrant></a>Vagrant
-----

A free software by HashiuCorp to create virtual environment.
It works with VirtualBox, VMware, Docker, Hyper-V, and custom solutions.
Ity can run on Windows, Mac, Linux. 

* * *
<a name=vb></a>VirtualBox
-----
Owned by Oracle. It is a free (but not open source) VM system that appears to be able to be used for free by personal or commercial use.

Problems: Most things work, except MongoDB. 


* * *
<a name=d></a>Docker
-----

Runs containers under different operating systems. 


* * *
<a name=n></a>Nerdctl and Rancher
-----
It is a free version of Docker. 




