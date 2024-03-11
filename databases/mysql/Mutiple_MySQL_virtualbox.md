 
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
6. [Setup Master-Master](#mm)
7. [Future](#f)

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
* Start mysql1 and get ip address
  *    # Record this ip address
      * ifconfig | grep inet | head -n1 | sed -e 's/  */ /g' | cut -d ' ' -f3
  * If you prefer to ssh to the system, log in as a normal user and sudo to root.
      * When you have multiple instances, you can have ssh open to each virtual machine under "screen or "tmux".
* Install Percona MySQL and other programs
    * Start "mysql1"
    * Sudo to root (this should already be setup)
    * Install software
``` bash
sudo bash

  #Set the hostname to mysql1
hostnamectl set-hostname mysql1.myguest.virtualbox.org

  # Setup alises in Linux bash so you can ssh to this box
ip=`ifconfig | grep inet | head -n1 | sed -e 's/  */ /g' | cut -d ' ' -f3`
echo "alias mysql1='ssh $ip -l $SUDO_USER '" >> /mnt/shared/alias_ssh_systems
echo "mysql1_name='mysql1'" >> /mnt/shared/alias_ssh_systems
echo "mysql1_ip=$ip" >> /mnt/shared/alias_ssh_systems


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

   # Make sure stuff starts at boot
systemctl enable ssh
systemctl enable mysql


  # If it did not ask for a password, it will authenicate by auth_socket
  # which you just sudo to root, and it logins automatically
mysql
```

* Execute these commands in the mysql shell

```sql
source create_user.sql
-- or make a password count
-- source create_user2.sql

  # Then in mysql execute
CREATE FUNCTION fnv1a_64 RETURNS INTEGER SONAME 'libfnv1a_udf.so';
CREATE FUNCTION fnv_64 RETURNS INTEGER SONAME 'libfnv_udf.so';
CREATE FUNCTION murmur_hash RETURNS INTEGER SONAME 'libmurmur_udf.so';

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

* * *
<a name=e>Export MySQL image</a>
-----

* Stop the "mysql1"
* In Virtual Box under File, select Export Appliance
* Choose the "mysqld1"
* For Mac Address Policy, choose "Strip all network adapter Max Addresses"
* For file chose : C:\vm\shared\mysql_base.ova
* Click Next
* Don't change anything on this page.
* Click Finish. Wait until is is done, may take a while.


* * *
<a name=i>Import MySQL image</a>
-----

To create 3 more images
* for mysql[l2,3,4]

Now import the images three times
* In Virtual Box, select Import Appliance
* For File, put in  C:\vm\shared\mysql_base.ova
* Change settings
    * Name : mysql2
    * Mac Address Policy : "Generate new"
    * click Finish
* start "mysql2"
* Login as user and sudo to root
    * sudo bash
* Set the hostname to mysql1
    * hostnamectl set-hostname mysql2.myguest.virtualbox.org
* Setup aliases in Linux bash so you can ssh to this box
```bash
ip=`ifconfig | grep inet | head -n1 | sed -e 's/  */ /g' | cut -d ' ' -f3`
echo "alias mysql2='ssh $ip -l $SUDO_USER '" >> /mnt/shared/alias_ssh_systems
echo "mysql2_name='mysql2'" >> /mnt/shared/alias_ssh_systems
echo "mysql2_ip=$ip" >> /mnt/shared/alias_ssh_systems
```

    

* In Virtual Box, select Import Appliance
* For File, put in  C:\vm\shared\mysql_base.ova
* Change settings
    * Name : mysql3
    * Mac Address Policy : "Generate new"
    * click Finish
* start "mysql3"
* Login as user and sudo to root
    * sudo bash
* Set the hostname to mysql1
    * hostnamectl set-hostname mysql3.myguest.virtualbox.org
* Setup aliases in Linux bash so you can ssh to this box
```bash
ip=`ifconfig | grep inet | head -n1 | sed -e 's/  */ /g' | cut -d ' ' -f3`
echo "alias mysql3='ssh $ip -l $SUDO_USER '" >> /mnt/shared/alias_ssh_systems
echo "mysql3_name='mysql3'" >> /mnt/shared/alias_ssh_systems
echo "mysql3_ip=$ip" >> /mnt/shared/alias_ssh_systems
```  

* In Virtual Box, select Import Appliance
* For File, put in  C:\vm\shared\mysql_base.ova
* Change settings
    * Name : mysql4
    * Mac Address Policy : "Generate new"
    * click Finish
* start "mysql4"
* Login as user and sudo to root
    * sudo bash
* Set the hostname to mysql1
    * hostnamectl set-hostname mysql4.myguest.virtualbox.org
* Setup aliases in Linux bash so you can ssh to this box
```
ip=`ifconfig | grep inet | head -n1 | sed -e 's/  */ /g' | cut -d ' ' -f3`
echo "alias mysql4='ssh $ip -l $SUDO_USER '" >> /mnt/shared/alias_ssh_systems
echo "mysql4_name='mysql4'" >> /mnt/shared/alias_ssh_systems
echo "mysql4_ip=$ip" >> /mnt/shared/alias_ssh_systems
```

Repeat this procedure if you need more images. 


* * *
<a name=main>Maintenance with WSL and cssh</a>
-----

* Start wsl
    * Install wsl
        * [https://github.com/vikingdata/articles/blob/main/databases/mysql/MySQL_under_wsl2.md](https://github.com/vikingdata/articles/blob/main/databases/mysql/MySQL_under_wsl2.md)
    * wsl --distribution mysql1
* Setup cssh to connect to all 4 hosts
    * install cssh [https://www.putorius.net/cluster-ssh.html](https://www.putorius.net/cluster-ssh.html)
        * sudo sudo apt-get install clusterssh
    * source /mnt/c/vm/shared/alias_ssh_systems
* Run cluster config commands
```bash
echo "dev root@$mysql1_ip root@$mysql2_ip root@$mysql3_ip root@$mysql4_ip" >> .clusterssh/clusters
```
* It is assumed you have already transferred your id_rsa.pub to authorized_hosts on each system.
* Connect to each server
```bash
cssh dev
```

* * *
<a name=mm>Setup Master-Master</a>
-----
* Download these files 
    * [mysql_vm/mmss/setup_mysql_mmss.sh](https://raw.githubusercontent.com/vikingdata/articles/main/databases/mysql/mysql_vm/mmss/setup_mysql_mmss.sh)
    * [mysql_vm/mmss/accounts_mmss.sql](https://raw.githubusercontent.com/vikingdata/articles/main/databases/mysql/mysql_vm/mmss/accounts_mmss.sql)
    * [mysql_vm/mmss/mmss_rep.sh](https://raw.githubusercontent.com/vikingdata/articles/main/databases/mysql/mysql_vm/mmss/mmss_rep.sh)
    * [mysqld_mmss_my.cnf](https://raw.githubusercontent.com/vikingdata/articles/main/databases/mysql/mysql_vm/mmss/mysqld_mmss_my.cnf)
* It is assumed ssh keys to root of each system is setup.
* execute scripts
```bash

wget https://raw.githubusercontent.com/vikingdata/articles/main/databases/mysql/mysql_vm/mmss/setup_mysql_mmss.sh
wget https://raw.githubusercontent.com/vikingdata/articles/main/databases/mysql/mysql_vm/mmss/accounts_mmss.sql
wget https://raw.githubusercontent.com/vikingdata/articles/main/databases/mysql/mysql_vm/mmss/mmss_rep.sh
wget https://raw.githubusercontent.com/vikingdata/articles/main/databases/mysql/mysql_vm/mmss/mysqld_mmss_my.cnf


bash setup_mysql_mmss.sh
bash mmss_rep.sh

```



* * *
<a name=f>Future</a>
-----

Eventually, MySQL Group Replication Cluter and Percona Cluster script will be added to this doc. 