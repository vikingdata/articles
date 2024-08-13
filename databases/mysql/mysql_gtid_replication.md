
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
4. [Resetting replication at a point](#reset)
5. [Reset GTID replication](#reset2)
6. [Reset normal replication](#reset3)

* * *
<a name=links></a>Links
-----
* [Repair - replace -  a slave gtid](https://docs.percona.com/percona-xtrabackup/2.4/howtos/recipes_ibkx_gtid.html)
* Setup GTID
    * [Setting Up Replication Using GTIDs](https://dev.mysql.com/doc/mysql-replication-excerpt/8.0/en/replication-gtids-howto.html)
    
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

* On both servers
```
 ## Add this to /etc/my.cnf

gtid_mode=ON
enforce-gtid-consistency=ON
log-slave-updates=ON
```
* On both servers : service mysql restart
* <a href=#reset>Reset</a> the servers described below. 



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
--  removes slave settings
reset slave all;

-- removes slave binlog gtid settings
reset master;    
```

* On master in mysql
```
drop user if exists 'repl'@'%';
drop user if exists 'remote'@'%';
CREATE USER if not exists 'repl'@'%' IDENTIFIED BY 'repl';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';

CREATE USER if not exists 'remote'@'%' IDENTIFIED BY 'bad_password';
GRANT all privileges ON *.* TO 'remote'@'%';

```

* On both servers at Linux prompt
```
  ## REmoves all binlogs, starts fresh
service mysql stop
rm -vf /var/lib/mysql/binlog.*
service mysql start
```

* On master in mysql
```
reset master; -- removes gitd settings from master
drop database if exists rep_test;
create database rep_test;
```

* On master in mysql in Linux
```
ip=`ifconfig | grep inet | head -n1 | sed -e 's/  */ /g' | cut -d ' ' -f3`
echo "master ip = $ip"
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
stop SLAVE; 
select sleep (1);
start slave;
select sleep (1);
show slave status\G
show databases like '%rep_test%';

```


```

SELECT * FROM performance_schema.global_variables
  WHERE VARIABLE_NAME like 'gtid_executed'
    OR VARIABLE_NAME like 'gtid_purged';
```


* * *
<a name=reset3></a>Reset normal replication
-----
* We assume no connections are written to master.
* On mastger
```
drop user if exists 'repl'@'%';
drop user if exists 'remote'@'%';
CREATE USER if not exists 'repl'@'%' IDENTIFIED BY 'repl';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';

CREATE USER if not exists 'remote'@'%' IDENTIFIED BY 'bad_password';
GRANT all privileges ON *.* TO 'remote'@'%';
```
* On both servers
```
service mysql stop
rm -vf /var/lib/mysql/binlog.*
service mysql start
```

* Stop GTID replication, on both if given. If GTID is turned off, skip this. 
```
stop slave;
set GLOBAL gtid_mode=on_permissive;
set GLOBAL gtid_mode=OFF_PERMISSIVE;
CHANGE REPLICATION SOURCE TO SOURCE_AUTO_POSITION = 0;
set GLOBAL gtid_mode=OFF;
set GLOBAL enforce_gtid_consistency=off;

```

* On master
```
show master status;
drop database if exists rep_test;
create database rep_test;

```

Output -- Just need values for "File" and "Position"
```
| File          | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set                        |
+---------------+----------+--------------+------------------+------------------------------------------+
| binlog.000001 |      153 |              |                  | 7ca9a3f5-f52b-11ee-b56f-080027a5063b:1-2 |

```
* On master in mysql in Linux
```
ip=`ifconfig | grep inet | head -n1 | sed -e 's/  */ /g' | cut -d ' ' -f3`
echo "master ip = $ip"
```
Output
```
  # NOTE your ip address will be different.
  master ip = 192.168.0.217

```

* On Slave, make a dummy connection. For some reason, I needed to connect on my system before
the replication thread could connect. It makes no sense. 
```
mysql -u repl -prepl -h 192.168.0.217 -e "show status"
```


* On slave, you can configure replication with starting position or none to start
from the beginning;
```
reset slave all;

CHANGE REPLICATION SOURCE TO
 SOURCE_HOST = '192.168.0.217',
 SOURCE_USER = 'repl',
 SOURCE_PASSWORD = 'repl';
start slave; 
stop SLAVE;
select sleep (1);
start slave;
select sleep (1);
show slave status\G
show databases like '%rep_test%';


```
