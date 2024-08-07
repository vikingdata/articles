
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
* [Show mutiple variables from 'show'](#show)
* [Removing large undo files](#undo)


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
* MySQL memory cosiderations : https://mariadb.com/kb/en/mariadb-memory-allocation/

* * *
<a name=show></a>Show mutiple variables from 'show'
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
+

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
* Create new undo file -- not it may ask for full path. 
```
CREATE UNDO TABLESPACE  temp_undo ADD DATAFILE 'undo_003.ibu';
```
* Disable previous large undo
```
ALTER UNDO TABLESPACE innodb_undo_002 SET INACTIVE;
```
* Select staus of undo file until Free_Extents stops.
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
   

