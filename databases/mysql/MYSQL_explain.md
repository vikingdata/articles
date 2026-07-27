
---
title : MySQL Explain
author : Mark Nielsen
copyright : July 2026
---


MySQL Explain
==============================

_**by Mark Nielsen
Original Copyright July 2026**_

1. [links](#links)
2. [Setup](#setup)
3. Explain extended
4. Explain JSON
5. Explain analyze
6. [Important rules on index](#i)
   c. Left most principle for tables
   d. WOG (where, order, Group)
   e. They forget about joins
7. [Derived tables and joins](#d)

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

TODO
* explain you need to multiple Rows to get approximate rows scanned. Include a   dervied query using a join and where condition, that if an index is changed, it becomes more efficient. Explain the leftmost principle and  Composite Index (or Compound Index).3B
* YTou really need to look at slow log

* * *
<a name=i></a> Important rules on index
   c. Left most principle for tables
   d. WOG (where, order, Group)
   e. They forget about joins

* * *
<a name=d></a>Derived tables and joins
When you join to a derived table in MySQL (it may be different with other database systems) you need an index
where the first field is the join field. The other fields are part of the derived query.



* Start your mysql client in verbose mode. "-vvv" for the mysql client. 
* Run "source create_table_join.sql" on your database.
---
Output

Query OK, 1 row affected, 1 warning (0.00 sec)

Database changed
Query OK, 0 rows affected (0.01 sec)

Query OK, 0 rows affected (0.00 sec)

Query OK, 0 rows affected (0.01 sec)

Query OK, 0 rows affected (0.00 sec)

Query OK, 0 rows affected (0.01 sec)

Query OK, 0 rows affected (0.01 sec)

---
   * Run "bash make_data.sh" at your linux or operating system prompt.
---
Output
done with t1 1
done with t1 2
done with t1 3
done with t1 4
done with t1 5
done with t1 6
done with t1 7
done with t1 8
done with t1 9
done with t1 10
----
   * Run the follwing in mysql
---
source insert_t1.sql;
source insert_t2.sql;
source insert_t3.sql;

Output
mysql> source insert_t1.sql;
Query OK, 11 rows affected (0.01 sec)
Records: 11  Duplicates: 0  Warnings: 0

mysql> source insert_t2.sql;
Query OK, 1001 rows affected (0.01 sec)
Records: 1001  Duplicates: 0  Warnings: 0

mysql> source insert_t3.sql;
Query OK, 1000001 rows affected (9.91 sec)
Records: 1000001  Duplicates: 0  Warnings: 0
---
* Make the logs directory and empty it.
    * "  bash -c 'mkdir -p logs; rm -f logs/*'   "
* Run the join test script in mysql "source join_test.sql". This saves log information to files join_first.log, no_index.log, where_first.log.
* Process the logs by running "analyze_logs.sh"
```
Output
For no_index.log, the no of rows is calcualted from the explain
    11*926*926403 = 9436340958
For where_first.log, the no of rows is calcualted from the explain
    11*181*18142 = 36120722
For join_first.log, the no of rows is calcualted from the explain
    11*2*11 = 242
```
* We see that adding an index where the first field in the index is in the where condition is better. But an index for the field with join first is the best.
* Here are the explains for the queries.
   * Explain for no index
```
*************************** 1. row ***************************
           id: 1
  select_type: PRIMARY
        table: t1
   partitions: NULL
         type: index
possible_keys: PRIMARY
          key: PRIMARY
      key_len: 4
          ref: NULL
         rows: 11
     filtered: 100.00
        Extra: Using index
*************************** 2. row ***************************
           id: 1
  select_type: PRIMARY
        table: <derived2>
   partitions: NULL
         type: ref
possible_keys: <auto_key0>
          key: <auto_key0>
      key_len: 4
          ref: test_join.t1.t1_id
         rows: 926
     filtered: 100.00
        Extra: NULL
*************************** 3. row ***************************
           id: 2
  select_type: DERIVED
        table: t3
   partitions: NULL
         type: index
possible_keys: PRIMARY
          key: PRIMARY
      key_len: 12
          ref: NULL
         rows: 926403
     filtered: 10.00
        Extra: Using where; Using index; Using temporary
3 rows in set, 1 warning (0.01 sec)
```

   
   * Explain which the index is only for the where clause
   * Explain where the join is the first field of the index and the field in the where clause for the derived
   query is the next field.
   