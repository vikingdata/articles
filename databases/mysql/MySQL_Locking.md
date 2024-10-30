
---
title : MySQL Locking
author : Mark Nielsen
copyright : October 2024
---


MySQL Locking
==============================

_**by Mark Nielsen
Copyright October 2024**_

This is for MySQL 8. MySQL 5.7 has different tables and columns. Did not check 8.1 or 8.4, but expect changes. 

Wanted to make a good example of locks in MySQL. I wanted to demonstrate GAP locks, Next Key Locks, update locks, and alter table locks. Funny thing, for alter table locks, I couldn't list what was blocking it. I think it was because it is outside a row level lock. Also, for next key lock, I had to insert two numbers at the end in order to avoid next key lock above 100. This doesn't happen with single row updates. 



1. [Links](#links)
2. [Queries](#queries)
3. [Setup](#setup)
4. [Output](#output)
* * *
<a name=links></a>Links
-----
* https://severalnines.com/blog/how-fix-lock-wait-timeout-exceeded-error-mysql/
* https://www.alibabacloud.com/help/en/kb-articles/latest/how-do-i-view-the-lock-information-of-a-mysql-database



* * *
<a name=queries></a>Queries
-----
There is also "show engine innodb status".


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
might show up. Also Table locks don't know up from alters. We will try to address this. Here the queries are listed by
oldest first. Notice the "select for update" is the oldest thread under 'ptime1' 
```
select  dlw.BLOCKING_THREAD_ID as thread_id1
  , t1.PROCESSLIST_ID as p1
  , t1.PROCESSLIST_INFO as info1
  , t1.PROCESSLIST_TIME as ptime1
  , ' blocks '
  , dlw.REQUESTING_THREAD_ID as thread_id2
  , t2.PROCESSLIST_ID as p2
  , t2.PROCESSLIST_INFO as info2 
  , t2.PROCESSLIST_TIME as ptime2
from performance_schema.data_lock_waits dlw
  join performance_schema.threads t1 on (t1.thread_id = dlw.BLOCKING_THREAD_ID)
  join performance_schema.threads t2 on (t2.thread_id = dlw.REQUESTING_THREAD_ID)
order by ptime2 desc
;

select 'missing locks '
  , t.thread_id
  , t.processlist_id as pid
  , t.processlist_info as info
  , t.PROCESSLIST_TIME as ptime
from information_schema.processlist pl
  join performance_schema.threads t on  (t.processlist_id = pl.id)
  left join performance_schema.data_lock_waits  dlw on (dlw.REQUESTING_THREAD_ID = t.thread_id)
where dlw.engine is Null and pl.state like '%lock%'
;

select 'holding locks'
  , t.thread_Id
  , t.processlist_id as pid
  , t.processlist_info as info
  , t.PROCESSLIST_TIME as ptime
from INFORMATION_SCHEMA.INNODB_TRX trx
  join performance_schema.threads t on (t.processlist_id = trx.trx_mysql_thread_iD)
order by ptime desc;


select  t.thread_id as thread_id
  , t.processlist_id as pid
  , t.PROCESSLIST_DB as db
  , t.PROCESSLIST_COMMAND as psql
  , t.PROCESSLIST_STATE as pstate
  , t.PROCESSLIST_INFO as info
  , t.PROCESSLIST_TIME as ptime
  , ' blocked by thread '
  , dlw.BLOCKING_THREAD_ID as blocking_thread_id
  , group_concat(ml.lock_type) as lock_type
from performance_schema.metadata_locks ml
  join performance_schema.threads t on (t.thread_id = ml.owner_thread_id)
  join performance_schema.processlist p on (p.id = t.processlist_id)
  left join performance_schema.data_lock_waits  dlw on (dlw.REQUESTING_THREAD_ID = t.thread_id)
  
where ml.lock_type in ('INTENTION_EXCLUSIVE', 'SHARED_WRITE', 'SHARED_UPGRADABLE', 'EXCLUSIVE')
group by thread_id, pid, db, psql, pstate, info, time, ' blocked by thread ', dlw.BLOCKING_THREAD_ID 
;


```

* * *
<a name=setup></a>Setup
-----

Setup the locks. Start 5 mysql sessions. We will call them Session 1, 2, 3, 4 and 5. Screen or tmux might be helpful here.

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
* * *
<a name=ouptut></a>Output
-----

* The output of the lock queries. Notice at the 4th to last table has "info1" with no query and the 3rd to last table has "info" with no query. That's because the "select for update" query finished. The thread is still blocking though "nothing" is being executed. Normally, you should see a query. 

```
MySQL [lock_test]> source q
--------------
show open tables where in_use > 0
--------------

+-----------+-------+--------+-------------+
| Database  | Table | In_use | Name_locked |
+-----------+-------+--------+-------------+
| lock_test | locks |      4 |           0 |
+-----------+-------+--------+-------------+
1 row in set (0.001 sec)

--------------
SELECT * FROM performance_schema.metadata_locks
--------------

+---------------+--------------------+-----------------+-------------+-----------------------+---------------------+---------------+-------------+--------------------+-----------------+----------------+
| OBJECT_TYPE   | OBJECT_SCHEMA      | OBJECT_NAME     | COLUMN_NAME | OBJECT_INSTANCE_BEGIN | LOCK_TYPE           | LOCK_DURATION | LOCK_STATUS | SOURCE             | OWNER_THREAD_ID | OWNER_EVENT_ID |
+---------------+--------------------+-----------------+-------------+-----------------------+---------------------+---------------+-------------+--------------------+-----------------+----------------+
| TABLE         | lock_test          | locks           | NULL        |       137181198270688 | SHARED_WRITE        | TRANSACTION   | GRANTED     | sql_parse.cc:6427  |              60 |            152 |
| GLOBAL        | NULL               | NULL            | NULL        |       137181255564544 | INTENTION_EXCLUSIVE | STATEMENT     | GRANTED     | sql_base.cc:3080   |              64 |             33 |
| TABLE         | lock_test          | locks           | NULL        |       137181255484208 | SHARED_WRITE        | TRANSACTION   | GRANTED     | sql_parse.cc:6427  |              64 |             33 |
| GLOBAL        | NULL               | NULL            | NULL        |       137181390564800 | INTENTION_EXCLUSIVE | STATEMENT     | GRANTED     | sql_base.cc:3080   |              65 |             22 |
| TABLE         | lock_test          | locks           | NULL        |       137181391303504 | SHARED_WRITE        | TRANSACTION   | GRANTED     | sql_parse.cc:6427  |              65 |             22 |
| GLOBAL        | NULL               | NULL            | NULL        |       137182114793136 | INTENTION_EXCLUSIVE | STATEMENT     | GRANTED     | sql_base.cc:3080   |              67 |             19 |
| TABLE         | lock_test          | locks           | NULL        |       137182114790704 | SHARED_WRITE        | TRANSACTION   | GRANTED     | sql_parse.cc:6427  |              67 |             19 |
| GLOBAL        | NULL               | NULL            | NULL        |       137181930194416 | INTENTION_EXCLUSIVE | STATEMENT     | GRANTED     | sql_base.cc:5548   |              68 |             48 |
| BACKUP LOCK   | NULL               | NULL            | NULL        |       137181930147296 | INTENTION_EXCLUSIVE | TRANSACTION   | GRANTED     | sql_base.cc:5560   |              68 |             48 |
| SCHEMA        | lock_test          | NULL            | NULL        |       137181930643968 | INTENTION_EXCLUSIVE | TRANSACTION   | GRANTED     | sql_base.cc:5535   |              68 |             48 |
| TABLE         | lock_test          | locks           | NULL        |       137181930643872 | SHARED_UPGRADABLE   | TRANSACTION   | GRANTED     | sql_parse.cc:6427  |              68 |             48 |
| BACKUP TABLES | NULL               | NULL            | NULL        |       137181930643776 | INTENTION_EXCLUSIVE | STATEMENT     | GRANTED     | lock.cc:1260       |              68 |             48 |
| TABLESPACE    | NULL               | lock_test/locks | NULL        |       137181930372704 | INTENTION_EXCLUSIVE | TRANSACTION   | GRANTED     | lock.cc:813        |              68 |             48 |
| TABLE         | lock_test          | #sql-279d_20    | NULL        |       137181930642128 | EXCLUSIVE           | STATEMENT     | GRANTED     | sql_table.cc:17580 |              68 |             48 |
| TABLE         | lock_test          | locks           | NULL        |       137181930642768 | EXCLUSIVE           | TRANSACTION   | PENDING     | mdl.cc:3776        |              68 |             49 |
| TABLE         | performance_schema | metadata_locks  | NULL        |       137180992720640 | SHARED_READ         | TRANSACTION   | GRANTED     | sql_parse.cc:6427  |             173 |             30 |
+---------------+--------------------+-----------------+-------------+-----------------------+---------------------+---------------+-------------+--------------------+-----------------+----------------+
16 rows in set (0.001 sec)

--------------
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
group by thread_id, pid, db, psql, pstate, info, time
--------------

+-----------+------+-----------+-------+---------------------------------+------------------------------------------------+-------+-------------------------------------------------------------------------------------------------------------------------------------------+
| thread_id | pid  | db        | psql  | pstate                          | info                                           | ptime | lock_type                                                                                                                                 |
+-----------+------+-----------+-------+---------------------------------+------------------------------------------------+-------+-------------------------------------------------------------------------------------------------------------------------------------------+
|        60 |   24 | lock_test | Sleep | NULL                            | NULL                                           |  1656 | SHARED_WRITE                                                                                                                              |
|        64 |   28 | lock_test | Query | updating                        | update locks set i = 4 where i = 1             |  1653 | INTENTION_EXCLUSIVE,SHARED_WRITE                                                                                                          |
|        65 |   29 | lock_test | Query | update                          | insert into locks values (2)                   |  1642 | INTENTION_EXCLUSIVE,SHARED_WRITE                                                                                                          |
|        67 |   31 | lock_test | Query | update                          | insert into locks values (4)                   |  1640 | INTENTION_EXCLUSIVE,SHARED_WRITE                                                                                                          |
|        68 |   32 | lock_test | Query | Waiting for table metadata lock | alter table locks add column (text varchar(1)) |  1637 | INTENTION_EXCLUSIVE,INTENTION_EXCLUSIVE,INTENTION_EXCLUSIVE,SHARED_UPGRADABLE,INTENTION_EXCLUSIVE,INTENTION_EXCLUSIVE,EXCLUSIVE,EXCLUSIVE |
+-----------+------+-----------+-------+---------------------------------+------------------------------------------------+-------+-------------------------------------------------------------------------------------------------------------------------------------------+
5 rows in set, 2 warnings (0.001 sec)

--------------
SELECT TRX_ID
  , TRX_STATE
  ,  trx_mysql_thread_iD AS MID
  ,  trx_tables_locked TL
  , trx_rows_locked as rl
FROM INFORMATION_SCHEMA.INNODB_TRX
--------------

+--------+-----------+-----+----+----+
| TRX_ID | TRX_STATE | MID | TL | rl |
+--------+-----------+-----+----+----+
|   2291 | LOCK WAIT |  31 |  1 |  1 |
|   2290 | LOCK WAIT |  29 |  1 |  1 |
|   2289 | LOCK WAIT |  28 |  1 |  1 |
|   2288 | RUNNING   |  24 |  1 |  5 |
+--------+-----------+-----+----+----+
4 rows in set (0.001 sec)

--------------
select * from performance_schema.data_locks
--------------

+--------+---------------------------------------+-----------------------+-----------+----------+---------------+-------------+----------------+-------------------+------------+-----------------------+-----------+------------------------+-------------+------------------------+
| ENGINE | ENGINE_LOCK_ID                        | ENGINE_TRANSACTION_ID | THREAD_ID | EVENT_ID | OBJECT_SCHEMA | OBJECT_NAME | PARTITION_NAME | SUBPARTITION_NAME | INDEX_NAME | OBJECT_INSTANCE_BEGIN | LOCK_TYPE | LOCK_MODE              | LOCK_STATUS | LOCK_DATA              |
+--------+---------------------------------------+-----------------------+-----------+----------+---------------+-------------+----------------+-------------------+------------+-----------------------+-----------+------------------------+-------------+------------------------+
| INNODB | 137182144632680:1067:137182060812672  |                  2291 |        67 |       20 | lock_test     | locks       | NULL           | NULL              | NULL       |       137182060812672 | TABLE     | IX                     | GRANTED     | NULL                   |
| INNODB | 137182144632680:5:4:4:137182060809760 |                  2291 |        67 |       20 | lock_test     | locks       | NULL           | NULL              | PRIMARY    |       137182060809760 | RECORD    | X,GAP,INSERT_INTENTION | WAITING     | 100                    |
| INNODB | 137182144631832:1067:137182060806688  |                  2290 |        65 |       23 | lock_test     | locks       | NULL           | NULL              | NULL       |       137182060806688 | TABLE     | IX                     | GRANTED     | NULL                   |
| INNODB | 137182144631832:5:4:3:137182060803776 |                  2290 |        65 |       23 | lock_test     | locks       | NULL           | NULL              | PRIMARY    |       137182060803776 | RECORD    | X,GAP,INSERT_INTENTION | WAITING     | 3                      |
| INNODB | 137182144630984:1067:137182060800704  |                  2289 |        64 |       34 | lock_test     | locks       | NULL           | NULL              | NULL       |       137182060800704 | TABLE     | IX                     | GRANTED     | NULL                   |
| INNODB | 137182144630984:5:4:2:137182060797792 |                  2289 |        64 |       34 | lock_test     | locks       | NULL           | NULL              | PRIMARY    |       137182060797792 | RECORD    | X,REC_NOT_GAP          | WAITING     | 1                      |
| INNODB | 137182144630136:1067:137182060794608  |                  2288 |        60 |      152 | lock_test     | locks       | NULL           | NULL              | NULL       |       137182060794608 | TABLE     | IX                     | GRANTED     | NULL                   |
| INNODB | 137182144630136:5:4:1:137182060791616 |                  2288 |        60 |      152 | lock_test     | locks       | NULL           | NULL              | PRIMARY    |       137182060791616 | RECORD    | X                      | GRANTED     | supremum pseudo-record |
| INNODB | 137182144630136:5:4:2:137182060791616 |                  2288 |        60 |      152 | lock_test     | locks       | NULL           | NULL              | PRIMARY    |       137182060791616 | RECORD    | X                      | GRANTED     | 1                      |
| INNODB | 137182144630136:5:4:3:137182060791616 |                  2288 |        60 |      152 | lock_test     | locks       | NULL           | NULL              | PRIMARY    |       137182060791616 | RECORD    | X                      | GRANTED     | 3                      |
| INNODB | 137182144630136:5:4:4:137182060791616 |                  2288 |        60 |      152 | lock_test     | locks       | NULL           | NULL              | PRIMARY    |       137182060791616 | RECORD    | X                      | GRANTED     | 100                    |
| INNODB | 137182144630136:5:4:5:137182060791616 |                  2288 |        60 |      152 | lock_test     | locks       | NULL           | NULL              | PRIMARY    |       137182060791616 | RECORD    | X                      | GRANTED     | 101                    |
+--------+---------------------------------------+-----------------------+-----------+----------+---------------+-------------+----------------+-------------------+------------+-----------------------+-----------+------------------------+-------------+------------------------+
12 rows in set (0.001 sec)

--------------
select REQUESTING_ENGINE_TRANSACTION_ID as RTransI
  , REQUESTING_THREAD_ID as RThreadI
  , REQUESTING_EVENT_ID REI
  , BLOCKING_ENGINE_TRANSACTION_ID BTI
  , BLOCKING_THREAD_ID BTI
  , BLOCKING_EVENT_ID BEI
from performance_schema.data_lock_waits
--------------

+---------+----------+------+------+------+------+
| RTransI | RThreadI | REI  | BTI  | BTI  | BEI  |
+---------+----------+------+------+------+------+
|    2291 |       67 |   20 | 2288 |   60 |  152 |
|    2290 |       65 |   23 | 2288 |   60 |  152 |
|    2289 |       64 |   34 | 2288 |   60 |  152 |
+---------+----------+------+------+------+------+
3 rows in set (0.000 sec)

--------------
select  dlw.BLOCKING_THREAD_ID as thread_id1
  , t1.PROCESSLIST_ID as p1
  , t1.PROCESSLIST_INFO as info1
  , t1.PROCESSLIST_TIME as ptime1
  , ' blocks '
  , dlw.REQUESTING_THREAD_ID as thread_id2
  , t2.PROCESSLIST_ID as p2
  , t2.PROCESSLIST_INFO as info2 
  , t2.PROCESSLIST_TIME as ptime2
from performance_schema.data_lock_waits dlw
  join performance_schema.threads t1 on (t1.thread_id = dlw.BLOCKING_THREAD_ID)
  join performance_schema.threads t2 on (t2.thread_id = dlw.REQUESTING_THREAD_ID)
order by ptime2 desc
--------------

+------------+------+-------+--------+----------+------------+------+------------------------------------+--------+
| thread_id1 | p1   | info1 | ptime1 | blocks   | thread_id2 | p2   | info2                              | ptime2 |
+------------+------+-------+--------+----------+------------+------+------------------------------------+--------+
|         60 |   24 | NULL  |   1656 |  blocks  |         64 |   28 | update locks set i = 4 where i = 1 |   1653 |
|         60 |   24 | NULL  |   1656 |  blocks  |         65 |   29 | insert into locks values (2)       |   1642 |
|         60 |   24 | NULL  |   1656 |  blocks  |         67 |   31 | insert into locks values (4)       |   1640 |
+------------+------+-------+--------+----------+------------+------+------------------------------------+--------+
3 rows in set (0.001 sec)

--------------
select 'missing locks '
  , t.thread_id
  , t.processlist_id as pid
  , t.processlist_info as info
  , t.PROCESSLIST_TIME as ptime
from information_schema.processlist pl
  join performance_schema.threads t on  (t.processlist_id = pl.id)
  left join performance_schema.data_lock_waits  dlw on (dlw.REQUESTING_THREAD_ID = t.thread_id)
where dlw.engine is Null and pl.state like '%lock%'
--------------

+----------------+-----------+------+------------------------------------------------+-------+
| missing locks  | thread_id | pid  | info                                           | ptime |
+----------------+-----------+------+------------------------------------------------+-------+
| missing locks  |        68 |   32 | alter table locks add column (text varchar(1)) |  1637 |
+----------------+-----------+------+------------------------------------------------+-------+
1 row in set, 1 warning (0.001 sec)

--------------
select 'holding locks'
  , t.thread_Id
  , t.processlist_id as pid
  , t.processlist_info as info
  , t.PROCESSLIST_TIME as ptime
from INFORMATION_SCHEMA.INNODB_TRX trx
  join performance_schema.threads t on (t.processlist_id = trx.trx_mysql_thread_iD)
order by ptime desc
--------------

+---------------+-----------+------+------------------------------------+-------+
| holding locks | thread_Id | pid  | info                               | ptime |
+---------------+-----------+------+------------------------------------+-------+
| holding locks |        60 |   24 | NULL                               |  1656 |
| holding locks |        64 |   28 | update locks set i = 4 where i = 1 |  1653 |
| holding locks |        65 |   29 | insert into locks values (2)       |  1642 |
| holding locks |        67 |   31 | insert into locks values (4)       |  1640 |
+---------------+-----------+------+------------------------------------+-------+
4 rows in set (0.001 sec)

--------------
select  t.thread_id as thread_id
  , t.processlist_id as pid
  , t.PROCESSLIST_DB as db
  , t.PROCESSLIST_COMMAND as psql
  , t.PROCESSLIST_STATE as pstate
  , t.PROCESSLIST_INFO as info
  , t.PROCESSLIST_TIME as ptime
  , ' blocked by thread '
  , dlw.BLOCKING_THREAD_ID as blocking_thread_id
  , group_concat(ml.lock_type) as lock_type
from performance_schema.metadata_locks ml
  join performance_schema.threads t on (t.thread_id = ml.owner_thread_id)
  join performance_schema.processlist p on (p.id = t.processlist_id)
  left join performance_schema.data_lock_waits  dlw on (dlw.REQUESTING_THREAD_ID = t.thread_id)

where ml.lock_type in ('INTENTION_EXCLUSIVE', 'SHARED_WRITE', 'SHARED_UPGRADABLE', 'EXCLUSIVE')
group by thread_id, pid, db, psql, pstate, info, time, ' blocked by thread ', dlw.BLOCKING_THREAD_ID
--------------

+-----------+------+-----------+-------+---------------------------------+------------------------------------------------+-------+---------------------+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------+
| thread_id | pid  | db        | psql  | pstate                          | info                                           | ptime | blocked by thread   | blocking_thread_id | lock_type                                                                                                                                 |
+-----------+------+-----------+-------+---------------------------------+------------------------------------------------+-------+---------------------+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------+
|        60 |   24 | lock_test | Sleep | NULL                            | NULL                                           |  1656 |  blocked by thread  |               NULL | SHARED_WRITE                                                                                                                              |
|        64 |   28 | lock_test | Query | updating                        | update locks set i = 4 where i = 1             |  1653 |  blocked by thread  |                 60 | INTENTION_EXCLUSIVE,SHARED_WRITE                                                                                                          |
|        65 |   29 | lock_test | Query | update                          | insert into locks values (2)                   |  1642 |  blocked by thread  |                 60 | INTENTION_EXCLUSIVE,SHARED_WRITE                                                                                                          |
|        67 |   31 | lock_test | Query | update                          | insert into locks values (4)                   |  1640 |  blocked by thread  |                 60 | INTENTION_EXCLUSIVE,SHARED_WRITE                                                                                                          |
|        68 |   32 | lock_test | Query | Waiting for table metadata lock | alter table locks add column (text varchar(1)) |  1637 |  blocked by thread  |               NULL | INTENTION_EXCLUSIVE,INTENTION_EXCLUSIVE,INTENTION_EXCLUSIVE,SHARED_UPGRADABLE,INTENTION_EXCLUSIVE,INTENTION_EXCLUSIVE,EXCLUSIVE,EXCLUSIVE |
+-----------+------+-----------+-------+---------------------------------+------------------------------------------------+-------+---------------------+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------+
5 rows in set, 2 warnings (0.001 sec)

```

* * *
<a name=idb></a>Show InnoDB status
-----

```

mysql> show engine innodb status;
| Type   | Name | Status

| InnoDB |      | 
=====================================
2024-10-30 14:16:46 137182132024896 INNODB MONITOR OUTPUT
=====================================
Per second averages calculated from the last 24 seconds
-----------------
BACKGROUND THREAD
-----------------
srv_master_thread loops: 132 srv_active, 0 srv_shutdown, 209985 srv_idle
srv_master_thread log flush and writes: 0
----------
SEMAPHORES
----------
OS WAIT ARRAY INFO: reservation count 3384
OS WAIT ARRAY INFO: signal count 3358
RW-shared spins 0, rounds 0, OS waits 0
RW-excl spins 0, rounds 0, OS waits 0
RW-sx spins 0, rounds 0, OS waits 0
Spin rounds per wait: 0.00 RW-shared, 0.00 RW-excl, 0.00 RW-sx
------------
TRANSACTIONS
------------
Trx id counter 2379
Purge done for trx's n:o < 2376 undo n:o < 0 state: running but idle
History list length 0
LIST OF TRANSACTIONS FOR EACH SESSION:
---TRANSACTION 418657121344184, not started
mysql tables in use 1, locked 1
0 lock struct(s), heap size 1128, 0 row lock(s)
---TRANSACTION 418657121343336, not started
0 lock struct(s), heap size 1128, 0 row lock(s)
---TRANSACTION 418657121339944, not started
0 lock struct(s), heap size 1128, 0 row lock(s)
---TRANSACTION 418657121339096, not started
0 lock struct(s), heap size 1128, 0 row lock(s)
---TRANSACTION 2378, ACTIVE 64 sec inserting
mysql tables in use 1, locked 1
LOCK WAIT 2 lock struct(s), heap size 1128, 1 row lock(s)
MySQL thread id 168, OS thread handle 137182133081664, query id 1832 localhost root update
insert into locks values (2)
------- TRX HAS BEEN WAITING 64 SEC FOR THIS LOCK TO BE GRANTED:
RECORD LOCKS space id 5 page no 4 n bits 80 index PRIMARY of table `lock_test`.`locks` trx id 2378 lock_mode X locks gap before rec insert intention waiting
Record lock, heap no 3 PHYSICAL RECORD: n_fields 4; compact format; info bits 0
 0: len 4; hex 80000003; asc     ;;
 1: len 6; hex 0000000008b0; asc       ;;
 2: len 7; hex 81000000b5011d; asc        ;;
 3: SQL DEFAULT;

------------------
---TRANSACTION 2377, ACTIVE 67 sec starting index read
mysql tables in use 1, locked 1
LOCK WAIT 2 lock struct(s), heap size 1128, 1 row lock(s)
MySQL thread id 166, OS thread handle 137182060738112, query id 1831 localhost root updating
update locks set i = 4 where i = 1
------- TRX HAS BEEN WAITING 67 SEC FOR THIS LOCK TO BE GRANTED:
RECORD LOCKS space id 5 page no 4 n bits 80 index PRIMARY of table `lock_test`.`locks` trx id 2377 lock_mode X locks rec but not gap waiting
Record lock, heap no 8 PHYSICAL RECORD: n_fields 4; compact format; info bits 64
 0: len 4; hex 80000001; asc     ;;
 1: len 6; hex 000000000940; asc      @;;
 2: len 7; hex 81000000f50110; asc        ;;
 3: len 30; hex 2f02600048ffd08000000200000000094602000000f805a904ca31000000; asc / ` H           F         1   ; (total 4294967291 bytes);

------------------
---TRANSACTION 2376, ACTIVE 69 sec
2 lock struct(s), heap size 1128, 5 row lock(s)
MySQL thread id 167, OS thread handle 137182188664384, query id 1830 localhost root
--------
FILE I/O
--------
I/O thread 0 state: waiting for completed aio requests (insert buffer thread)
I/O thread 1 state: waiting for completed aio requests (read thread)
I/O thread 2 state: waiting for completed aio requests (read thread)
I/O thread 3 state: waiting for completed aio requests (read thread)
I/O thread 4 state: waiting for completed aio requests (read thread)
I/O thread 5 state: waiting for completed aio requests (write thread)
I/O thread 6 state: waiting for completed aio requests (write thread)
I/O thread 7 state: waiting for completed aio requests (write thread)
I/O thread 8 state: waiting for completed aio requests (write thread)
Pending normal aio reads: [0, 0, 0, 0] , aio writes: [0, 0, 0, 0] ,
 ibuf aio reads:
Pending flushes (fsync) log: 0; buffer pool: 0
935 OS file reads, 2624 OS file writes, 1753 OS fsyncs
0.00 reads/s, 0 avg bytes/read, 0.00 writes/s, 0.00 fsyncs/s
-------------------------------------
INSERT BUFFER AND ADAPTIVE HASH INDEX
-------------------------------------
Ibuf: size 1, free list len 0, seg size 2, 0 merges
merged operations:
 insert 0, delete mark 0, delete 0
discarded operations:
 insert 0, delete mark 0, delete 0
Hash table size 34679, node heap has 6 buffer(s)
Hash table size 34679, node heap has 1 buffer(s)
Hash table size 34679, node heap has 2 buffer(s)
Hash table size 34679, node heap has 1 buffer(s)
Hash table size 34679, node heap has 2 buffer(s)
Hash table size 34679, node heap has 2 buffer(s)
Hash table size 34679, node heap has 1 buffer(s)
Hash table size 34679, node heap has 1 buffer(s)
0.00 hash searches/s, 0.00 non-hash searches/s
---
LOG
---
Log sequence number          20688293
Log buffer assigned up to    20688293
Log buffer completed up to   20688293
Log written up to            20688293
Log flushed up to            20688293
Added dirty pages up to      20688293
Pages flushed up to          20688293
Last checkpoint at           20688293
Log minimum file id is       6
Log maximum file id is       6
Modified age no less than    20688293
Checkpoint age               0
Max checkpoint age           87417344
550 log i/o's done, 0.00 log i/o's/second
----------------------
BUFFER POOL AND MEMORY
----------------------
Total large memory allocated 0
Dictionary memory allocated 577854
Buffer pool size   8191
Buffer pool size, bytes 134201344
Free buffers       7012
Database pages     1163
Old database pages 409
Modified db pages  0
Pending reads      0
Pending writes: LRU 0, flush list 0, single page 0
Pages made young 558, not young 118
0.00 youngs/s, 0.00 non-youngs/s
Pages read 912, created 342, written 1477
0.00 reads/s, 0.00 creates/s, 0.00 writes/s
Buffer pool hit rate 1000 / 1000, young-making rate 0 / 1000 not 0 / 1000
Pages read ahead 0.00/s, evicted without access 0.00/s, Random read ahead 0.00/s
LRU len: 1163, unzip_LRU len: 0
I/O sum[0]:cur[0], unzip sum[0]:cur[0]
--------------
ROW OPERATIONS
--------------
0 queries inside InnoDB, 0 queries in queue
0 read views open inside InnoDB
3 RW transactions active inside InnoDB
Process ID=10141, Main thread ID=137181521774144 , state=sleeping
Number of rows inserted 461, updated 16, deleted 23, read 516
0.00 inserts/s, 0.00 updates/s, 0.00 deletes/s, 0.00 reads/s
Number of system rows inserted 119, updated 365, deleted 58, read 15534
0.00 inserts/s, 0.00 updates/s, 0.00 deletes/s, 0.00 reads/s
----------------------------
END OF INNODB MONITOR OUTPUT
============================

1 row in set (0.00 sec)


