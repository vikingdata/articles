
---
title : MySQL General
author : Mark Nielsen
copyright : June 2024 
---


MySQL General
==============================

_**by Mark Nielsen
Original Copyright June 2024**_

This article will grow over time. 


* [tail a gzip file](#tailgzip)
* [Info queries](info_queries.md)
* [MySQL variables](MySQL_variables.md)
* [Backup Restore Replication](mysql_backup_restore_replication.md)
* [What causes swap](#swap)
* [Show multiple variables from 'show'](#show)
* [Removing large undo files](#undo)
* [Binlogs](#binlog)
* Heap Tables -- doing
* Encrypt Data
* Code Review -- doing
* CPU spikes changes -- doing
* [Join versus subquery](#join)
* [Fix root permissions](#root)
* * *
<a name=tailgzip></a>Tail a gzipped file
-----

Assume a file is called File.gz

### Long way
This takes a long time since it has to unzip the entire file before doing tail.

```
zcat FILE.gz | tail -n 5

  ## or
gunzip -c FILE.gz | tail -n 5

```

### Faster way
A faster way is to NOT decompress the entire file.
For more information: https://github.com/circulosmeos/gztool

```
gztool -t FILE.gz | tail -n 5

```

### Or leave file uncompressed
```
tail -n 5 FILE.sql
```

* * *
<a name=swap></a>What causes swap
-----

* transparent huge pages set to active
   * cat /sys/kernel/mm/transparent_hugepage/enabled
       * Should be :  always [madvise] never
   * To turn off
       * echo never > /sys/kernel/mm/transparent_hugepage/enabled
       * echo never > /sys/kernel/mm/transparent_hugepage/defrag
* jemalloc  https://support.sentieon.com/appnotes/jemalloc/
   * centos
       * yum install epel-release
       * yum install jemalloc
   * ubuntu
       * apt update
       * apt install libjemalloc2
   * Install in mysql my.cnf and then restart mysql
```
[mysqld_safe]
   # Make sure you load the right library
   # depending on how jemaloc was installed
   # check which library file got installed on your system
malloc-lib=/usr/lib64/libjemalloc.so.1
```
* swapinesss to 1
    * cat /proc/sys/vm/swappiness
    * Should be set to "0"
    * Change it : https://linuxize.com/post/how-to-change-the-swappiness-value-in-linux/
        * sudo sysctl vm.swappiness=0
        * edit sudo sysctl vm.swappiness=0
            * vm.swappiness=0
* high temp tables memory settings in mysql with an engine Engine
    * MEMORY
      * tmp_table_size
      * max_heap_table_size
    * TempTable	   
      * tmp_table_size
      * temptable_max_ram
* Note enough ram
    * [Look at the innodb buffer pool ratio](info_queries.md#ibpr)
    * [Analyze ram and swap use](https://github.com/vikingdata/articles/blob/main/linux/Linux_general.md#m) -- Monitor commands
* MySQL memory considerations : https://mariadb.com/kb/en/mariadb-memory-allocation/

* * *
<a name=show></a>Show multiple variables from 'show'
-----
* https://dev.mysql.com/doc/refman/8.4/en/regexp.html
* https://www.geeksforgeeks.org/rlike-operator-in-mysql/

```
SHOW GLOBAL STATUS WHERE Variable_name RLIKE 'read';
SHOW GLOBAL STATUS WHERE Variable_name RLIKE '_read';
SHOW GLOBAL STATUS WHERE Variable_name RLIKE 'read_';
SHOW GLOBAL variables WHERE Variable_name = 'gtid_executed' or Variable_name = 'gtid_purged';

SELECT * FROM performance_schema.global_status
 WHERE VARIABLE_NAME like '%read%';
 
SELECT * FROM performance_schema.global_variables
 WHERE VARIABLE_NAME like 'gtid_executed'
     OR VARIABLE_NAME like 'gtid_purged';

```
* * *
<a name=undo></a>Remove large undo files
-----
Links
* https://dev.mysql.com/doc/refman/8.4/en/innodb-undo-tablespaces.html#innodb-drop-undo-tablespaces

* Make sure this is in my.cnf and is in global variables
    * SET GLOBAL innodb_undo_log_truncate=ON;
* Increase the purge frequency -- by lowering the number. Check undo logs described below and see if they auto-purge. 
```
show global variables like 'innodb_purge_rseg_truncate_frequency';

+--------------------------------------+-------+
| Variable_name                        | Value |
+--------------------------------------+-------+
| innodb_purge_rseg_truncate_frequency | 128   |
+--------------------------------------+-------+

SET GLOBAL innodb_purge_rseg_truncate_frequency=32;

```
* Increase the amount of threads
```
 set GLOBAL innodb_purge_threads=8;
```

* Kill all processes or restart mysql
    * Before you do this, get permission.
    * The goal is to release a query that might be causing the undo log to grow by not releasing a commit.
        * You can also try to kill long running queries. 
* NOTE: innodb_undo_001 and innodb_undo_002 are reserved and CANNOT be manually truncated. You must
allow them to auto truncate. 
* Select all undo files
```
SELECT TABLESPACE_NAME, FILE_NAME FROM INFORMATION_SCHEMA.FILES
  WHERE FILE_TYPE LIKE 'UNDO LOG';
```
Output
```
+-----------------+------------+
| TABLESPACE_NAME | FILE_NAME  |
+-----------------+------------+
| innodb_undo_001 | ./undo_001 |
| innodb_undo_002 | ./undo_002 |
+-----------------+------------+

```
* Create new undo file -- note it may ask for full path. 
```
CREATE UNDO TABLESPACE  temp_undo ADD DATAFILE 'undo_003.ibu';
```
* Disable previous large undo
```
ALTER UNDO TABLESPACE innodb_undo_002 SET INACTIVE;
```
* Select status of undo file until Free_Extents stops.
```
 SELECT file_id, file_name, file_type, free_extents, total_extents, initial_size FROM
 INFORMATION_SCHEMA.FILES   WHERE FILE_NAME='./undo_002'\G

*************************** 1. row ***************************
       FILE_ID: 4294967151
     FILE_NAME: ./undo_002
     FILE_TYPE: UNDO LOG
  FREE_EXTENTS: 200
 TOTAL_EXTENTS: 1000
  INITIAL_SIZE: 1677721611

```

* Keep executing this query until its say empty. Auto purging should happen automatically.
By disabling the file, letting it empty, and activating it will auto purge the file. 
```
SELECT NAME, STATE FROM INFORMATION_SCHEMA.INNODB_TABLESPACES   WHERE NAME LIKE '%undo2%';
+-----------------+--------+
| NAME            | STATE  |
+-----------------+--------+
| innodb_undo_002 | empty  |
+-----------------+--------+
```

* Enable previous large undo
```
ALTER UNDO TABLESPACE innodb_undo_002 SET ACTIVE;
```

* Wait a while and check again and it should decrease now. 
```
SELECT file_id, file_name, file_type, free_extents, total_extents, initial_size FROM
INFORMATION_SCHEMA.FILES   WHERE FILE_NAME='./undo_002'\G
*************************** 1. row ***************************
      FILE_ID: 4294967151
          FILE_NAME: ./undo_002
	      FILE_TYPE: UNDO LOG
	       FREE_EXTENTS: 2
	       TOTAL_EXTENTS: 16
	        INITIAL_SIZE: 16777216


```

* Check diskspace:
    * df -h
    * ls -alh /var/lib/mysql/undo*
```
-rw-r----- 1 mysql mysql 16M Aug  7 10:57 /var/lib/mysql/undo_001
-rw-r----- 1 mysql mysql 16M Aug  7 10:55 /var/lib/mysql/undo_002
-rw-r----- 1 mysql mysql 16M Aug  7 10:57 /var/lib/mysql/undo_003.ibu
```
* Deactivate and then drop the 3rd undo log.

```
MySQL [test1]> ALTER UNDO TABLESPACE temp_undo SET INACTIVE;
Query OK, 0 rows affected (0.022 sec)

MySQL [test1]> ALTER UNDO TABLESPACE temp_undo SET ACTIVE;
Query OK, 0 rows affected (0.030 sec)
```

* Other Info
   * SELECT NAME, SUBSYSTEM, COMMENT FROM INFORMATION_SCHEMA.INNODB_METRICS WHERE NAME LIKE '%truncate%';
   

* * *
<a name=binlog></a>Binlog stuff
-----
* Extract queries from binlog with row level replication : [mysqlbinlog Row Event Display](https://dev.mysql.com/doc/refman/8.4/en/mysqlbinlog-row-events.html)
```
mysqlbinlog  --base64-output=DECODE-ROWS --verbose FILE > FILE.sql

```

* * *
<a name=heap></a>Heap Tables
-----
* detect which engine

* Different engines

* detect if heap or temporary tables are large enough

* Make larger

* Note : More memory assigned to heap tables take up more memory


* * *
<a name=encrypt></a>Encrypt Data 
-----
* Transit -- Use all. For MySQL, in the server or client you can force ssl. 

* Encryption at rest. In general you need
    * A module that does encryption for your data. The module takes care of
    encrypting the data on disk, and maybe cached data. Normally doesn't affect
    data in transit. Before data in transferred it is decrypted. 
    * Encryption keys are used to store the data on disk (and maybe memory cache). This means data backups need the keys to decrypt in order to read the data. It also means if you restore binary copies of the data the database service needs the keys to read and write to the existing data. 
    * The module can read the encryption keys from disk or get them from another server. A more secure environment uses a server to store keys and which other
    servers are allowed to have the keys.
    * MySQL :
        * https://www.mysql.com/products/enterprise/tde.html
        * https://dev.mysql.com/doc/refman/8.4/en/innodb-data-encryption.html
        * https://info.townsendsecurity.com/how-mysql-enterprise-transparent-data-encryption-works
    * Percona
        * https://www.percona.com/blog/percona-server-for-mysql-encryption-options-and-choices/
        * https://www.percona.com/blog/transparent-data-encryption-tde/
	* One issues with Percona in the past, which may be solved by now, is
	that servers every 30 days needed to be restarted to get the keys. This
	doesn't happen with MySQL Enterprise as I understand.

Encrypting data

* MySQL
   * Setup a server to store the keys.
   * Configure my.cnf to support encryption.
       * https://dev.mysql.com/doc/refman/8.4/en/innodb-data-encryption.html#:~:text=To%20enable%20encryption%20for%20the,using%20an%20ALTER%20TABLESPACE%20statement.
   * Tables should File-Per-Table
   * Change the default for new tables to be encrypted with default_table_encryption. 
   * For each table : ALTER TABLESPACE ts1 ENCRYPTION = 'Y';
   * Also consider REDO and UNDO logs to be encrypted using  innodb_redo_log_encrypt and  innodb_redo_log_encrypt.
* Percona
* [AWS RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.Encryption.html)
    * Use AWS KMS keys
    * You have to turn on encryption while you make it.
    * However, you can encrypt a copy of the database and restore it as
    encrypted.
        * Take snapshot, make an encrypted copy, restore encrypted copy. 
* [AWS Aurora](*https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Overview.Encryption.html)
    * Uses [ AWS Key Management Service-AWS KMS ](https://docs.aws.amazon.com/kms/latest/developerguide/)
    * You have to turn on encryption while you make it.
    * However, you can encrypt a copy of the database and restore it as
    encrypted.
        * Take snapshot, make an encrypted copy, restore encrypted copy.

* * *
<a name=Code></a>Code Review
-----
Code review just concerns itself with schema and stored procedure changes
and scripts that are database related (like backup scripts).

* Dev, QA, Staging, Prod cycle

* 2 people review code

* Test code : Note any locking changes to schema. 

* * *
<a name=spike></a CPU spikes changes
-----
* Are there any locks?

* Are there any long running queries? Over 5 seconds.

* What is the history of cpu spikes on graph?

* Are there alarms for spikes at warning, error, and critical?

* Are total connections way less than max connections?

* Record queries and run explain on them. Look at slow long. 

* * *
<a name=join></a>Join versus subquery
-----
* Links
    * https://adamtlee.medium.com/sql-subqueries-vs-join-9bcb921a5b2e

* For running explains,
    * it is easier for joins to predict explain plans
    * Making plans for subroutines might involve running sub queries
    * Joins are made one to one with results. Subqueries may also be one to one with results. But using "in" with subqueries may result one more than one
    run that isn't used in the results returned but the subquery. Subqueries
    can almost never be more efficient than joins. 

Benefits of sub queries
* easier to read
* easier to change for flexibility
* might run faster in some cases. If the sub queries have the same execution the results might be cached.
* Used for "select * from table  t where t.id in (select max(id) from TABLE)".

Benefits of joins
* Sub queries can almost always be converted to joins.
* Sub queries have limitations, such as returning only one column,
are only allowed in comparisons (In, exists =), cannot be used in outer join. 
* Left joins can include NULL matches, but technically sub queries can too.
* In most cases, joins will be more efficient -- if the indexes are correct.
* Columns from all tables an be included in the result.
* More complex queries can be easier to read when written properly.

In general
* Most nested queries can  be joins and vice versa.
* write in the style easiest for you.
* Check out the efficiency and speed of queries by
   * Running an explain on the queries
   * Between each run of a query, clear the cache if possible. You can do this
   by selecting data from another table that is larger than cache. Then time it.
* Consider using CTE for programming.

* * *
<a name=root></a>Fix root permissions
-----

Method 1
* As mysql root : "REVOKE INSERT ON *.* FROM 'root'@'localhost';"
* Edit my.cnf and add
```
  # add to my.cnf
init_file=/etc/init_mysql.sql
```
* Create file init_file=/etc/init_mysql.sql with contents
```
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' ;
```

* Restart mysql
    * service mysqld restart
* Show grants : Grants for root@localhost
```
+----------------------------------------------------
| Grants for root@localhost
+----------------------------------------------------
| GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost'
  IDENTIFIED BY PASSWORD '*81F5E21E35407D884A6CD4A731AEBFB6AF209E1B'
  WITH GRANT OPTION |
| GRANT PROXY ON ''@'%' TO 'root'@'localhost' WITH GRANT OPTION                                                                         |
+----------------------------------------------------

```

Method 2: If root still has grant option
* As mysql root: GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' ;
    * Note: This works in some versions of MySQL. Need to test various versions.

* * *
<a name=test></a>test
-----
