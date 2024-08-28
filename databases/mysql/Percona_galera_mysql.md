
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
    * https://galeracluster.com/library/training/tutorials/starting-cluster.html 
* https://severalnines.com/blog/improve-performance-galera-cluster-mysql-or-mariadb/

* * *
<a name=install></a>Install  on 3 servers
-----
* Install 3 Linux servers in  VWmware
   * Use NAT networking

* Login as root and run commands on each server. 

```

   # Change to root first, execute next command by itself
sudo bash

   # Optional : remove mysql or percona packages
   # For every package listed do
   # apt-get remove PACKAGE
apt list --installed | egrep -i "mysq|percona"

# Change to multi user mode -- use less memory
systemctl set-default multi-user.target

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
apt-get -y remove percona-xtradb-cluster-57 mysql-common percona-xtradb-cluster-client-5.7 percona-xtradb-cluster-common-5.7 percona-xtradb-cluster-server-5.7 percona-xtrabackup-24

dpkg --purge --force-all percona-xtradb-cluster-server-5.7 percona-xtradb-cluster-common-5.7 percona-xtradb-cluster-client-5.7 percona-xtrabackup-24    mysql-common percona-xtradb-cluster-57 libmysqlclient21 libdbd-mysql-perl

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
* * *
<a name=cluster></a>Configure cluster
-----


* Reset networking to
   * Shutdown each server
   * In VWmare change networking to "Briudged Adapter"
       * This is because the connection to the internet has a problems with "Bridged Adapter", but we don't
       need the internet anymore. But we do need the nodes to see each other.
       * If you need internet access, you can probably setup a proxy. 
* bootstrap first node
* Add 2and 3rd node

* * *
<a name=mon></a>Command line monitoring
-----

* * *
<a name=backups></a>Backups
-----

* * *
<a name=remove></a>Remove a Node
-----

* * *
<a name=add></a>Add a Node
-----

* * *
<a name=restore></a>Restore from backup
-----

* * *
<a name=upgrade></a>Upgrade to 5.7
-----
