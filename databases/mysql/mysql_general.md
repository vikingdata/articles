
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

Not including [Info Queries](info_queries.md)

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
* Kill all processes or restart mysql
* Select all undo files
```
SELECT TABLESPACE_NAME, FILE_NAME FROM INFORMATION_SCHEMA.FILES
  WHERE FILE_TYPE LIKE 'UNDO LOG';
```
Output
```

```
* Create new undo file
```
CREATE UNDO TABLESPACE  temp_undo ADD DATAFILE 'temp_undo.ibu';
```
* Disable previous large undo
```
ALTER UNDO TABLESPACE innodb_undo_002 SET INACTIVE;
```
* Select staus of undo file until Free_Extents equal Total_Extents
```
SELECT * FROM INFORMATION_SCHEMA.FILES   WHERE FILE_NAME='./undo_002'\G
```



