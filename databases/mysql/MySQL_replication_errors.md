
---
title : MySQL Replication Errors
author : Mark Nielsen
copyright : January 2025
---


MySQL Memory
==============================

_**by Mark Nielsen
Copyright January 2025**_

This document will grow continuously. 

1. [Links](#links)
2. (Most common errors)[#e]

* * *
<a name=links></a>Links
-----

* https://dev.mysql.com/doc/mysql-errors/5.7/en/server-error-reference.html
    * Use this to determine the error and if you want to skip all errors of that code in my.cnf. 
* https://genexdbs.com/common-mysql-replication-issues/

* * *
<a name=e></a>Most common errors
-----
Questions to ask
* Are there additional rows above the insert?
* Are the tables in sync between the master and slave except for what hasn't been replicated?
* Are you using SQL or Row level or Mixed Replication?
* Is this for  Cluster as in ClusterSet or regular replication?
* Is this normal or GTID replication?
* Why was there data on the slave already?
* Is there more data on the slave?

Possible reasons
* On a Slave or cluster node someone used set SQL_LOG_BIN=0 and inserted or changed data.
* Multiple replication channels interfered with each other.
* On A Slave, someone inserted data when they shouldn't have. An account has insert permission on a Slave
and the read only global variable is not set. Or "root" changed data.
* A rollback of a transaction including an engine that is not transactional like MyISAM. 
* Replication could have been set to an incorrect file or position. 

Errors and possible solutions
* Duplicate key error 1062
    * On a Cluster, if there is a duplicate key error, determine which node has true data and re sync data from
    good node to bad node.
    * For GTID or non-GTID replication
        * I recommend percona checksum to determine differences in servers. Perhaps check every row as well.
	* There are basically two options, delete data and resume or skip the command. Both solutions requires
	what data is on the master for the row, look at the data on the slave, and look at the data being
	inserted from the relay log on the slave. That should help you determine what to do. If you are using
	SQL replication, you have another problem. Even if you delete the row on the slave, the insert command
	may not be the same when you resume replication --- what if there is data after that row? Autoincrement
	won't be the same on the master as the slave. Demonstrations are given below.
```
   # Setup replication between master and slave. 

   ## On MySQL master -- we assume row level for now. 
show global variables like 'binlog_format';
drop database if exists test1;
create database test1;
use test1;
create table i (i int, PRIMARY  KEY (i));
insert into i values (1);

  ## On Slave
show databases like 'test1';
use test1;
show tables like 'i';
set SQL_LOG_BIN=0;
insert into i values (2);

  ## on Master
insert into i values (2);
insert into i values (3);
insert into i values (4);
insert into i values (5);

  ## On slave
  ## This should show an error.
show slave status\G

  ## At this point use mysqlbinlog to examine the data being inserted on the slave.
  ## Also, compare the data on the master and slave for that row.
  ## The data on the master and slave have to be identical in the end. 

  ## We determine we can skip.
  ## On slave
SET SQL_LOG_BIN=0;
  ## If you multiple replication channels, you might have to specify. 
SET GLOBAL sql_slave_skip_counter =1;
start slave;
  ## See If there are any errors.
show slave status\G

  ## OPTION 2 -- we assume replication is normal.
  ## On Slave
set SQL_LOG_BIN=0;
insert into i values (10);
  

  ## On master
insert into i values (10);
insert into i values (11);
insert into i values (12);
insert into i values (13);
  
  ## On Slave
  ## We determine table = i, row = 10 is the issue.
  ## We determine the data being inserted is the same as on the master.
  ## We looked at the row on the master and used mysqlbinlog on relay log on slave. 
delete from slave where i = 10;
start slave;
show slave status\G
```
* Duplicate key errors with GTID replication
    * Determine the row on the master and slave and what data the binlog is doing.
    * Delete row and resume replication.
    * Or skip GTID replication with
        * https://www.percona.com/blog/how-to-skip-replication-errors-in-gtid-based-replication/
	* Or set next GTID and resume : https://dev.mysql.com/doc/mysql-replication-excerpt/8.0/en/replication-administration-skip-gtid.html
	
* Transaction timeout or other timeout
   * Resume replication with "start slave"

* Error 1032 – Missing Records
    * Are there other rows missing?
    * I would either restore the slave from scratch, or use percona pt-sync. I would not trust there
    are other errors. Get them in sync and then do pt-checksum. 
