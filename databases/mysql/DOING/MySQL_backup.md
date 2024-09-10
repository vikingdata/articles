
---
title : MySQL Backup
author : Mark Nielsen
copyright : September 2024
---


MySQL Backup
==============================

_**by Mark Nielsen
Original Copyright September 2024**_

1. [links](#links)
2. [MySQLDump](#mysqldump)

* * *
<a name=links></a>Links
-----

* * *
<a name=setup></a>Setup
-----

* We will have 3 servers. One Master, one slave, and a 2nd slave we will
restore from using the 1st slave. 
* Install MySQL on all 3 servers. Outside of scope of article.
    * EX: for Ubuntu:
* Setup replicaion from Master to Slave. 
    * Add slave account on all servers.
        * On master
    * Configure replication on slave from first position on master. No need
    for backup. 
    * Start replication. 
 



* * *
<a name=mysqldump></a>MySQLDump
-----



* * *
<a name=percona></a>Xtrabakcup
-----

* * *
<a name=lvm></a>LVM
-----

* * *
<a name=lvm></a>Binary
-----

* * *
<a name=lvm></a>LVM
-----
The whole trick with snapshots is
* Make snapshot appropriately.
* Mount snapshot on same computer or another computer. 
* Start another mysql using snapshot.
* Take a backup using one of the methods.
* Shutdown 2nd mysql instance and remove LVM partition. 
* Restore backup on another computer.

 Setup an additional partition. 
* Add partition to VirtualBox
    * https://www.tecmint.com/list-disks-partitions-linux/
        * Make a parition of 25 Gigs. 
    * In linux, use lvm
```    
service mysqld stop

apt install lvm2
vgcreate mysql_group /dev/sdb
  # Depending on how you created the partition, the device may
	    be different. Mine was /dev/sdb
pvdisplay /dev/sdb
lvcreate -L10G -nmysql mysql_group
mkdir -p /database
mkfs  -t ext4 /dev/mysql_group/mysql
mkdir -p /database/mysql
chown -R mysql.mysql 
mount /dev/mysql_group/mysql /database
  # Recommendation: Change /etc/fstab to mount this dorectory   on reboot. 
chown -R mysql.mysql /database/mysql/db

## Move mysql
mv /var/lib/mysql /var/lib/mysql_OLD
rsync -av /var/lib/mysql_OLD/* /database/mysql/db/
ln -n /database/mysql/db /var/lib/mysql
