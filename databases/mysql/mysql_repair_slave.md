
---
title : MySQL Repair Slave
author : Mark Nielsen
copyright : August 2024 
---

MySQL Repair Slave
==============================
_**by Mark Nielsen
Original Copyright June 2024**_




Index

1. [Repair norma Slavel](#normal)
2. [Repair GTID](#gtid)

* * *
<a name=normal></a>MySQL repair normal Slave
-----
* Restore Slave from Backup or make non-blocking backup from master or
other slave. 
* Fix Slave Replication is possible.
    * Reset slave to last executed position.
    * 


* * *
<a name=gtid></a>MySQL repair GTID Slave
-----

Options
* Restore Slave from backup
    * 5.6 https://www.percona.com/blog/how-to-createrestore-a-slave-using-gtid-replication-in-mysql-5-6/
* Fix slave

We will opt the fix the slave.
* First install virtualbox and follow this article.
    * https://github.com/vikingdata/articles/blob/main/databases/mysql/Multiple_MySQL_virtualbox.md#mm
    * You do not need to worry about replication.
* Record the ip addresses or the servers.
    * Use : execute: ifconfig | grep inet | grep "netmask 255.255.255.0"
       * You will see something like : inet 192.168.0.217
    * Log into 2 mysql servers.
* On both servers:
   * Add to my.cnf
```
 ## Add this to /etc/my.cnf

gtid_mode=ON
enforce-gtid-consistency=ON
log-slave-updates=ON

```
* On both servers : service mysql restart
* On both servers,
    * log into mysql as root: sudo mysql -u root
    * and execute
```
CREATE USER 'repl'@'%' IDENTIFIED BY 'repl';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';

CREATE USER 'remote'@'%' IDENTIFIED BY 'bad_password';
GRANT all privileges ON *.* TO 'remote'@'%';

```
* On master  as mysql root:
```

create database temp1;
PURGE BINARY LOGS BEFORE now();


