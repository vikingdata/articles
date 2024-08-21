
---
title : MySQL Temporary Tables
author : Mark Nielsen
copyright : August 2024
---


MySQL Temporary Tables
==============================

_**by Mark Nielsen
Original Copyright August 2024**_

1. [links](#links)
2. [Sequence of events](#seq)
3. Engines
    * Heap less than 8.4
    * TempTable 8.4 and greater
    * Memory
    * Innodb -- for on disk

* * *
<a name=links></a>Links
-----
* Engines
    * [Memory] (https://dev.mysql.com/doc/refman/8.4/en/memory-storage-engine.html) which is also known as HEAP. 
    * [TempTable](https://dev.mysql.com/doc/refman/8.4/en/internal-temporary-tables.html#internal-temporary-tables-engines)
* Temporary Table in general
    * [Internal Temporary Table Use in MySQL](https://dev.mysql.com/doc/refman/8.4/en/internal-temporary-tables.html)


* * *
<a name=seq></a>Sequence of events
-----
* Variables
    * [tmp_table_size](https://dev.mysql.com/doc/refman/8.4/en/server-system-variables.html#sysvar_tmp_table_size) : max size of memory or temptable for internal use. Does not apply to user made memory tables. User made temptables is not supported. 
    * [max_heap_table_size](https://dev.mysql.com/doc/refman/8.4/en/server-system-variables.html#sysvar_max_heap_table_size) : Max size user memory tables are permitted to grow. 
    *  internal_tmp_mem_storage_engine : Memory or TempTable

* Create statements

```
show engines;

create database if not exists test1;
use database test1;

drop table if exists memory1;
CREATE TEMPORARY TABLE memory1 (
  i int, c char(100), v varchar(255)
  )
  engine=Memory;

drop table if exists innodb1;
CREATE TEMPORARY TABLE innodb1 (
  i int, c char(100), v varchar(255)
  )
engine=Memory;


SELECT table_schema, table_name, engine
  FROM INFORMATION_SCHEMA.TEMPORARY_TABLES
  WHERE TABLE_SCHEMA = "test1"\G


drop procedure if exists insert_test;

DELIMITER //
  CREATE PROCEDURE insert_test()
    BEGIN
    DECLARE i int DEFAULT 0;
    WHILE i <= 1024*1024 DO
        INSERT INTO innodb1 (i,c,v) VALUES (i, 'a', 'bbbbbbbbbbbbbbbbbbbb');
        INSERT INTO memory1 (i,c,v) VALUES (i, 'a', 'bbbbbbbbbbbbbbbbbbbb');
        SET i = i + 1;
    END WHILE;

    END //
DELIMITER ;

delete from memory1;
delete from innodb1;
call insert_test();
select count(1), 'memory1' from memory1;
select count(1), 'innodb1' from memory1;

SELECT  TABLE_NAME AS `Table`,  DATA_LENGTH, INDEX_LENGTH
FROM  information_schema.TEMPORARY_TABLES;


```

* Sequence of events
    * [AWS](https://aws.amazon.com/blogs/database/use-the-temptable-storage-engine-on-amazon-rds-for-mysql-and-amazon-aurora-mysql/)
    * Sequence
        * Temporary table made by user or internal.
             * MEMORY engine can ONLY be used by user. Can also specify InnoDB (but I believe you use disk also)
        * If size of data exceeds max size allowed it switched to ondisk temporary tables.
        * On disk temporary tables use InnoDB. 
* Notes
    * Memory engine
        * Memory is ONLY freed up when the table is dropped.
            * Deletes won't free up memory.
        * Each column uses the max amount of space per column even if there is only 1 byte of data. Ex: 1 bytes of data on a varchar(255) column occupies 255 bytes.
        * Cannot do blob or text fields -- I think. 

* TempTable engine
        * Efficient storage of varchar, blob, and text fields
        * Unsure if other fields are padded to maximum.
	* Unsure if memory is freed for deletions (not drops)
	* TempTables are more efficent and faster. Not sure why. 

* Status
    *  [Created_tmp_tables](https://dev.mysql.com/doc/refman/8.4/en/server-status-variables.html#statvar_Created_tmp_tables) : amount of temporary tables made.
    * [ Created_tmp_disk_tables](https://dev.mysql.com/doc/refman/8.4/en/server-status-variables.html#statvar_Created_tmp_disk_tables) : Amount of temporary tables converted to disk. This is normally bad. 