
---
title : MySQL Locking
author : Mark Nielsen
copyright : October 2024
---


MySQL Locking
==============================

_**by Mark Nielsen
Copyright October 2024**_

1. [Links](#links)
2. [Methods](#methods)

* * *
<a name=links></a>Links
-----
* https://severalnines.com/blog/how-fix-lock-wait-timeout-exceeded-error-mysql/
* https://www.alibabacloud.com/help/en/kb-articles/latest/how-do-i-view-the-lock-information-of-a-mysql-database

* * *
<a name=methods></a>Methods
-----

* show processlist
* show innodb status
* by queries

* * *
<a name=queries></a>Queries
-----


* Open tables
```
show open tables where in_use > 0;
```

*  Select metalocks
```
SELECT * FROM performance_schema.metadata_locks;
```

* Try to see the order of locks
```

select  t.thread_id as thread_id
  , t.processlist_id as pid
  , t.PROCESSLIST_DB as db
  , t.PROCESSLIST_COMMAND as psql
  , t.PROCESSLIST_STATE as pstate
  , t.PROCESSLIST_INFO as info
  , t.PROCESSLIST_TIME as ptime
  , group_concat(ml.lock_type) as lock_type
from performance_schema.metadata_locks ml
  join performance_schema.threads t on (t.thread_id = ml.owner_thread_id)
  join performance_schema.processlist p on (p.id = t.processlist_id) 

where ml.lock_type in ('INTENTION_EXCLUSIVE', 'SHARED_WRITE', 'SHARED_UPGRADABLE', 'EXCLUSIVE')
group by thread_id, pid, db, psql, pstate, info, time;
;
```

* Use the INFORMATION_SCHEMA.INNODB_TRX table.
```
SELECT TRX_ID
  , TRX_STATE
  ,  trx_mysql_thread_iD AS MID
  ,  trx_tables_locked TL
  , trx_rows_locked as rl
FROM INFORMATION_SCHEMA.INNODB_TRX;
```


* Use the data_locks table
```
select * from performance_schema.data_locks;
```

* Use the data_lock_waits table.
```
select REQUESTING_ENGINE_TRANSACTION_ID as RTransI
  , REQUESTING_THREAD_ID as RThreadI
  , REQUESTING_EVENT_ID REI
  , BLOCKING_ENGINE_TRANSACTION_ID BTI
  , BLOCKING_THREAD_ID BTI
  , BLOCKING_EVENT_ID BEI
from performance_schema.data_lock_waits;
```

* Combine them together to tell what blocks what, except the alter command. Notice the blocking query is Null because
it is a "select for update", which means the command is done. If it was an update command or something else the query
might show up. Also Table locks don't know up from alters. We will try to address this. 
```
select  dlw.BLOCKING_THREAD_ID as thread_id1
  , t1.PROCESSLIST_ID as p1
  , t1.PROCESSLIST_INFO as info1
  , ' blocks ' 
  , dlw.REQUESTING_THREAD_ID as thread_id2
  , t2.PROCESSLIST_ID as p2
  , t2.PROCESSLIST_INFO as info2

from performance_schema.data_lock_waits dlw
  join performance_schema.threads t1 on (t1.thread_id = dlw.BLOCKING_THREAD_ID)
  join performance_schema.threads t2 on (t2.thread_id = dlw.REQUESTING_THREAD_ID)
;

select 'missing locks ', t.thread_id, t.processlist_id as pid, t.processlist_info as info
  from information_schema.processlist pl
    join performance_schema.threads t on  (t.processlist_id = pl.id)
    left join performance_schema.data_lock_waits  dlw on (dlw.REQUESTING_THREAD_ID = t.thread_id)
where dlw.engine is Null and pl.state like '%lock%'
;


```

Setup the locks. Start 3 mysql session. We will call them Session 1, 2 and 3. Screen or tmux might be helpful here.

* In Session 1
```
create database if not exists lock_test;
use lock_test;
drop table if exists locks;
create table if not exists locks (i int, primary key (i));

  -- Here we have to insert 100 and 101 to prevent next-key locks above 100. 
insert into locks values (1),(3),(100),(101);

  # default 50
set GLOBAL innodb_lock_wait_timeout=5000;

```

* In Session 1. This will do GAP locks, Next Key Locks, Alter locks, and update locks. If we just insert 1 row, it won't
GAP and Next Key locks won't happen. We had to insert 100 and 101 to stop Next Key above 100. If this is true, I consider
it a bug. I tested it over and over and Next Key shouldn't happen if just 100 is inserted, but it needs 101 as well. You
can test this. 

```
begin;
select * from locks where i = 1 or i = 3 for update;

```


* In session 2. We will do an update lock. 
```
use lock_test;
update locks set i = 4 where i = 1;
```

* In Session 3 we will do a GAP lock. 
```
use lock_test;
insert into locks values (2);
```

* In Session 4, we will do a Next Key Lock
```
use lock_test;
insert into locks values (4);
```

* In Session 5, we will do an alter
```
use lock_test;
alter table locks add column (text varchar(1));
```


* The output of the lock queries

```
MySQL [lock_test]> source l
+-----------+-------+--------+-------------+
| Database  | Table | In_use | Name_locked |
+-----------+-------+--------+-------------+
| lock_test | locks |      4 |           0 |
+-----------+-------+--------+-------------+
1 row in set (0.001 sec)

+---------------+--------------------+-----------------+-------------+-----------------------+---------------------+---------------+-------------+--------------------+-----------------+----------------+
| OBJECT_TYPE   | OBJECT_SCHEMA      | OBJECT_NAME     | COLUMN_NAME | OBJECT_INSTANCE_BEGIN | LOCK_TYPE           | LOCK_DURATION | LOCK_STATUS | SOURCE             | OWNER_THREAD_ID | OWNER_EVENT_ID |
+---------------+--------------------+-----------------+-------------+-----------------------+---------------------+---------------+-------------+--------------------+-----------------+----------------+
| TABLE         | lock_test          | locks           | NULL        |       137181199687296 | SHARED_WRITE        | TRANSACTION   | GRANTED     | sql_parse.cc:6427  |              60 |            149 |
| GLOBAL        | NULL               | NULL            | NULL        |       137181255564544 | INTENTION_EXCLUSIVE | STATEMENT     | GRANTED     | sql_base.cc:3080   |              64 |             28 |
| TABLE         | lock_test          | locks           | NULL        |       137181255484208 | SHARED_WRITE        | TRANSACTION   | GRANTED     | sql_parse.cc:6427  |              64 |             28 |
| GLOBAL        | NULL               | NULL            | NULL        |       137181390564800 | INTENTION_EXCLUSIVE | STATEMENT     | GRANTED     | sql_base.cc:3080   |              65 |             15 |
| TABLE         | lock_test          | locks           | NULL        |       137181391303504 | SHARED_WRITE        | TRANSACTION   | GRANTED     | sql_parse.cc:6427  |              65 |             15 |
| GLOBAL        | NULL               | NULL            | NULL        |       137182114793136 | INTENTION_EXCLUSIVE | STATEMENT     | GRANTED     | sql_base.cc:3080   |              67 |             15 |
| TABLE         | lock_test          | locks           | NULL        |       137182114790704 | SHARED_WRITE        | TRANSACTION   | GRANTED     | sql_parse.cc:6427  |              67 |             15 |
| GLOBAL        | NULL               | NULL            | NULL        |       137181930188976 | INTENTION_EXCLUSIVE | STATEMENT     | GRANTED     | sql_base.cc:5548   |              68 |             42 |
| BACKUP LOCK   | NULL               | NULL            | NULL        |       137181930884144 | INTENTION_EXCLUSIVE | TRANSACTION   | GRANTED     | sql_base.cc:5560   |              68 |             42 |
| SCHEMA        | lock_test          | NULL            | NULL        |       137181930127536 | INTENTION_EXCLUSIVE | TRANSACTION   | GRANTED     | sql_base.cc:5535   |              68 |             42 |
| TABLE         | lock_test          | locks           | NULL        |       137181930642128 | SHARED_UPGRADABLE   | TRANSACTION   | GRANTED     | sql_parse.cc:6427  |              68 |             42 |
| BACKUP TABLES | NULL               | NULL            | NULL        |       137181930372704 | INTENTION_EXCLUSIVE | STATEMENT     | GRANTED     | lock.cc:1260       |              68 |             42 |
| TABLESPACE    | NULL               | lock_test/locks | NULL        |       137181930334832 | INTENTION_EXCLUSIVE | TRANSACTION   | GRANTED     | lock.cc:813        |              68 |             42 |
| TABLE         | lock_test          | #sql-279d_20    | NULL        |       137181930334304 | EXCLUSIVE           | STATEMENT     | GRANTED     | sql_table.cc:17580 |              68 |             42 |
| TABLE         | lock_test          | locks           | NULL        |       137181930747440 | EXCLUSIVE           | TRANSACTION   | PENDING     | mdl.cc:3776        |              68 |             43 |
| TABLE         | performance_schema | metadata_locks  | NULL        |       137180992735296 | SHARED_READ         | TRANSACTION   | GRANTED     | sql_parse.cc:6427  |             162 |             47 |
+---------------+--------------------+-----------------+-------------+-----------------------+---------------------+---------------+-------------+--------------------+-----------------+----------------+
16 rows in set (0.001 sec)

+-----------+------+-----------+-------+---------------------------------+------------------------------------------------+-------+-------------------------------------------------------------------------------------------------------------------------------------------+
| thread_id | pid  | db        | psql  | pstate                          | info                                           | ptime | lock_type                                                                                                                                 |
+-----------+------+-----------+-------+---------------------------------+------------------------------------------------+-------+-------------------------------------------------------------------------------------------------------------------------------------------+
|        60 |   24 | lock_test | Sleep | NULL                            | NULL                                           |  4389 | SHARED_WRITE                                                                                                                              |
|        64 |   28 | lock_test | Query | updating                        | update locks set i = 4 where i = 1             |  4383 | INTENTION_EXCLUSIVE,SHARED_WRITE                                                                                                          |
|        65 |   29 | lock_test | Query | update                          | insert into locks values (2)                   |  4381 | INTENTION_EXCLUSIVE,SHARED_WRITE                                                                                                          |
|        67 |   31 | lock_test | Query | update                          | insert into locks values (4)                   |  4379 | INTENTION_EXCLUSIVE,SHARED_WRITE                                                                                                          |
|        68 |   32 | lock_test | Query | Waiting for table metadata lock | alter table locks add column (text varchar(1)) |  4365 | INTENTION_EXCLUSIVE,INTENTION_EXCLUSIVE,INTENTION_EXCLUSIVE,SHARED_UPGRADABLE,INTENTION_EXCLUSIVE,INTENTION_EXCLUSIVE,EXCLUSIVE,EXCLUSIVE |
+-----------+------+-----------+-------+---------------------------------+------------------------------------------------+-------+-------------------------------------------------------------------------------------------------------------------------------------------+
5 rows in set, 2 warnings (0.001 sec)

ERROR: No query specified

+--------+-----------+-----+----+----+
| TRX_ID | TRX_STATE | MID | TL | rl |
+--------+-----------+-----+----+----+
|   2263 | LOCK WAIT |  31 |  1 |  1 |
|   2262 | LOCK WAIT |  29 |  1 |  1 |
|   2261 | LOCK WAIT |  28 |  1 |  1 |
|   2259 | RUNNING   |  24 |  1 |  5 |
+--------+-----------+-----+----+----+
4 rows in set (0.001 sec)

+--------+---------------------------------------+-----------------------+-----------+----------+---------------+-------------+----------------+-------------------+------------+-----------------------+-----------+------------------------+-------------+------------------------+
| ENGINE | ENGINE_LOCK_ID                        | ENGINE_TRANSACTION_ID | THREAD_ID | EVENT_ID | OBJECT_SCHEMA | OBJECT_NAME | PARTITION_NAME | SUBPARTITION_NAME | INDEX_NAME | OBJECT_INSTANCE_BEGIN | LOCK_TYPE | LOCK_MODE              | LOCK_STATUS | LOCK_DATA              |
+--------+---------------------------------------+-----------------------+-----------+----------+---------------+-------------+----------------+-------------------+------------+-----------------------+-----------+------------------------+-------------+------------------------+
| INNODB | 137182144632680:1067:137182060812672  |                  2263 |        67 |       16 | lock_test     | locks       | NULL           | NULL              | NULL       |       137182060812672 | TABLE     | IX                     | GRANTED     | NULL                   |
| INNODB | 137182144632680:5:4:4:137182060809760 |                  2263 |        67 |       16 | lock_test     | locks       | NULL           | NULL              | PRIMARY    |       137182060809760 | RECORD    | X,GAP,INSERT_INTENTION | WAITING     | 100                    |
| INNODB | 137182144631832:1067:137182060806688  |                  2262 |        65 |       16 | lock_test     | locks       | NULL           | NULL              | NULL       |       137182060806688 | TABLE     | IX                     | GRANTED     | NULL                   |
| INNODB | 137182144631832:5:4:3:137182060803776 |                  2262 |        65 |       16 | lock_test     | locks       | NULL           | NULL              | PRIMARY    |       137182060803776 | RECORD    | X,GAP,INSERT_INTENTION | WAITING     | 3                      |
| INNODB | 137182144630984:1067:137182060800704  |                  2261 |        64 |       29 | lock_test     | locks       | NULL           | NULL              | NULL       |       137182060800704 | TABLE     | IX                     | GRANTED     | NULL                   |
| INNODB | 137182144630984:5:4:2:137182060797792 |                  2261 |        64 |       29 | lock_test     | locks       | NULL           | NULL              | PRIMARY    |       137182060797792 | RECORD    | X,REC_NOT_GAP          | WAITING     | 1                      |
| INNODB | 137182144630136:1067:137182060794608  |                  2259 |        60 |      149 | lock_test     | locks       | NULL           | NULL              | NULL       |       137182060794608 | TABLE     | IX                     | GRANTED     | NULL                   |
| INNODB | 137182144630136:5:4:1:137182060791616 |                  2259 |        60 |      149 | lock_test     | locks       | NULL           | NULL              | PRIMARY    |       137182060791616 | RECORD    | X                      | GRANTED     | supremum pseudo-record |
| INNODB | 137182144630136:5:4:2:137182060791616 |                  2259 |        60 |      149 | lock_test     | locks       | NULL           | NULL              | PRIMARY    |       137182060791616 | RECORD    | X                      | GRANTED     | 1                      |
| INNODB | 137182144630136:5:4:3:137182060791616 |                  2259 |        60 |      149 | lock_test     | locks       | NULL           | NULL              | PRIMARY    |       137182060791616 | RECORD    | X                      | GRANTED     | 3                      |
| INNODB | 137182144630136:5:4:4:137182060791616 |                  2259 |        60 |      149 | lock_test     | locks       | NULL           | NULL              | PRIMARY    |       137182060791616 | RECORD    | X                      | GRANTED     | 100                    |
| INNODB | 137182144630136:5:4:5:137182060791616 |                  2259 |        60 |      149 | lock_test     | locks       | NULL           | NULL              | PRIMARY    |       137182060791616 | RECORD    | X                      | GRANTED     | 101                    |
+--------+---------------------------------------+-----------------------+-----------+----------+---------------+-------------+----------------+-------------------+------------+-----------------------+-----------+------------------------+-------------+------------------------+
12 rows in set (0.000 sec)

+---------+----------+------+------+------+------+
| RTransI | RThreadI | REI  | BTI  | BTI  | BEI  |
+---------+----------+------+------+------+------+
|    2263 |       67 |   16 | 2259 |   60 |  149 |
|    2262 |       65 |   16 | 2259 |   60 |  149 |
|    2261 |       64 |   29 | 2259 |   60 |  149 |
+---------+----------+------+------+------+------+
3 rows in set (0.000 sec)

+------------+------+-------+----------+-----------+------+------------------------------------+
| thread_id1 | p1   | info1 | blocks   | thred_id2 | p2   | info2                              |
+------------+------+-------+----------+-----------+------+------------------------------------+
|         60 |   24 | NULL  |  blocks  |        67 |   31 | insert into locks values (4)       |
|         60 |   24 | NULL  |  blocks  |        65 |   29 | insert into locks values (2)       |
|         60 |   24 | NULL  |  blocks  |        64 |   28 | update locks set i = 4 where i = 1 |
+------------+------+-------+----------+-----------+------+------------------------------------+
3 rows in set (0.000 sec)

Database changed
Query OK, 0 rows affected (0.001 sec)

Query OK, 4 rows affected (0.001 sec)
Records: 4  Duplicates: 0  Warnings: 0

+------------+------+-------+----------+------------+------+------------------------------------+
| thread_id1 | p1   | info1 | blocks   | thread_id2 | p2   | info2                              |
+------------+------+-------+----------+------------+------+------------------------------------+
|         60 |   24 | NULL  |  blocks  |         67 |   31 | insert into locks values (4)       |
|         60 |   24 | NULL  |  blocks  |         65 |   29 | insert into locks values (2)       |
|         60 |   24 | NULL  |  blocks  |         64 |   28 | update locks set i = 4 where i = 1 |
|       NULL | NULL | NULL  |  blocks  |       NULL |   24 | NULL                               |
+------------+------+-------+----------+------------+------+------------------------------------+
4 rows in set (0.001 sec)

+----------------+-----------+------+------------------------------------------------+
| missing locks  | thread_id | pid  | info                                           |
+----------------+-----------+------+------------------------------------------------+
| missing locks  |        68 |   32 | alter table locks add column (text varchar(1)) |
+----------------+-----------+------+------------------------------------------------+
1 row in set, 1 warning (0.001 sec)



```