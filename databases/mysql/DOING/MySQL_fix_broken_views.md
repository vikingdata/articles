
---
title : MySQL Fix Views
author : Mark Nielsen
copyright : November 2024
---


MySQL Fix Views
==============================

_**by Mark Nielsen
Copyright November 2024**_

Sometimes views may not work. Thhe trick is to recreate them. If the view is in the same database as the table, you can
use 'show create view <VIEW>' to how it was created, drop it, and then recreate it. If the table is in another
database as the view, show create view won't work. The trick is to use information_schema. 

1. [Links](#links)


* * *
<a name=links></a>Links
-----

* * *
<a name=Setup></a>Setup 
-----

```
echo "

drop database if exists test_tables;
create database if not exists test_tables;
use test_tables;
create table tbl1 (i int);
create table tbl2 (i int);
insert into tbl1 values (1);
insert into tbl2 values (1);

drop database if exists test_views;
create database if not exists test_views;
use test_views;

create view view1 as select * from test_tables.tbl1;
create view view2 as select * from test_tables.tbl2;
create view view3 as select * from test_tables.tbl3;
" > setup_views.sql


echo "
drop test_tables.table tbl2;
" > drop_tbl2.sql

echo "
use test_views;
select 'This select from a view will work';
select * from view1 limit 1;

select 'This select will fail';
select * from view2 limit 1;

select 'This show create view from view1 will work';
show create view view1;

select 'This show create view from view2 will fail';
show reate view view2;

select 'This select from information_schema will work for all';

select TABLE_SCHEMA as db, TABLE_NAME as tbl, VIEW_DEFINITION, DEFINER, SECURITY_TYPE
from information_schema.views
where table_schema in ('test_views');
" > test_views.sql

```


```
* * *
<a name=execute></a>Execute scripts
-----

* Start mysql client and connect to mysql
* Execute setup
    * Notice views3 could not be create because tbl3 doesn't exist. 

```
source setup_views.sql

```

Output
```

mysql> create view view3 as select * from tbl3;
ERROR 1146 (42S02): Table 'test_views.tbl3' doesn't exist
mysql>
```

* Execute drop tbl2
```
source drop_tbl2.sql

```

