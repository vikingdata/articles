 
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
2. [Setup MySQL password and tables](#setup)
3. [Select tables with a certain amount of Free Space](#free)
4. [Select all innodb tables](#all)
5. [Calculate free space](#calc)
6. [Get status of innodb tables free space](#status)
7. [Clear Free space from tables with one-file-per-table](#clear)
8. [Monitor](#monitor)
* * *
<a name=links></a>Links
-----



* * *
<a name=setup></a>Setup MySQL password and tables
-----

In Linux

```
echo "
drop user if exists reload@localhost;
create user reload@localhost identified by 'reload';
grant  all privileges on *.*     to   reload@localhost;
revoke if exists all privileges on mysql.* from reload@localhost;
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
insert into table_innodb2 values (@s), (@s), (@s);
insert into table_myisam1 values (@s), (@s), (@s), (@s), (@s), (@s), (@s), (@s), (@s), (@s), (@s), (@s);

delete from table_innodb1;
insert into table_innodb1 values (@s), (@s), (@s);
delete from table_innodb2;
insert into table_innodb2 values (@s);

analyze table table_innodb1;
analyze table table_innodb2;
" > setup.sql
```

In linux -- NOTE: change your root password if different. 
```
echo "
[mysql]
user=reload
password=reload

" > ~/.my.cnf_reload

echo "
[mysql]
user=root
password=root

" > ~/.my.cnf_root


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
select table_schema as db, table_name as tbl, engine, data_free, DATA_LENGTH, table_rows 
from information_schema.tables
where table_type = 'BASE TABLE' and table_schema not in
  ('mysql', 'performance_schema', 'information_schema', 'sys')
  and engine = 'InnoDB' order by data_free desc;
" > select_innodb_tables.sql
```

* * *
<a name=calc></a>Calculate free space
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
<a name=status></a>Get status of innodb tables free space
-----

```
mysql --defaults-file=~/.my.cnf_root   -e "source setup.sql"
mysql --defaults-file=~/.my.cnf_reload -e "source select_innodb_tables.sql"
mysql --defaults-file=~/.my.cnf_reload -e "source select_innodb_tables_free.sql"
```


* * *
<a name=clear></a>Clear Free space from tables with one-file-per-table
-----
 In MySQL

```
mysql --defaults-file=~/.my.cnf_reload -N -e "source select_innodb_tables.sql" > table_list1.txt
mysql --defaults-file=~/.my.cnf_reload -N -e "source select_innodb_tables_free.sql" > table_list2.txt

awk '{print "alter table "$1 "." $2 " engine=innodb;"}' table_list1.txt > reload1.sql
awk '{print "alter table "$1 "." $2 " engine=innodb;"}' table_list2.txt > reload2.sql
echo "analyze table table_innodb1; analyze table table_innodb2;" >> reload1.sql
echo "analyze table table_innodb1; analyze table table_innodb2;" >> reload2.sql

mysql --defaults-file=~/.my.cnf_root -e "source setup.sql" > /dev/null
sleep 1
mysql --defaults-file=~/.my.cnf_reload -e "source select_innodb_tables.sql" 
mysql --defaults-file=~/.my.cnf_reload -e "source reload1.sql" reload_test > /dev/null
sleep 1
echo "data_free should empty in innodb_table1 and innodb_table2"
mysql --defaults-file=~/.my.cnf_reload -e "source select_innodb_tables.sql" 



mysql --defaults-file=~/.my.cnf_root -e "source setup.sql" > /dev/null
sleep 1
mysql --defaults-file=~/.my.cnf_reload -e "source select_innodb_tables.sql" 
mysql --defaults-file=~/.my.cnf_reload -e "source reload2.sql" reload_test > /dev/null
sleep 1
echo "data_free should empty in innodb_table1"
mysql --defaults-file=~/.my.cnf_reload -e "source select_innodb_tables.sql"  


```


* * *
<a name=monitor></a>Monitor
-----

When you do this to prod tables
   * Strt screen
   * In one window, monitor with the linux commands below
   * In another window reload our tables.
   
```
DB_DIR="/var/lib/mysql"

while sleep 10; do
  clear;
  mysql --defaults-file=~/.my.cnf_root -e "show processlist"| grep -vi sleep | grep -vi "system user" | grep -v "show processlist";
  echo "";
  df -h  $DB_DIR
done

```

