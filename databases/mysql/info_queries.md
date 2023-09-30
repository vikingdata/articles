
---
title : DBT install  CLI and Adapters
author : Mark Nielsen
copyright : Feb 2021 to Sept 2023
---


MySL Info queries
==============================

_**by Mark Nielsen
Original Copyright Feb 2021**_

This article will grow over time. 

1. [table files](#files)
2. [InnooDB buffer pool ratio](#ibpr)
3. [Size of database/tables](#size)

* * *

<a name=files></a>files
-----

This tell you if a table is in its own tablespac, general tablespace, or system tablespace.
  https://dev.mysql.com/doc/refman/8.0/en/general-tablespaces.html


```sql

mysql> select FILE_ID, FILE_NAME, FILE_TYPE, TABLESPACE_NAME
 from INFORMATION_SCHEMA.files;
```

* * *

<a name=ibfr></a>InnooDB buffer pool ratio
-----

This tell how efficient read queries are getting data from memory and not disk.

```aql

100 - (100 * innodb_pages_read / innodb_buffer_pool_read_requests)

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




```