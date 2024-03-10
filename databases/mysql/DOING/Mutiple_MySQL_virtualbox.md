 
---
title : Multiple MySQL Virtualbox
author : Mark Nielsen  
copyright : March 2024  
---


Multiple MySQL VirtualBox
==============================

_**by Mark Nielsen
Original Copyright March 2024**_


1. [Links](#links)
2. [Install Linux](#l)
3. [Setup MySQL image](#m)
4. [Export MySQL image](#e)
5. [Import MySQL image](#i)
6. [Setup Cluster](#c)
7. [Setup Master-Master](#mm)

Purpose is to install Multiple installations of MySQL. 

* * *
<a name=Links></a>Links
-----
* [VirtualBox images](https://www.virtualbox.org/wiki/Downloads)
* [Windows Install Guest Additions](https://www.virtualbox.org/manual/ch04.html#additions-windows)
* [Move VirtualBox VM to other hosts](https://4sysops.com/archives/move-virtualbox-vm-to-other-hosts/#:~:text=If%20you're%20running%20VirtualBox,it%20on%20the%20target%20PC.)
* [Install Cygwin](https://www.cygwin.com/install.html)


* * *
<a name=l>Install Linux</a>
-----

* Setup "node1" described in [Multiple Linux under VirtualBox](https://github.com/vikingdata/articles/blob/main/linux/vm/Multiple_linux_VirtualBox.md)
    * Make sure bidirectional copy and paste is setup.
    * File sharing of c:\vm\shared to /mnt/shared
    * Network is using "Bridged Adapter"

* * *
<a name=m>Setup MySQL image</a>
-----


* Created mysql basic image: Copy "node1" to "mysql1"
    * In Virtual Box, select Import Appliance
    * For File, put in  C:\vm\shared\node1.ova
        * Change settings
        * Name : mysql1
        * Mac Address Policy : "Generate new"
        * click Finish
* Instal Percona MySQL and other programs
    * Start "mysql1"
    * Sudo to root (this should already be setup)
    * Install software
``` bash
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

* Execute these commands in the mysql shelll

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

* Logout of MySQL and back to sudo in linux
```bash
wget https://dev.mysql.com/get/Downloads/MySQL-Shell/mysql-shell_8.0.36-1ubuntu22.04_amd64.deb
wget https://dev.mysql.com/get/Downloads/MySQL-Router/mysql-router-community_8.0.36-1ubuntu22.04_amd64.deb

dpkg -i mysql-shell_8.0.36-1ubuntu22.04_amd64.deb
dpkg -i mysql-router-community_8.0.36-1ubuntu22.04_amd64.deb

   # Should be root. 
mysql -e "select USER();"
exit

   # Should be user, for me "mark"
mysql -e "select USER();"
exit
```
 