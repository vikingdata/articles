 
---
title : MySQL Free Space
author : Mark Nielsen  
copyright : November 2024  
---


MySQL Free Space
==============================

_**by Mark Nielsen
Original Copyright November 2024**_


1. [Links](#links)

* * *
<a name=links></a>Links
-----



* * *
<a name=setup></a>Setup MySQL password and tables
-----

In Linux

```
echo "
create user reload@localhost identified by 'reload';
grant  all privileges on *.*     to   reload@localhost;
revoke all privileges on mysql.* from reload@localhost;
grant select on mysql.* to reload@localhost;


create database if not exists reload_test;
use reload_test;

drop table if exists table_innodb1;
drop table if exists table_innodb2;
drop table if exists table_myisam1;
drop view if exists view1;

create table if not exists table_innodb1 (c longtext);
create table if not exists table_innodb2 (c longtext);
create table if not exists table_myisam1 (c longtext) engine=MyISAM;
create view view1 as select * from table_innodb1;

select @s:=repeat('a', 1024*1024);
insert into table_innodb1 values (@s), (@s), (@s), (@s), (@s), (@s), (@s), (@s), (@s), (@s), (@s), (@s);
insert into table_innodb1 values (@s), (@s), (@s), (@s), (@s), (@s), (@s), (@s), (@s), (@s), (@s), (@s);
insert into table_innodb1 values (@s), (@s), (@s), (@s), (@s), (@s), (@s), (@s), (@s), (@s), (@s), (@s);
insert into table_innodb1 values (@s), (@s), (@s), (@s), (@s), (@s), (@s), (@s), (@s), (@s), (@s), (@s);
insert into table_innodb2 values (@s), (@s);
insert into table_myisam1 values (@s), (@s), (@s), (@s), (@s), (@s), (@s), (@s), (@s), (@s), (@s), (@s);

delete from table_innodb1;
insert into table_innodb1 values (@s), (@s), (@s);
delete from table_innodb2;
insert into table_innodb1 values (@s);

analyze table table_innodb1;
analyze table table_innodb2;
" > setup.sql
```

In linux
```
```
echo "
[mysql]
user=reload
password=reload

" > ~/.my.cnf_reload
```

```

* * *
<a name=free></a>Select tables with a certain amount of  Free Space
-----

```
echo "
select table_schema as db, table_name as tbl, engine, data_free, DATA_LENGTH, table_rows
from information_schema.tables
where table_type = 'BASE TABLE' and table_schema not in
    ('mysql', 'performance_schema', 'information_schema', 'sys')
  and engine = 'InnoDB'
  and data_free > 1024*1024
  order by data_free desc;
" > select_innodb_tables_free.sql
```

* * *
<a name=all></a>Select all innodb tables
-----

```
echo "
select table_schema as db, table_name as tbl, engine, data_free 
from information_schema.tables
where table_type = 'BASE TABLE' and table_schema not in
  ('mysql', 'performance_schema', 'information_schema', 'sys')
  and engine = 'InnoDB' order by data_free desc;
" > select_innodb_tables.sql
```

* * *
<a name=free></a>Calculate free space
-----

In MySQL

```
select sum(data_free) as free_space_above_1_k
from information_schema.tables
where table_type = 'BASE TABLE' and table_schema not in
  ('mysql', 'performance_schema', 'information_schema', 'sys')
  and engine = 'InnoDB'
  and data_free > 1024*1024;

select sum(data_free) as all_free_space
from information_schema.tables
where table_type = 'BASE TABLE' and table_schema not in
  ('mysql', 'performance_schema', 'information_schema', 'sys')
  and engine = 'InnoDB';

```

* * *
<a name=status</a>Get status of innodb tables free space
-----

```
mysql --defaults-file=~/.my.cnf_reload -e "source setup.sql"
mysql --defaults-file=~/.my.cnf_reload -e "source select_innodb_tables.sql"
mysql --defaults-file=~/.my.cnf_reload -e "source select_innodb_tables_free.sql"
```


* * *
<a name=clear></a>Clear Free space from tables with one-file-per-table
-----
 In MySQL

```
mysql --defaults-file=~/.my.cnf_reload -e "source select_innodb_tables.sql" > table_list1.txt
mysql --defaults-file=~/.my.cnf_reload -e "source select_innodb_tables_free.sql" > table_list2.txt

awk '{print "alter table "$1 "." $2 " engine=innodb;"}' table_list1.txt >> reload1.sql
awk '{print "alter table "$1 "." $2 " engine=innodb;"}' table_list2.txt >> reload2.sql

mysql --defaults-file=~/.my.cnf_reload -e "source select_innodb_tables.sql" 
mysql --defaults-file=~/.my.cnf_reload -e "source reload1.sql" 
mysql --defaults-file=~/.my.cnf_reload -e "source select_innodb_tables.sql" 


mysql --defaults-file=~/.my.cnf_reload -e "source setup.sql"
mysql --defaults-file=~/.my.cnf_reload -e "source select_innodb_tables.sql" 
mysql --defaults-file=~/.my.cnf_reload -e "source reload2.sql"
mysql --defaults-file=~/.my.cnf_reload -e "source select_innodb_tables.sql"  


```


* * *
<a name=monitor></a>Monitor
-----

