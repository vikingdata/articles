
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
Explain
   * Old explain: http://download.nust.na/pub6/mysql/doc/refman/5.5/en/using-explain.html
   * New Explain: https://dev.mysql.com/doc/refman/8.4/en/explain.html
Explain Extended
   * https://dev.mysql.com/doc/refman/8.4/en/explain-extended.html
Explain analyze
   * https://dev.mysql.com/doc/refman/8.4/en/explain.html#explain-analyze
* https://engineering.wework.com/top-3-mysql-query-profiling-tools-41cb24db32bf

* * *
<a name=setup></a>Setup
-----

Execute on a mysql database server.

```

create database if not exists test1;
use test1;

drop table if exists table3;
drop table if exists table2;
drop table if exists table1;

CREATE TABLE table1 (  table1_id int, primary key(table1_id)  );

CREATE TABLE table2 (
table2_id int,
table1_id_ref int,

key(table1_id_ref),
primary key(table2_id),

  FOREIGN KEY (table1_id_ref)
        REFERENCES table1(table1_id)
	
);

CREATE TABLE table3 (
table3_id int,
table2_id_ref int,

key(table2_id_ref),
primary key(table3_id,table2_id_ref),

  FOREIGN KEY (table2_id_ref)
        REFERENCES table2(table2_id)

);


drop procedure if exists insert_data;
DELIMITER //
  CREATE PROCEDURE insert_data()
    BEGIN
    DECLARE i int DEFAULT 0;
    DECLARE j int DEFAULT 0;
    WHILE i <= 1024 DO
        INSERT INTO table1 (table1_id) values  (i);
        SET i = i + 1;
    END WHILE;

    set i = 0;
    WHILE i <= 1024 DO
        INSERT INTO table2 (table2_id, table1_id_ref) values  (i,i);
         SET i = i + 1;
    END WHILE;

    set i = 0;
    set j = 0;
    WHILE i <= 1024 DO
        WHILE j <= 50 DO
	    SET j = j + 1;
            INSERT INTO table3 (table3_id, table2_id_ref) values  (i,j);
        END WHILE;
	set j = 0;
        SET i = i + 1;
    END WHILE;

    END //
DELIMITER ;


call insert_data();
select count(1) from table1;
select count(1) from table2;
select count(1) from table3;

```

* * *
<a name=basic></a>Basic Explain
-----

```
select  t1.table1_id, t2.table2_id, t3.table3_id
  from
     table1 t1
       join table2 t2 on (t1.table1_id = t2.table1_id_ref)
       join table3 t3 on (t2.table2_id = t3.table2_id_ref)
  where t1.table1_id = 50
    and t2.table2_id = 50
    and t3.table3_id > 1
  limit 10;

explain
select  t1.table1_id, t2.table2_id, t3.table3_id
  from
     table1 t1
       join table2 t2 on (t1.table1_id = t2.table1_id_ref)
       join table3 t3 on (t2.table2_id = t3.table2_id_ref)
  where t1.table1_id = 50
    and t2.table2_id = 50
    and t3.table3_id > 1
  limit 10\G


```

Output

```
mysql> select  t1.table1_id, t2.table2_id, t3.table3_id
    ->   from
    ->      table1 t1
    ->        join table2 t2 on (t1.table1_id = t2.table1_id_ref)
    ->        join table3 t3 on (t2.table2_id = t3.table2_id_ref)
    ->   where t1.table1_id = 50
    ->     and t2.table2_id = 50
    ->     and t3.table3_id > 1
    ->   limit 10;
+-----------+-----------+-----------+
| table1_id | table2_id | table3_id |
+-----------+-----------+-----------+
|        50 |        50 |         2 |
|        50 |        50 |         3 |
|        50 |        50 |         4 |
|        50 |        50 |         5 |
|        50 |        50 |         6 |
|        50 |        50 |         7 |
|        50 |        50 |         8 |
|        50 |        50 |         9 |
|        50 |        50 |        10 |
|        50 |        50 |        11 |
+-----------+-----------+-----------+
10 rows in set (0.00 sec)

mysql> explain
    -> select  t1.table1_id, t2.table2_id, t3.table3_id
    ->   from
    ->      table1 t1
    ->        join table2 t2 on (t1.table1_id = t2.table1_id_ref)
    ->        join table3 t3 on (t2.table2_id = t3.table2_id_ref)
    ->   where t1.table1_id = 50
    ->     and t2.table2_id = 50
    ->     and t3.table3_id > 1
    ->   limit 10\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: t1
   partitions: NULL
         type: const
possible_keys: PRIMARY
          key: PRIMARY
      key_len: 4
          ref: const
         rows: 1
     filtered: 100.00
        Extra: Using index
*************************** 2. row ***************************
           id: 1
  select_type: SIMPLE
        table: t2
   partitions: NULL
         type: const
possible_keys: PRIMARY,table1_id_ref
          key: PRIMARY
      key_len: 4
          ref: const
         rows: 1
     filtered: 100.00
        Extra: NULL
*************************** 3. row ***************************
           id: 1
  select_type: SIMPLE
        table: t3
   partitions: NULL
         type: range
possible_keys: PRIMARY,table2_id_ref
          key: table2_id_ref
      key_len: 8
          ref: NULL
         rows: 1023
     filtered: 100.00
        Extra: Using where; Using index
3 rows in set, 1 warning (0.00 sec)


```


* * *
<a name=extended></a>Explain extended
-----

* * *
<a name=json></a>Explain Json
-----

* * *
<a name=analyze></a>Explain analyze
-----

