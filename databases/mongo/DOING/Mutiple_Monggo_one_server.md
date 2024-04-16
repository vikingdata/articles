 
---
title : Multiple MngoDB in Linux under WSL under Windows
author : Mark Nielsen  
copyright : March 2024  
---


Multiple MngoDB in Linux under WSL under Windows
==============================

_**by Mark Nielsen
Original Copyright March 2024**_


1. [Links](#links)
2. [Install Linux](#l)
3. [Setup MngoDB image](#m)
4. [Export MngoDB image](#e)
5. [Import MngoDB image](#i)
6. [Setup Master-Master](#mm)
7. [Future](#f)

Purpose is to install Multiple installations of MngoDB in Linux under VirtualBox running in Windows. To set it up for Mac or Linux is almost trivial.

* * *
<a name=Links></a>Links
-----
* TODO WSL linke
* [Install Cygwin](https://www.cygwin.com/install.html)

* * *
<a name=l>Install Linux under WSL</a>
-----


* * *
<a name=m>Setup Mongodb image</a>
-----
```
sudo bash

mkdir /data
ln -s /var/lib/mongodb /data/db
```

* Install Mongodb and other programs
``` bash
sudo bash

  #Set the hostname to mongodb1
hostnamectl set-hostname mongodb1.myguest.virtualbox.org

name=`hostname| cut -d '.' -f1`
ip=`ifconfig | grep inet | head -n1 | sed -e 's/  */ /g' | cut -d ' ' -f3`
echo "alias $name='ssh $ip -l $SUDO_USER '" >> /mnt/shared/alias_ssh_systems
echo "export $name""_name='$name'" >> /mnt/shared/alias_ssh_systems
echo "export $name""_ip=$ip" >> /mnt/shared/alias_ssh_systems
echo "" >> /mnt/shared/alias_ssh_systems


sudo apt-get install gnupg curl
rm -f /usr/share/keyrings/mongodb-server-7.0.gpg 
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
   --dearmor

   # For jammy, check /etc/lsb-release
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

   # If focal
# echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

   # update ubuntu packages
sudo apt-get update

   # Get the latest
apt-get install -y mongodb-org





  # If it did not ask for a password, it will authenicate by auth_socket
  # which you just sudo to root, and it logins automatically
mongodb
```



* * *
<a name=main>Maintenance with WSL and cssh</a>
-----

* Start wsl
    * Install wsl
        * [https://github.com/vikingdata/articles/blob/main/databases/mysql/MySQL_under_wsl2.md](https://github.com/vikingdata/articles/blob/main/databases/mongo/MongoDB_under_wsl2.md)
    * wsl --distribution mongodb1
* Setup cssh to connect to all 4 hosts
    * install cssh [https://www.putorius.net/cluster-ssh.html](https://www.putorius.net/cluster-ssh.html)
        * sudo sudo apt-get install clusterssh
    * source /mnt/c/vm/shared/alias_ssh_systems
* Run cluster config commands
```bash
echo "dev root@$mongodb1_ip root@$mongodb2_ip root@$mongodb3_ip root@$mongodb4_ip" >> .clusterssh/clusters
```
* It is assumed you have already transferred your id_rsa.pub to authorized_hosts on each system.
* Connect to each server
```bash
cssh dev
```
* Also, if you created the ssh keys in cygwin, copy your ssh keys to wsl. Change the username for you. This is how I did it. 
```
mkdir -p .ssh
cd .ssh
rsync -av /mnt/c/cygwin64/home/marka/.ssh/id_rsa* .
chmod 600 id_rsa*

```

* * *
<a name=mm>Setup Mongo replica set</a>
-----
* Download these files 
    * [mongodb_vm/mmss/setup_mongodb_mmss.sh](https://raw.githubusercontent.com/vikingdata/articles/main/databases/mongodb/mongodb_vm/mmss/setup_mongodb_mmss.sh)
    * [mongodb_vm/mmss/accounts_mmss.sql](https://raw.githubusercontent.com/vikingdata/articles/main/databases/mongodb/mongodb_vm/mmss/accounts_mmss.sql)
    * [mongodb_vm/mmss/mmss_rep.sh](https://raw.githubusercontent.com/vikingdata/articles/main/databases/mongodb/mongodb_vm/mmss/mmss_rep.sh)
    * [mongodbd_mmss_my.cnf](https://raw.githubusercontent.com/vikingdata/articles/main/databases/mongodb/mongodb_vm/mmss/mongodbd_mmss_my.cnf)
* It is assumed ssh keys to root of each system is setup.
* execute scripts
```bash

wget https://raw.githubusercontent.com/vikingdata/articles/main/databases/mongodb/mongodb_vm/mmss/setup_mongodb_mmss.sh
wget https://raw.githubusercontent.com/vikingdata/articles/main/databases/mongodb/mongodb_vm/mmss/mmss_rep.sh
wget https://raw.githubusercontent.com/vikingdata/articles/main/databases/mongodb/mongodb_vm/mmss/mongodbd_mmss_my.cnf


bash setup_mongodb_mmss.sh
bash mmss_rep.sh

```



* * *
<a name=f>Future</a>
-----

Eventually, Mongodb Group Replication Cluter and Percona Cluster script will be added to this doc. Also, steps to modify for max or Linux host.


TODO artcile: mongo under wsl