
---
title : MySQL Explain
author : Mark Nielsen
copyright : September 2024
---


MySQL Explain
==============================

_**by Mark Nielsen
Original Copyright September 2024**_

1. [links](#links)
3. [Setup](#setup)

* * *
<a name=links></a>Links
-----

* * *
<a name=setup></a>Setup
-----

Execute on a mysql database server.

```

create database if not exists test1;
use test1;

drop table if exists table1;
CREATE TABLE table1 (  table1_id int, key(i)  );

drop table if exists table2;
CREATE TABLE table2 (
table2_id int,
table1_id_ref int,

key(table1_id),
key(table2_id),

  FOREIGN KEY (table1_id_ref)
        REFERENCES table1(table1_id)
	
);

CREATE TABLE table3 (
table1_id int,  key(i),
table2_id_ref int,  key(i),

  FOREIGN KEY (table2_id_ref)
        REFERENCES table2(table2_id)
        );
);


drop procedure if exists insert_test;

DELIMITER //
  CREATE PROCEDURE insert_test()
    BEGIN
    DECLARE i int DEFAULT 0;
    WHILE i <= 1024 DO
        INSERT INTO innodb_temp (i,c,v) VALUES (i, 'aaaaaa', 'bbbbbb');
        INSERT INTO innodb_temp_text (i,c,v,t) VALUES (i, 'aaaaaa', 'bbbbbb','t111111111');
        INSERT INTO memory_temp (i,c,v) VALUES (i, 'aaaaaa', 'bbbbbb');
        INSERT INTO innodb_plain (i,c,v) VALUES (i, 'aaaaaa', 'bbbbbb');
        INSERT INTO innodb_plain_text (i,c,v,t) VALUES (i, 'aaaaaa', 'bbbbbb', 't111111111');
         SET i = i + 1;
    END WHILE;

    END //
DELIMITER ;


call insert_test();
select count(1), 'memory_temp' from memory_temp;
select count(1), 'innodb_temp' from innodb_temp;
select count(1), 'innodb_plain' from innodb_plain;
select count(1), 'innodb_temp_text' from innodb_temp;
select count(1), 'innodb_plain_text' from innodb_plain;



```

Output
```
mysql> SELECT  TABLE_NAME AS `Table`,  DATA_LENGTH, INDEX_LENGTH
    -> FROM  information_schema.TEMPORARY_TABLES;
+------------------+-------------+--------------+
| Table            | DATA_LENGTH | INDEX_LENGTH |
+------------------+-------------+--------------+
| innodb_temp_text |      383744 |       126984 |
| innodb_temp      |      384032 |       102696 |
| memory_temp      |      384032 |       102696 |
+------------------+-------------+--------------+
3 rows in set (0.01 sec)

mysql>
mysql> SELECT  TABLE_NAME AS `Table`,  DATA_LENGTH, INDEX_LENGTH
    -> FROM  information_schema.TABLES
    -> where table_name like 'innodb_plain%';
+-------------------+-------------+--------------+
| Table             | DATA_LENGTH | INDEX_LENGTH |
+-------------------+-------------+--------------+
| innodb_plain      |      147456 |            0 |
| innodb_plain_text |      180224 |            0 |
+-------------------+-------------+--------------+
2 rows in set (0.02 sec)
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
        * One thing to note, innodb temp tables use index space but normal innodb tables
	do not. The PRIMARY index on innodb tables are clustered, but apparently not for
	temp innodb tables. 
    
* Status
    *  [Created_tmp_tables](https://dev.mysql.com/doc/refman/8.4/en/server-status-variables.html#statvar_Created_tmp_tables) : amount of temporary tables made.
    * [ Created_tmp_disk_tables](https://dev.mysql.com/doc/refman/8.4/en/server-status-variables.html#statvar_Created_tmp_disk_tables) : Amount of temporary tables converted to disk. This is normally bad. 