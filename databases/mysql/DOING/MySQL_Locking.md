
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

*  Select metalocks
```
SELECT * FROM performance_schema.metadata_locks;
```

*
```

select t.thread_id, t.processlist_id

from performance_schema.metadata_locks ml
  join performance_schema.threads t on (t.thread_id = ml.owner_thread_id)
  join performance_schema.processlist p on (p.id = t.processlist_id) 


  -> WHERE OBJECT_TYPE='USER LEVEL LOCK'
    -> AND OBJECT_NAME='foobarbaz';
 
mysql> SELECT PROCESSLIST_ID FROM performance_schema.threads
    -> WHERE THREAD_ID=35;


```


Setup the locks. Start 3 mysql session. We will call them Session 1, 2 and 3. Screen or tmux might be helpful here.

* In Session 1
```
create database if not exists lock_test;
use lock_test;
drop table if exists locks;
create table if not exists locks (i int, primary key (i));

insert into locks values (1),(3);

  # default 50
set GLOBAL innodb_lock_wait_timeout=50;

```

* In Session 1

```
begin;
select * from locks where i = 0 or i = 3 for update;

```


* In session 2. We wil do an update lock. 
```
use lock_test;
update locks set id = 4 where id =1;
```

* In Session 3 we will do a GAP lock. 
```
use lock_test;
insert into locks values (2);
```

* In Session 4, we will do an alter lock
```
use lock_test;
alter table locks add column (test text);

```

* See the locks
```

```