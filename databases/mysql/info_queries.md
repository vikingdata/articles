
---
title : MySQL Info queries
author : Mark Nielsen
copyright : Feb 2021 to Sept 2023
---


MySQL Info queries
==============================

_**by Mark Nielsen
Original Copyright Feb 2021**_

This article will grow over time. 

TODO: simple performance_schema queries, information_schema queries

1. [table files](#files)
2. [InnoDB buffer pool ratio](#ibpr)
3. [Size of database/tables and created](#size)
4. [Free spac of tables](#free)
5. [No index](#noindex)
6. [Busiest tables](#busy)
7. [Unused indexes](#unused)
8. [List stored procedures, functions, triggers](#list1)
9. [find keyword in field, table, database](#find1)
10. [count tables](#count)
11.  Tempoary diskspace
* * *

<a name=files></a>files
-----

This tell you if a table is in its own tablespace, general tablespace, or system tablespace.
  https://dev.mysql.com/doc/refman/8.0/en/general-tablespaces.html


```sql

mysql> select FILE_ID, FILE_NAME, FILE_TYPE, TABLESPACE_NAME
 from INFORMATION_SCHEMA.files;
```

* * *

<a name=ibpr></a>InnoDB buffer pool ratio
-----

This tell how efficient read queries are getting data from memory and not disk.

```aql


SHOW GLOBAL STATUS WHERE Variable_name RLIKE '^(innodb_pages_read|innodb_buffer_pool_read_requests$)';

SELECT variable_value into @ipr from  performance_schema.global_status where variable_name='Innodb_pages_read';
SELECT variable_value into @ibprq  from  performance_schema.global_status where variable_name='Innodb_buffer_pool_read_requests';
select @ipr, @ibprq;

select round( 100.0 - 100.0 * (@ipr/@ibprq), 2) as innodb_buffer_hit_ratio;


```

* * *

<a name=size></a>Size of database and tables and created
-----

```sql
set @gig = 1024*1024*1024;
set @meg = 1024*1024;
select @meg, @gig;

SELECT table_schema 
        , ROUND(SUM(data_length + index_length) / @meg, 2)  as db_size_in_meg 
	, ROUND(SUM(data_length + index_length) / @gig, 2)  as db_size_in_gig
FROM information_schema.tables 
where table_schema not in
 ('mysql', 'information_schema', 'performance_schema', 'sys')
GROUP BY table_schema
order by db_size_in_meg desc
limit 10;

-- largest tables

set @gig = 1024*1024*1024;
set @meg = 1024*1024;
select @meg, @gig;

SELECT table_schema, table_name
        , ROUND(SUM(data_length + index_length) / @meg, 2)  as tbl_size_in_meg
        , ROUND(SUM(data_length + index_length) / @gig, 2)  as tbl_size_in_gig
FROM information_schema.tables
where table_schema not in
 ('mysql', 'information_schema', 'performance_schema', 'sys')
GROUP BY table_schema, table_name
order by db_size_in_meg desc
limit 10;

-- size of database and earliest table

SELECT table_schema 
	, ROUND(SUM(data_length + index_length) / @gig, 2)  as db_size_in_gig
	, MIN(create_time) AS min_creation_time_table
FROM information_schema.tables 
where table_schema not in
 ('mysql', 'information_schema', 'performance_schema', 'sys')

GROUP BY table_schema
order by min_creation_time_table desc , db_size_in_gig desc
limit 10;


SELECT table_schema
        , ROUND(SUM(data_length + index_length) / @gig, 2)  as db_size_in_gig
        , MIN(create_time) AS creation_time
FROM information_schema.tables
where table_schema in ('<DB>')
GROUP BY table_schema
order by creation_time desc, db_size_in_gig desc
limit 10;


```


* Also,  databases and tables listed by create date, oldest and newset first. 
```
set @gig = 1024*1024*1024;
set @meg = 1024*1024;
select @meg, @gig;

-- by first table
SELECT table_schema
  , ROUND(SUM(data_length + index_length) / @meg, 2)  as db_meg
   , MIN(create_time) AS creation_time
  FROM information_schema.tables
  where table_schema not in
       ('mysql', 'information_schema', 'performance_schema', 'sys')
  GROUP BY table_schema
  order by creation_time desc
  limit 10;
		   

SELECT table_schema
    , ROUND(SUM(data_length + index_length) / @meg, 2) as db_meg
    , MIN(create_time) AS creation_time
  FROM information_schema.tables
  where table_schema not in
       ('mysql', 'information_schema', 'performance_schema', 'sys')
  GROUP BY table_schema
  order by creation_time
  limit 10;
		      

SELECT table_schema, table_name
        , ROUND(SUM(data_length + index_length) / @meg, 2)  as tbl_meg
	, MIN(create_time) AS creation_time
  FROM information_schema.tables
  where table_schema not in
	 ('mysql', 'information_schema', 'performance_schema', 'sys')
  GROUP BY table_schema, table_name
  order by creation_time desc
  limit 50;

set @gig = 1024*1024*1024;
set @meg = 1024*1024;
select @meg, @gig;

SELECT table_schema, table_name
        , ROUND(SUM(data_length + index_length) / @meg, 2)  as tbl_meg
        , MIN(create_time) AS creation_time
  FROM information_schema.tables
    where table_schema not in
            ('mysql', 'information_schema', 'performance_schema', 'sys')
  GROUP BY table_schema, table_name
  order by creation_time
limit 50;
		   


```

* * *

<a name=free></a>Free space in tables
-----
```

set @gig = 1024*1024*1024;
set @meg = 1024*1024;
select @meg, @gig;

SELECT table_schema, table_name, data_free/@meg as data_free_meg
        , (data_length + index_length) / @meg  as db_size_in_meg
FROM information_schema.tables
where table_schema not in ('mysql', 'information_schema', 'performance_schema', 'sys')
  and data_free > 4*@meg 
order by data_free_meg desc
;


 -- list by smallet first might be best.
SELECT table_schema, table_name, data_free/@meg as data_free_meg
        , (data_length + index_length) / @meg  as db_size_in_meg
FROM information_schema.tables
where table_schema not in ('mysql', 'information_schema', 'performance_schema', 'sys')
  and data_free > 4*@meg
order by data_free_meg
;


```

* * *

<a name=noindex></a>Detect tables with no primary keys or unique indexes. 
-----



```sql

-- list all tables and constraints

select t.table_schema as db
       , t.table_name as tablename
       , tc.constraint_type
from information_schema.tables t
left join information_schema.table_constraints tc
          on tc.table_schema = t.table_schema
          and tc.table_name = t.table_name
where t.table_schema not in('mysql', 'information_schema', 'performance_schema', 'sys')
   and and t.table_type = 'BASE TABLE'
order by t.table_schema, t.table_name;

-- list all tables with primary or unique keys

select t.table_schema as db
        , t.table_name as tablename
       ,tc.constraint_type
from information_schema.tables t
left join information_schema.table_constraints tc
          on tc.table_schema = t.table_schema
          and tc.table_name = t.table_name
          and tc.constraint_type in ('PRIMARY KEY', 'UNIQUE')
where tc.constraint_type is not null
      and t.table_schema not in('mysql', 'information_schema', 'performance_schema', 'sys')
      and t.table_type = 'BASE TABLE'
order by t.table_schema, t.table_name;

-- list tables without primary or unique keys

select t.table_schema as db,
       t.table_name as tablename
from information_schema.tables t
left join information_schema.table_constraints tc
          on tc.table_schema = t.table_schema
          and tc.table_name = t.table_name
          and tc.constraint_type = in ('PRIMARY KEY', 'UNIQUE')
where tco.constraint_type is null
      and tab.table_schema not in('mysql', 'information_schema', `performance_schema', 'sys')
      and tab.table_type = 'BASE TABLE'
order by t.table_schema, t.table_name;

-- list out columns in prmary key or unqiue keys

select t.table_schema as db
       , t.table_name as tablename
       ,tc.constraint_type
       , group_concat(k.column_name separator ', ') as col
from information_schema.tables t
left join information_schema.table_constraints tc
          on tc.table_schema = t.table_schema
          and tc.table_name = t.table_name
          and tc.constraint_type in ('PRIMARY KEY', 'UNIQUE')
JOIN information_schema.key_column_usage k
          on k.constraint_name = tc.constraint_name
	  and k.table_schema = tc.table_schema
	  and k.table_name = tc.table_name
where 
      tc.constraint_type is not null
      and t.table_schema not in('mysql', 'information_schema', 'performance_schema', 'sys')
      and t.table_type = 'BASE TABLE'
group by t.table_schema, t.table_name, tc.constraint_type
order by t.table_schema, t.table_name;
```

* * *

<a name=busy></a>Busiest tables.
-----


Stolen from https://blog.sqlauthority.com/2023/08/01/mysql-identifying-and-optimizing-the-busiest-tables/?utm_source=rss&utm_medium=rss&utm_campaign=mysql-identifying-and-optimizing-the-busiest-tables

```sql
SELECT 
OBJECT_SCHEMA, 
OBJECT_NAME,
SUM(COUNT_READ) AS TOTAL_READS,
SUM(COUNT_WRITE) AS TOTAL_WRITES, 
SUM(COUNT_FETCH) AS TOTAL_FETCHES,
SUM(COUNT_INSERT) AS TOTAL_INSERTS,
SUM(COUNT_UPDATE) AS TOTAL_UPDATES,
SUM(COUNT_DELETE) AS TOTAL_DELETES,
SUM(COUNT_STAR) AS TOTAL
FROM performance_schema.table_io_waits_summary_by_table
where
   object_schema  not in('mysql', 'information_schema', 'performance_schema', 'sys')
GROUP BY OBJECT_SCHEMA, OBJECT_NAME
ORDER BY TOTAL DESC
LIMIT 10;


```

* * *

<a name=unused></a>Unused Indexes.
-----


Stolen from https://www.ktexperts.com/mysql-identifying-unused-indexes/


```sql

SHOW GLOBAL STATUS LIKE 'Uptime';
SELECT variable_value into @v from  performance_schema.global_status where variable_name='Uptime';
set @day=60*60*24;
set @hour=60*60;
select 'Server has been up ', round((@v/@day),0) as days, ' days or  ', round(@v/@hour,0) as hours, ' hours or  ', @v, ' seconds.'; 


SELECT object_schema, object_name, index_name
FROM performance_schema.table_io_waits_summary_by_index_usage
WHERE index_name IS NOT NULL
    AND count_star = 0
    and  object_schema  not in('mysql', 'information_schema', 'performance_schema', 'sys')
ORDER BY object_schema, object_name, index_name;
```


* * *

<a name=tc></a>Table cache.
-----


* * *

<a name=list1></a>List stored procedures, functions, triggers
-----

* stored procedures and functions. and triggers
```
SELECT  routine_schema,  
        routine_name,  
        routine_type 
FROM information_schema.routines 
WHERE routine_schema not in ('sys', 'mysql', 'mysql_innodb_cluster_metadata', 'information_schema', 'performance_schema') 
ORDER BY routine_name;

  # just trigger name
select trigger_schema, trigger_name
  from information_schema.triggers
  WHERE trigger_schema not in ('sys', 'mysql', 'mysql_innodb_cluster_metadata', 'information_schema', 'performance_schema');

  # triggers with code
select trigger_schema, trigger_name, action_statement
  from information_schema.triggers
  WHERE trigger_schema not in ('sys', 'mysql', 'mysql_innodb_cluster_metadata', 'information_schema', 'performance_schema');
```

* * *

<a name=find1></a>find keyword in field, table, database
-----


```
create database if not exists test1;
create database if not exists temp2;
use temp2;
create table if not exists test2 (i int, primary key(i));
create database if not exists temp3;
use temp3;
create table if not exists table2 (test3 int, primary key(test3));


select @field := 'test';

SELECT table_schema, table_NAME, COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE COLUMN_NAME like concat ('%', @field, '%')
     AND TABLE_SCHEMa not in ('sys', 'mysql', 'mysql_innodb_cluster_metadata', 'information_schema', 'performance_schema')
union

SELECT  table_schema, table_NAME, '' 
    FROM INFORMATION_SCHEMA.TABLES
    WHERE  table_NAME like concat ('%', @field, '%')

union

SELECT schema_name, '', ''
    FROM INFORMATION_SCHEMA.schemata
    WHERE schema_NAME like concat ('%', @field, '%')
 ;


SELECT table_schema, table_NAME, COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE COLUMN_NAME like concat ('%', @field, '%')
     AND TABLE_SCHEMa not in ('sys', 'mysql', 'mysql_innodb_cluster_metadata', 'information_schema', 'performance_schema')
     and table_schema in ('db1', 'db2')
union

SELECT  table_schema, table_NAME, ''
    FROM INFORMATION_SCHEMA.TABLES
    WHERE  table_NAME like concat ('%', @field, '%')
    and table_schema in ('db1', 'db2')
union

SELECT schema_name, '', ''
    FROM INFORMATION_SCHEMA.schemata
    WHERE schema_NAME like concat ('%', @field, '%')
;
```

* * *
<a name=count></a>Count tables.
-----
```


SELECT count(1), table_schema
    FROM INFORMATION_SCHEMA.tables
    WHERE 
      TABLE_SCHEMa not in ('sys', 'mysql', 'mysql_innodb_cluster_metadata', 'information_schema', 'performance_schema')
    group by table_schema;

;


SELECT count(1), table_schema
    FROM INFORMATION_SCHEMA.tables
    WHERE 
     TABLE_SCHEMa not in ('sys', 'mysql', 'mysql_innodb_cluster_metadata', 'information_schema', 'performance_schema')
     and table_schema like '%pattern%'
    group by table_schema;
 ;

```


* * *
<a name=temp></a>Tempoary Diskspace
-----

links
* https://docs.percona.com/percona-server/5.7/diagnostics/misc_info_schema_tables.html#information_schematemporary_tables
* https://dev.mysql.com/doc/refman/8.4/en/innodb-information-schema-temp-table-info.html
* https://dev.mysql.com/doc/refman/8.4/en/information-schema-innodb-temp-table-info-table.html
* https://dev.mysql.com/doc/refman/8.4/en/information-schema-innodb-session-temp-tablespaces-table.html
* https://mariadb.com/kb/en/information-schema-temp_tables_info-table/#:~:text=The%20Information%20Schema%20TEMP_TABLES_INFO%20table,data%20is%20stored%20in%20memory.
* https://docs.percona.com/percona-server/8.4/misc-info-schema-tables.html#information_schemaglobal_temporary_tables
* https://www.percona.com/blog/session-temporary-tablespaces-and-disk-space-usage/

### Info
```
mysql> show tables like '%temp%';
+---------------------------------------+
| Tables_in_information_schema (%TEMP%) |
+---------------------------------------+
| GLOBAL_TEMPORARY_TABLES               |
| INNODB_SESSION_TEMP_TABLESPACES       |
| INNODB_TEMP_TABLE_INFO                |
| TEMPORARY_TABLES                      |
+---------------------------------------+
4 rows in set (0.02 sec)

```
* Temp tables -- info from webpages
    * GLOBAL_TEMPORARY_TABLES               "The INFORMATION_SCHEMA.GLOBAL_TEMPORARY_TABLES table in MySQL stores information about temporary tables that are active for all connections. "
    * INNODB_SESSION_TEMP_TABLESPACES       "The INNODB_SESSION_TEMP_TABLESPACES table provides metadata about session temporary tablespaces used for internal and user-created temporary tables."
    * INNODB_TEMP_TABLE_INFO       "The INNODB_TEMP_TABLE_INFO table provides information about user-created InnoDB temporary tables that are active in an InnoDB instance. It does not provide information about internal InnoDB temporary tables used by the optimizer. The INNODB_TEMP_TABLE_INFO table is created when first queried, exists only in memory, and is not persisted to disk."         
    * TEMPORARY_TABLES                 "This table holds information on the temporary tables existing for the running connection."
        * But I believe it is ONLY for tables written to disk. 


#### Get Info
```
 show global variables where variable_name in ('tmp_table_size', 'temptable_max_ram', 'internal_tmp_mem_storage_engine');
+---------------------------------+------------+
| Variable_name                   | Value      |
+---------------------------------+------------+
| internal_tmp_mem_storage_engine | TempTable  |
| temptable_max_ram               | 1073741824 |
| tmp_table_size                  | 16777216   |
+---------------------------------+------------+
3 rows in set (0.00 sec)

mysql> select * from performance_schema.global_variables where variable_name in ('tmp_table_size', 'temptable_max_ram', 'internal_tmp_mem_storage_engine');
+---------------------------------+----------------+
| VARIABLE_NAME                   | VARIABLE_VALUE |
+---------------------------------+----------------+
| internal_tmp_mem_storage_engine | TempTable      |
| temptable_max_ram               | 1073741824     |
| tmp_table_size                  | 16777216       |
+---------------------------------+----------------+
3 rows in set (0.00 sec)

select @tmp_size:=VARIABLE_VALUE
  from performance_schema.global_variables
  where variable_name = 'tmp_table_size';

select @tmptable_size:=VARIABLE_VALUE
  from performance_schema.global_variables
  where variable_name = 'temptable_max_ram';

select if(@tmp_size>@tmptable_size, @tmp_size, @tmptable_size);
+---------------------------------------------------------+
| if(@tmp_size>@tmptable_size, @tmp_size, @tmptable_size) |
+---------------------------------------------------------+
| 16777216                                                |
+---------------------------------------------------------+

mysql> show global variables like '%tmpdir%';
+---------------------+------------+
| Variable_name       | Value      |
+---------------------+------------+
| innodb_tmpdir       |            |
| replica_load_tmpdir | /tmp/mysql |
| slave_load_tmpdir   | /tmp/mysql |
| tmpdir              | /tmp/mysql |
+---------------------+------------+


```

* Get directory of temp diskspace
    * If size of table exceeds size allowed in memory, table goes to disk.
* Do df -h on directory
* 'ls' or 'du' directory.
* select * from information_schema.


```
  # Max size is 16777216 or 16 megs for /tmp/mysql

df -h /tmp/mysql
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda3       112G   39G   67G  37% /


echo "
create database if not exists test1;
drop table if exists not_in_memory;
drop table if exists in_memory;
create temporary table not_in_memory (t longtext);
create temporary table in_memory (t text);
insert into in_memory values (repeat('a',10000));

-- This should show no files. 
select * from  information_schema.INNODB_SESSION_TEMP_TABLESPACES    where size>81920;

insert into not_in_memory values (repeat('a',16777216*2)), (repeat('a',16777216*2)), (repeat('a',16777216*2));

-- This should now show one file if TEMPTABLE uses memory mapped files.
select * from  information_schema.INNODB_SESSION_TEMP_TABLESPACES    where size>81920;

-- This should list both tables
select * from  information_schema.GLOBAL_TEMPORARY_TABLES \G
-- Shows the tablespaces for the temporary tables
select * from  information_schema.INNODB_SESSION_TEMP_TABLESPACES       ;

-- Gives from info on the temporary tables
select * from  information_schema.INNODB_TEMP_TABLE_INFO                ;

-- Lists both tables
select * from  information_schema.TEMPORARY_TABLES                      ;

SELECT PATH, format_bytes(SIZE), STATE, PURPOSE
FROM INFORMATION_SCHEMA.INNODB_SESSION_TEMP_TABLESPACES WHERE id = CONNECTION_ID();

SELECT * FROM INFORMATION_SCHEMA.INNODB_TABLES where name like 'test%';

SELECT * FROM INFORMATION_SCHEMA.temporary_tables\G
SELECT * FROM INFORMATION_SCHEMA.INNODB_TEMP_TABLE_INFO\G

" > test1.sql

echo "No files should be shown to disk IF TEMPTABLE uses memory mapped files"
ls -al /tmp/mysql

echo "If TEMPTABLE uses memory mapped files"
find /var/lib/mysql/#innodb_temp/ -type f -printf '%s %p\n' | sort -nr | head -n 1

echo "Should be 104857600 /var/lib/mysql/#innodb_temp/temp_9.ibt "



```