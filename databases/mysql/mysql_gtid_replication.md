
---
title : MySQL Replication
author : Mark Nielsen
copyright : August 2024 
---

MySQL GTID Replication
==============================
_**by Mark Nielsen
Original Copyright June 2024**_

Explanation
1. anonymous
2. gtid executed
3. gtid purged
4. gtid next


Index

0. [Links](#links)
1. [Setup GTID](#setup)
2. [Convert replication to GTID](#convert)
3. [Skipping query on Slave](#skip)
4. [Resetting replication at a point]($reset)

* * *
<a name=links></a>Links
-----
* (Repair - replace -  a slave gtid)[https://docs.percona.com/percona-xtrabackup/2.4/howtos/recipes_ibkx_gtid.html)]
* Setup GTID
    * (Setting Up Replication Using GTIDs)[https://dev.mysql.com/doc/mysql-replication-excerpt/8.0/en/replication-gtids-howto.html]
    
* SKip Query GTID
    * [MySQL replication — Skipped GTID and how to fix it](https://medium.com/@brianlie/mysql-replication-skipped-gtid-and-how-to-fix-it-a2d836452724)
    * https://www.percona.com/blog/how-to-skip-replication-errors-in-gtid-based-replication/
    * https://mysqlwall.com/2021/11/30/how-to-skip-transaction-on-replica-when-gtid-replication-is-broken/
* Other
   * (A Useful GTID Feature for Migrating to MySQL GTID Replication – ASSIGN_GTIDS_TO_ANONYMOUS_TRANSACTIONS)[https://www.percona.com/blog/useful-gtid-feature-for-migrating-to-mysql-gtid-replication-assign_gtids_to_anonymous_transactions/]
   * https://www.red-gate.com/simple-talk/blogs/a-beginners-guide-to-mysql-replication-part-4-using-gtid-based-replication/
   * https://percona.community/blog/2021/11/08/the-errant-gtid-pt1/
   * https://www.percona.com/sites/default/files/presentations/mysql_56_GTID_in_a_nutshell.pdf

* * *
<a name=setup></a>Setup GTID
-----



* * *
<a name=convert></a>Convert replication to GTID
-----

* * *
<a name=skip></a>Skipping query on Slave
-----

* * *
<a name=reset></a>Resetting replication at a point
-----


* * *
<a name=reset2></a>Reset gtid replication
-----
* On slave in MySQL
```
 stop slave;
mysql> reset master all;
```
* On both servers at Linux prompt
```
service mysql stop
rm -f /var/lib/mysql
service mysql start
```

* On both servers in mysql
```
 CREATE USER 'repl'@'%' IDENTIFIED BY 'repl';
 GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
 CREATE USER 'remote'@'%' IDENTIFIED BY 'bad_password';
 GRANT all privileges ON *.* TO 'remote'@'%';

```

* On master in mysql
```
 drop database if exists rep_test;
 create database rep_test;
```

* On master in mysql in Linux
```
ip=`ifconfig | grep inet | head -n1 | sed -e 's/  */ /g' | cut -d ' ' -f3`
echo "master ip - $ip"
```
Output
```
  # NOTE your ip address will be different. 
master ip = 192.168.0.217

```


* On slave in mysql
```
 drop database if exists rep_test;
 CHANGE REPLICATION SOURCE TO
     SOURCE_HOST = '192.168.0.217',
     SOURCE_USER = 'repl',
     SOURCE_PASSWORD = 'repl',
     SOURCE_AUTO_POSITION = 1;
 start slave;

```


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


SELECT * FROM performance_schema.global_variables
  WHERE VARIABLE_NAME like 'gtid_executed'
    OR VARIABLE_NAME like 'gtid_purged';
```


