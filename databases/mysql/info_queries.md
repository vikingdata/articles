
---
title : MySQL Info queries
author : Mark Nielsen
copyright : Feb 2021 to Sept 2023
---


MySL Info queries
==============================

_**by Mark Nielsen
Original Copyright Feb 2021**_

This article will grow over time. 

TODO: simple performance_shema queries, information_schema queries

1. [table files](#files)
2. [InnooDB buffer pool ratio](#ibpr)
3. [Size of database/tables](#size)
4. [No index](#noindex)
5. [Busiest tables](#busy)
6. [Unused indexes](#unused)
7. [List stored procedures, functions, triggers](#list1)

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

<a name=ibpr></a>InnooDB buffer pool ratio
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

<a name=size></a>Size of database and tables
-----

```sql
set @gig = 1024*1024*1024;
set @meg = 1024*1024;
select @meg, @gig;

SELECT table_schema 
        , ROUND(SUM(data_length + index_length) / @meg, 2)  as db_size_in_meg 
	, ROUND(SUM(data_length + index_length) / @gig, 2)  as db_size_in_gig
FROM information_schema.tables 
GROUP BY table_schema
order by db_size_in_meg desc
limit 10;

-- largest tables

set @gig = 1024*1024*1024;
set @meg = 1024*1024;
select @meg, @gig;

SELECT table_schema, table_name
        , ROUND(SUM(data_length + index_length) / @meg, 2)  as db_size_in_meg
        , ROUND(SUM(data_length + index_length) / @gig, 2)  as db_size_in_gig
FROM information_schema.tables
GROUP BY table_schema, table_name
order by db_size_in_meg desc
limit 10;

-- size of database and earliest table

SELECT table_schema 
	, ROUND(SUM(data_length + index_length) / @gig, 2)  as db_size_in_gig
	, MIN(create_time) AS min_reation_time_table
FROM information_schema.tables 
GROUP BY table_schema
order by db_size_in_gig desc
limit 10;


SELECT table_schema
        , ROUND(SUM(data_length + index_length) / @gig, 2)  as db_size_in_gig
        , MIN(create_time) AS min_reation_time_table
FROM information_schema.tables
where table_schema in ('<DB>')
GROUP BY table_schema
order by db_size_in_gig desc
limit 10;


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

* stored procedures and functions. amd triggers
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