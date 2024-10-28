
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
* General query
```
select
  object_schema as db,
  object_name as name,
  GROUP_CONCAT(DISTINCT EXTERNAL_LOCK) as locks
from
  performance_schema.table_handles 
where external_lock is not null
group by db, name;

```

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

* Use the INFORMATION_SCHEMA.INNODB_TRX table.
```
SELECT TRX_ID
  , TRX_STATE
  ,  trx_mysql_thread_iD AS MID
  ,  trx_tables_locked TL
  , trx_rows_locked as rl
FROM INFORMATION_SCHEMA.INNODB_TRX;


-> WHERE OBJECT_TYPE='USER LEVEL LOCK'
    -> AND OBJECT_NAME='foobarbaz';
 
mysql> SELECT PROCESSLIST_ID FROM performance_schema.threads
    -> WHERE THREAD_ID=35;

* Use the data_locks table
```
select * from performance_schema.data_locks;
```

* Use the data_lock_waits table. 
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
might show up. 
```
select  dlw.BLOCKING_THREAD_ID as thread_id1
  , t1.PROCESSLIST_ID as p1
  , t1.PROCESSLIST_INFO as info1
  , ' blocks ' 
  , dlw.REQUESTING_THREAD_ID as thred_id2
  , t2.PROCESSLIST_ID as p2
  , t2.PROCESSLIST_INFO as info2

from performance_schema.data_lock_waits dlw
  join performance_schema.threads t1 on (t1.thread_id = dlw.BLOCKING_THREAD_ID)
  join performance_schema.threads t2 on (t2.thread_id = dlw.REQUESTING_THREAD_ID)
;
```

* Use performance_schema.threads joined to performance_schema.data_lock_waits
```
use lock_test;
drop temporary table if exists temp_locks;
create temporary table temp_locks select distinct  THREAD_ID from performance_schema.data_locks;

select  dlw.BLOCKING_THREAD_ID as thread_id1
  , t1.PROCESSLIST_ID as p1
  , t1.PROCESSLIST_INFO as info1
  , ' blocks '
  , dlw.REQUESTING_THREAD_ID as thread_id2
  , t2.PROCESSLIST_ID as p2
  , t2.PROCESSLIST_INFO as info2

from temp_locks tl
  join performance_schema.threads t2 on (t2.thread_id = tl.thread_id)
  left join performance_schema.data_lock_waits dlw on (dlw.REQUESTING_THREAD_ID = tl.thread_id)
  left join performance_schema.threads t1 on (t1.thread_id = dlw.BLOCKING_THREAD_ID)

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


* See the locks
```
--------------
SELECT * FROM performance_schema.metadata_locks
--------------


| OBJECT_TYPE   | OBJECT_SCHEMA      | OBJECT_NAME     | COLUMN_NAME | OBJECT_INSTANCE_BEGIN | LOCK_TYPE           | LOCK_DURATION | LOCK_STATUS | SOURCE             | OWNER_THREAD_ID | OWNER_EVENT_ID |

| TABLE         | performance_schema | metadata_locks  | NULL        |       137180987078352 | SHARED_READ         | TRANSACTION   | GRANTED     | sql_parse.cc:6427  |              88 |              2 |
| TABLE         | lock_test          | locks           | NULL        |       137181199687296 | SHARED_WRITE        | TRANSACTION   | GRANTED     | sql_parse.cc:6427  |              60 |            134 |
| GLOBAL        | NULL               | NULL            | NULL        |       137181255481248 | INTENTION_EXCLUSIVE | STATEMENT     | GRANTED     | sql_base.cc:3080   |              64 |             13 |
| TABLE         | lock_test          | locks           | NULL        |       137181255484752 | SHARED_WRITE        | TRANSACTION   | GRANTED     | sql_parse.cc:6427  |              64 |             13 |
| GLOBAL        | NULL               | NULL            | NULL        |       137181389711728 | INTENTION_EXCLUSIVE | STATEMENT     | GRANTED     | sql_base.cc:3080   |              65 |             12 |
| TABLE         | lock_test          | locks           | NULL        |       137181391220992 | SHARED_WRITE        | TRANSACTION   | GRANTED     | sql_parse.cc:6427  |              65 |             12 |
| GLOBAL        | NULL               | NULL            | NULL        |       137182115157040 | INTENTION_EXCLUSIVE | STATEMENT     | GRANTED     | sql_base.cc:3080   |              67 |             12 |
| TABLE         | lock_test          | locks           | NULL        |       137182115158608 | SHARED_WRITE        | TRANSACTION   | GRANTED     | sql_parse.cc:6427  |              67 |             12 |
| GLOBAL        | NULL               | NULL            | NULL        |       137181930334304 | INTENTION_EXCLUSIVE | STATEMENT     | GRANTED     | sql_base.cc:5548   |              68 |             40 |
| BACKUP LOCK   | NULL               | NULL            | NULL        |       137181930269360 | INTENTION_EXCLUSIVE | TRANSACTION   | GRANTED     | sql_base.cc:5560   |              68 |             40 |
| SCHEMA        | lock_test          | NULL            | NULL        |       137181930334832 | INTENTION_EXCLUSIVE | TRANSACTION   | GRANTED     | sql_base.cc:5535   |              68 |             40 |
| TABLE         | lock_test          | locks           | NULL        |       137181930309072 | SHARED_UPGRADABLE   | TRANSACTION   | GRANTED     | sql_parse.cc:6427  |              68 |             40 |
| BACKUP TABLES | NULL               | NULL            | NULL        |       137181930701760 | INTENTION_EXCLUSIVE | STATEMENT     | GRANTED     | lock.cc:1260       |              68 |             40 |
| TABLESPACE    | NULL               | lock_test/locks | NULL        |       137181930125744 | INTENTION_EXCLUSIVE | TRANSACTION   | GRANTED     | lock.cc:813        |              68 |             40 |
| TABLE         | lock_test          | #sql-279d_20    | NULL        |       137181930746544 | EXCLUSIVE           | STATEMENT     | GRANTED     | sql_table.cc:17580 |              68 |             40 |
| TABLE         | lock_test          | locks           | NULL        |       137181930289920 | EXCLUSIVE           | TRANSACTION   | PENDING     | mdl.cc:3776        |              68 |             41 |

```