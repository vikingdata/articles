
---
title : Percona Galera Mysql
author : Mark Nielsen
copyright : August 2024 
---


Percona Galera Mysql
==============================

_**by Mark Nielsen
Original Copyright August 2024**_

We will install it on one computer. It is meant for functional testing and not performance. 

* [Links](#links)
* [Install on one server](#install)
* [Variables to pay attention to](#vars)
* [Command line monitoring](#mon)

* * *
<a name=Links></a>Links
-----
* Adding ip via rc.local and other
    * I couldn't figure out network.services
    * https://www.linuxbabe.com/linux-server/how-to-enable-etcrc-local-with-systemd
    * https://www.baeldung.com/linux/create-remove-systemd-services
* Install
    * https://docs.percona.com/percona-xtrabackup/2.4/installation/apt_repo.html#installing-percona-xtrabackup-via-percona-release
    * https://docs.percona.com/percona-software-repositories/index.html
    * https://docs.percona.com/percona-xtradb-cluster/5.7/install/apt.html#apt
    * https://repo.percona.com/
* https://severalnines.com/blog/improve-performance-galera-cluster-mysql-or-mariadb/


* * *
<a name=ip></a>Add ip addresses to Ubuntu
-----
```
   # Change to root first, execute next command by itself
sudo bash


echo "

[Unit]
 Description=/etc/rc.local Compatibility
 ConditionPathExists=/etc/rc.local

[Service]
 Type=forking
 ExecStart=/etc/rc.local start
 TimeoutSec=0
 StandardOutput=tty
 RemainAfterExit=yes
 SysVStartPriority=99

[Install]
 WantedBy=multi-user.target


" > /etc/systemd/system/rc-local.service

echo '#!/bin/bash

/usr/sbin/ifconfig lo:2 127.0.0.2 netmask 255.0.0.0 up
/usr/sbin/ifconfig lo:3 127.0.0.3 netmask 255.0.0.0 up
/usr/sbin/ifconfig lo:4 127.0.0.4 netmask 255.0.0.0 up
/usr/sbin/ifconfig lo:5 127.0.0.5 netmask 255.0.0.0 up
/usr/sbin/ifconfig lo:6 127.0.0.6 netmask 255.0.0.0 up

' > /etc/rc.local

chmod +x /etc/rc.local

/etc/rc.local

  # Test with ifconfig

ifconfig | grep -i lo:

  # Optional, test with ping
for i in 2 3 4 5 6; do ping -c 1 127.0.0.$i; done

  # enable it on reboot
systemctl enable rc-local

echo "
127.0.0.2 localhost2
127.0.0.3 localhost3
127.0.0.4 localhost4
127.0.0.5 localhost5
127.0.0.6 localhost6

" >> /etc/hosts

```

* * *
<a name=install></a>Install on one server
-----

```

   # Change to root first, execute next command by itself
sudo bash

   # Optional : remove mysql or percona packages
   # For every package listed do
   # apt-get remove PACKAGE
apt list --installed | egrep -i "mysq|percona"



apt -y remove apparmor
apt update
apt -y install curl 

mkdir -p /root/install
cd /root/install

curl -O https://repo.percona.com/apt/percona-release_latest.generic_all.deb
apt -y install gnupg2 lsb-release ./percona-release_latest.generic_all.deb
apt update

  ## we want 5.6, because we want to upgrade. 
  ## You will be asked to supply a password, for testing purposes only use "root" for password
percona-release enable pxc-57 release
# percona-release enable pxc-80 release
percona-release enable-only tools release


apt -y install percona-xtrabackup-24
apt -y install qpress
   # Enter root twice for password. Only for non-prod testing. 
apt -y install percona-xtradb-cluster-57

mysql -u root -proot -e "CREATE FUNCTION fnv1a_64 RETURNS INTEGER SONAME 'libfnv1a_udf.so'"
mysql -u root -proot -e "CREATE FUNCTION fnv_64 RETURNS INTEGER SONAME 'libfnv_udf.so'"
mysql -u root -proot -e "CREATE FUNCTION murmur_hash RETURNS INTEGER SONAME 'libmurmur_udf.so'"

systemctl list-units -a | egrep -i "mysql|percona"
  # Stop mysql

service mysql stop


ls -al /etc/my/conf
```

Undo
```
apt list --installed | egrep -i "mysq|percona"

apt-get -y remove percona-xtrabackup-24
apt-get -y remove percona-xtradb-cluster-57 mysql-common percona-xtradb-cluster-client-5.7 percona-xtradb-cluster-common-5.7 percona-xtradb-cluster-server-5.7

dpkg --purge percona-xtradb-cluster-server-5.7 percona-xtradb-cluster-common-5.7 percona-xtradb-cluster-client-5.7 percona-xtrabackup-24  percona-xtradb-cluster-common-5.7  mysql-common

apt-get -y install --reinstall mysql-common
apt-get -y purge mysql-common


rm -rf /var/lib/mysql
rm -f /etc/my.cnf
rm -rf /etc/mysql*

apt list --installed | egrep -i "mysq|percona"

systemctl status mysql
systemctl disable mysql

ls -alh /etc/systemd/system/mysql.service /usr/lib/systemd/system/mysql
rm -fv /etc/systemd/system/mysql.service
rm -fv /usr/lib/systemd/system/mysql.serrvice


```
kill mysqld
sleep(2)
kill -9 mysqld


* Install
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* Remove previous installation
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* Install config files
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* Initziation directories
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* Start first node
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* Add other nodes
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* Check cluster
```
service --status-all  | grep mysql
systemctl disable mysql
systemctl disable mysqlrouter

  # Skip this part if never installed before
kill mysqld
sleep(2)
kill -9 mysqld
for i in 1 2 3; do
  rm -rf /database/cluster/node$i/db
done

# Setup config and directories

for i in 1 2 3; do
  mkdir -p /database/cluster/node$i/db
done
mkidr -p /database/cluster/etc/init.d
chown -R mysql.mysql /database/cluster

wget -O /tmp/my.cnf https://raw.githubusercontent.com/vikingdata/articles/main/databases/mysql/Percona_galera_mysql_files/my.cnf

wget -O /tmp/mysql.service https://raw.githubusercontent.com/vikingdata/articles/main/databases/mysql/Percona_galera_mysql_files/mysql.service

wget -O /tmp/mysql https://raw.githubusercontent.com/vikingdata/articles/main/databases/mysql/Percona_galera_mysql_files/mysql_init


for i in 1 2 3; do
  sed -e 's/__NODE__/$i/g' /tmp/my.cnf > /database/cluster/etc/my$i.cnf
  sed -e 's/__NODE__/$i/g' /tmp/mysql > /database/cluster/etc/init.d/mysql$i
  sed -e 's/__NODE__/$i/g' /tmp/mysql.service > /etc/systemd/system/mysql$i.service 
done

ls /etc/systemd/system/mysql*



```

* * *
<a name=service></a>Make service and start
-----


* * *
<a name=vars></a>Variables to pay attention to
-----

* * *
<a name=mon></a>Command line monitoring
-----

* * *
<a name=add></a>Add a Node
-----

* * *
<a name=remove></a>Remove a Node
-----

* * *
<a name=backups></a>Backups
-----

* * *
<a name=upgrade></a>Upgrade to 5.7
-----
