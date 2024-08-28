
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
* [Install on 3 servers](#install)
* [Configure cluster](#configure)
* [Remove a Node](#remove)
* [Add a node](#add)
* [Add a slave](#slave)

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
   * Use Bridged Adapter

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
apt-get -y install ssh net-tools emacs plocate
mkdir -p /usr/lib64/galera3/
ln -s /usr/lib/galera3/libgalera_smm.so /usr/lib64/galera3/libgalera_smm.so
ls -al /usr/lib64/galera3/libgalera_smm.so

apt -y remove apparmor
apt update
apt -y install curl 

mkdir -p /root/install
cd /root/install

curl -O https://repo.percona.com/apt/percona-release_latest.generic_all.deb
apt -y install gnupg2 lsb-release ./percona-release_latest.generic_all.deb
apt update

  ## You will be asked to supply a password, for testing purposes only use "root" for password
percona-release enable pxc-57 release
# percona-release enable pxc-80 release
percona-release enable-only tools release


apt -y install percona-xtrabackup-24
apt -y install qpress
   # Enter root twice for password. Only for non-prod testing. 
apt -y install percona-xtradb-cluster-57

echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';" > /etc/mysql/root_init.sql
echo "CREATE USER 'sstuser'@'localhost' IDENTIFIED BY 'passw0rd';" >> /etc/mysql/root_init.sql
echo "GRANT RELOAD, LOCK TABLES, PROCESS, REPLICATION CLIENT ON *.* TO 'sstuser'@'localhost'; " >>/etc/mysql/root_init.sql

echo "" >> /etc/mysql/percona-xtradb-cluster.conf.d/mysqld.cnf
echo "init-file=/etc/mysql/root_init.sql" >> /etc/mysql/percona-xtradb-cluster.conf.d/mysqld.cnf

my_ip=`ifconfig  | grep "inet "| grep -v 127 | sed -e "s/  */ /g" | cut -d ' ' -f3`
echo  "my external ip is $my_ip"

```

Undo
```
apt list --installed | egrep -i "mysq|percona"

apt-get -y remove percona-xtradb-cluster-57 mysql-common percona-xtradb-cluster-client-5.7 percona-xtradb-cluster-common-5.7 percona-xtradb-cluster-server-5.7 percona-xtrabackup-24

dpkg --purge --force-all percona-xtradb-cluster-server-5.7 percona-xtradb-cluster-common-5.7 percona-xtradb-cluster-client-5.7 percona-xtrabackup-24    mysql-common percona-xtradb-cluster-57 libmysqlclient21 libdbd-mysql-perl

apt-get -y install --reinstall mysql-common
apt-get -y purge mysql-common

rm -rf /var/lib/mysql
rm -f /etc/my.cnf
rm -rf /etc/mysql*

apt list --installed | egrep -i "mysq|percona"

```
* * *
<a name=cluster></a>Configure cluster
-----
* Config each server1

### config /etc/mysql/percona-xtradb-cluster.conf.d/wsrep.cnf
Add to /etc/mysql/percona-xtradb-cluster.conf.d/wsrep.cnf
Make sure you change the ip address for the node.
```
[mysqld]
 wsrep_provider=/usr/lib64/galera3/libgalera_smm.so
 wsrep_cluster_name=pxc-cluster
 wsrep_cluster_address=gcomm://<ip1>,<ip2>,<ip3>
   # pxc2 and pxc3 for node 2 and node 3  
 wsrep_node_name=pxc1
 wsrep_node_address=<my ip>
 wsrep_sst_method=rsync
 wsrep_sst_auth=sstuser:passw0rd
 pxc_strict_mode=ENFORCING
 binlog_format=ROW
 default_storage_engine=InnoDB
 innodb_autoinc_lock_mode=2
```
 ### config /etc/mysql/percona-xtradb-cluster.conf.d/mysqld.cnf
Change server-id=1 to server-id=2 and server-id=3 for node 2 and node 3

* bootstrap first node

```
/etc/init.d/mysql bootstrap-pxc
sleep 5
mysql -u root -proot -e "SHOW GLOBAL status WHERE Variable_name in ('wsrep_ready','wsrep_cluster_size');"
mysql -u root -proot \
  -e "SHOW GLOBAL VARIABLES WHERE Variable_name in ('wsrep_cluster_address','wsrep_node_address',  \
     'wsrep_node_name', 'wsrep_sst_method');"

```

* Add 2nd and  3rd node
    * Configure node2 and node3 like node1, but change the ip address, server-id, wsrep_node_name and 
 wsrep_node_address for wsrep.conf and my.conf
    * Just start each server : service mysql stop
* Execute on each server

```
mysql -u root -proot -e "CREATE FUNCTION fnv1a_64 RETURNS INTEGER SONAME 'libfnv1a_udf.so'"
mysql -u root -proot -e "CREATE FUNCTION fnv_64 RETURNS INTEGER SONAME 'libfnv_udf.so'"
mysql -u root -proot -e "CREATE FUNCTION murmur_hash RETURNS INTEGER SONAME 'libmurmur_udf.so'"
mysql -u root -proot -e "SHOW GLOBAL status WHERE Variable_name in ('wsrep_ready','wsrep_cluster_size');"

```

* * *
<a name=mon></a>Command line monitoring
-----
```
mysql -u root -proot -e "SHOW GLOBAL status WHERE Variable_name in ('wsrep_ready','wsrep_cluster_size');"
mysql -u root -proot \
  -e "SHOW GLOBAL VARIABLES WHERE Variable_name in ('wsrep_cluster_address','wsrep_node_address',  \
     'wsrep_node_name', 'wsrep_sst_method');"

``


* * *
<a name=remove></a>Remove a Node
-----
* Shutdown the servers.
* Remove the ip address from the other servers in
```
wsrep_cluster_address=gcomm://<ip1>,<ip2>,<ip3>,<ip4>,etc
```
* On the server to want to remove, comment out 'wsrep_cluster_address' in wresp.cnf

* * *
<a name=add></a>Add a Node
-----
To add a 4th or more node, install is like node 2 or 3, but add the ip address to
```
wsrep_cluster_address=gcomm://<ip1>,<ip2>,<ip3>,<ip4>,etc
```
to each server. 


***
<a name=slave></a>Add a slave
-----
What is the purpose of the slave? Mainly, to run long queries or many queries to take load off
the cluster. The slowest node of the cluster determines the speed of the cluster in general. 


