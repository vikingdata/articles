 
---
title : Mariadb and MySQL differences
author : Mark Nielsen  
copyright : June 2024  
---


MariaDB and MySQL differences
==============================

_**by Mark Nielsen
Original Copyright September 2024**_


1. [Links](#links)

<a name=Links></a>Links
-----
* [Amazon : MariaDB versus MySQL](https://aws.amazon.com/compare/the-difference-between-mariadb-vs-mysql/#:~:text=MariaDB%20is%20more%20scalable%20and,multiple%20engines%20in%20one%20table.)
* https://mariadb.com/kb/en/incompatibilities-and-feature-differences-between-mariadb-10-5-and-mysql-8-/
* https://www.cloudways.com/blog/mariadb-vs-mysql/
* [Incompatabilities](https://mariadb.com/kb/en/incompatibilities-and-feature-differences-between-mariadb-10-5-and-mysql-8-/)
* https://mariadb.com/kb/en/system-variable-differences-between-mariadb-rolling-and-mysql-8-0/
https://mariadb.com/kb/en/mariadb-vs-mysql-compatibility/


<a name=diff></a>Differences

-----

* [Incompatabilities and Feature Differences](https://mariadb.com/kb/en/incompatibilities-and-feature-differences-between-mariadb-10-5-and-mysql-8-/)

MariaDB
* differences
    * Flush Tables by default in MariaDB skips tables in use, and hence won't lock further queries from those tables.
    * MariaDB allows killing all queries for a user. I am still waiting on
killing queries above a certain time.
    * Has MySQLDump, can still use Percona Xtrabackup, but now also
    [MariaDB Backup Stage](https://mariadb.com/kb/en/backup-stage/).
    Has minimal locking and a timeout can be set.
    * Has many more storage engines. Namely. Spider (federated, ODBC, and sharded remote tables), S3, ColumnStore, OQGRAPH, and others. 
    * Proxy (relay the IP of the clients to the server programs)
    HandlerSocket -- fast CRUD operations.
    * WAIT command. It lets you abort after waiting for a lock.
    WAIT 0 is the same as NOWAIT, which aborts if it can't get a lock.
    This prevents the same queries from occuring over and over.
    * Question, does lock_wait_timeout in MySQL achieve the same thing?
    * MariaDB has Oracle compatability mode and supports PL/SQL. It supports
    a subset of capabilities. 

* Json: MariaDB stores as strings. MySQL as binary.
* Thread Pooling. MySQL has better thread pooling with enterprise.
MariaDB is better than MySQL community and enterprise. 
* MariaDB has many more store engines.

<a name=sim></a>Similarities
* Both can use Galera or Group Replication Clusters.
* Table Value Constructors. This lets you select data from a
      table UNION arbitray  data.
    * (MySQL 8.4](https://dev.mysql.com/doc/refman/8.4/en/values.html  

* System-Versioned Tables Or Temporal tables or time travel.
    * mysql 8.4
    * What happens to the table and data if an alter table occurs?

* DDL online
   * Most [MariaDB alters](https://mariadb.com/kb/en/innodb-online-ddl-operations-with-the-inplace-alter-algorithm/)
   * [MySQL 8.4](https://dev.mysql.com/doc/refman/8.4/en/innodb-online-ddl-operations.html)


-------
Other

*https://dev.mysql.com/doc/refman/8.4/en/mysql-nutshell.html