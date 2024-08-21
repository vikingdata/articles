
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
3. [Temp Engines](#temp)
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
<a name=engines></a>Temp Engines
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

drop table if exists memory_temp;
CREATE TEMPORARY TABLE memory_temp (  i int, c char(100), v varchar(255)  )
  engine=Memory;

drop table if exists innodb_temp;
CREATE TEMPORARY TABLE innodb_temp (  i int, c char(100), v varchar(255)  )
engine=Memory;

drop table if exists innodb_temp_text;
CREATE temporARY TABLE innodb_temp_text (  i int, c char(100), v varchar(255), t text  )
engine=Memory;

drop table if exists innodb_plain;
CREATE TABLE innodb_plain (  i int, c char(100), v varchar(255))
engine=Innodb;

drop table if exists innodb_plain_text;
CREATE TABLE innodb_plain_text (  i int, c char(100), v varchar(255), t text  )
engine=Innodb;


SELECT table_schema, table_name, engine
  FROM INFORMATION_SCHEMA.TEMPORARY_TABLES
  WHERE TABLE_SCHEMA = "test1"\G

drop procedure if exists insert_test;

DELIMITER //
  CREATE PROCEDURE insert_test()
    BEGIN
    DECLARE i int DEFAULT 0;
    WHILE i <= 1024 DO
        INSERT INTO innodb_temp (i,c,v) VALUES (i, 'a', 'b');
        INSERT INTO innodb_temp_text (i,c,v,t) VALUES (i, 'a', 'b','t111111111');
        INSERT INTO memory_temp (i,c,v) VALUES (i, 'a', 'b');
        INSERT INTO innodb_plain (i,c,v) VALUES (i, 'a', 'b');
        INSERT INTO innodb_plain_text (i,c,v,t) VALUES (i, 'a', 'b', 't111111111');
         SET i = i + 1;
    END WHILE;

    END //
DELIMITER ;

delete from memory_temp;
delete from innodb_temp;
delete from innodb_plain;
delete from innodb_temp_text;
delete from innodb_plain_text;


call insert_test();
select count(1), 'memory_temp' from memory_temp;
select count(1), 'innodb_temp' from innodb_temp;
select count(1), 'innodb_plain' from innodb_plain;
select count(1), 'innodb_temp_text' from innodb_temp;
select count(1), 'innodb_plain_text' from innodb_plain;


SELECT  TABLE_NAME AS `Table`,  DATA_LENGTH, INDEX_LENGTH
FROM  information_schema.TEMPORARY_TABLES;

SELECT  TABLE_NAME AS `Table`,  DATA_LENGTH, INDEX_LENGTH
FROM  information_schema.TABLES
where table_name like 'innodb_plain%';


```

* Sequence of events
    * [AWS](https://aws.amazon.com/blogs/database/use-the-temptable-storage-engine-on-amazon-rds-for-mysql-and-amazon-aurora-mysql/)
    * Sequence
        * Temporary table made by user or internal.
             * MEMORY engine can ONLY be used by user. Can also specify InnoDB (but I believe you use disk also)
        * If size of data exceeds max size allowed it switches to on disk temporary tables.
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
        * TempTables are more efficient and faster. Not sure why.
	* Detailed information on TempTable is lacking.
   * Temp Innodb
        * Like MEMORY, the temp tables use the max space for varchar.
	* InnoDB temp tables appear to be efficient with text columns.
    
* Status
    *  [Created_tmp_tables](https://dev.mysql.com/doc/refman/8.4/en/server-status-variables.html#statvar_Created_tmp_tables) : amount of temporary tables made.
    * [ Created_tmp_disk_tables](https://dev.mysql.com/doc/refman/8.4/en/server-status-variables.html#statvar_Created_tmp_disk_tables) : Amount of temporary tables converted to disk. This is normally bad. 