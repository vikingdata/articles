---
title : MySQL To Percona Innodb Cluster
author : Mark Nielsen
copyright : January 2025
---


MySQL to Percona InnoDB cluster
=============================

_**by Mark Nielsen
Copyright January 2026**_


1. [Links](#links)
2. [Requirements](#r)
2. [Steps](#s)

* * *
<a name=links></a>Links
-----

TODO: Link these links
* Setup Virtual Box, base image, firewall 3 ports, 3 virtual box images
  and port forwarding
    * Virtual Box Install
    * Making a base image
    * Setup 3 firewalled ports
    * Setup 3 virtual box servers
    * Do port forwarding and Nat Network

* * *
<a name=r></a>Requirements
-----
* Virtual Box installed
     * Installed on Windows 11
     * Installing Oracle Linux 8 under VirtualBox
     * Linux instances use Nat Network so they can see each other.
     * You use port forwarding in VirtualBox to ssh to a windows port which
        ssh to the Linux instances on port 22.
     * You block he windows ports with firewall from the outside.	
* OracleLinue 8.10
* MySQL 8.0.43 InnoDB CLuster
* Converting to Percona 8.4.7 Innodb Cluster (not Galera Cluster)
* Turn on auditing in Percona

* * *
<a name=s></a>Steps
-----

Steps
* Setup install directory
```
mkdir -p mysql_to_percona
cd mysql_to_percona

* Record saving ip addresses and usernames.

echo "

   # change these values to your values to your servers. 
export server1=10.0.2.29
export server2=10.0.2.28
export server3=10.0.2.30
export remote_user=root
export remote_password=mark

export s1_port=2001
export s2_port=2002
export s3_port=2003

" > global_vars.sh

```

* Setup ssh 
```
ssh-keygen -t rsa -b 4096  -q -N '' -q -f id_rsa

source global_vars.sh
echo "

for p in $s1_port $s2_port $s3_port; do

  echo 'enter root password, setting up ssh keys'
ssh -o StrictHostKeyChecking=no root@127.0.0.1 -p \$p 'mkdir -p /root/.ssh;  mkdir -p /home/mark/.ssh'
  echo 'enter root password, setting up authorized keys'
scp -o StrictHostKeyChecking=no -P \$p id_rsa.pub root@127.0.0.1:/root/.ssh/authorized_keys

  echo 'Copying key to user mark'
scp -o StrictHostKeyChecking=no -P \$p id_rsa.pub root@127.0.0.1://home/mark/.ssh/authorized_keys
ssh -o StrictHostKeyChecking=no root@127.0.0.1 -p \$p 'chown -R mark /home/mark'


echo 'Setting up mark to sudo without password'
ssh -o StrictHostKeyChecking=no root@127.0.0.1 -p \$p \" echo '$MY_USER ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \"

done
"  > ssh_install

```