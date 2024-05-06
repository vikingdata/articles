 
---
title : MySQL Variables
author : Mark Nielsen  
copyright : May 2024  
---


MongoDB Variables
==============================

_**by Mark Nielsen
Original Copyright May 2024**_


NOTE: This article is always in progress.

1. [Links](#links)
2. [Server Configuration](#s)
3. [Client Configuration](#c)
4. [Replication](#r)
5. [ClusterSet](#cluster)
6. [Other](#other)

* * *
<a name=Links></a>Links
-----

* * *
<a name=s>Server Configuration</a>
-----
* server-id : Used to identify a server in replication or cluster. You should always have it.
* report-host : Name of the server. Again, you should always have this.

Optimization Important Variables
*  table_cache
    * SHOW OPEN TABLES : shows currently opened tables.
    * SHOW OPENED TABLES : If this value is large, your table cache may be too small.
    * Also count how may tables you have. 
        * group by database ```
select count(1), table_schema
  from INFORMATION_SCHEMA.TABLES
  where table_schema not in ('mysql','information_schema','performance_schema','sys')
  group by table_schema;
```
       * or total ```
select count(1)
  from INFORMATION_SCHEMA.TABLES
  where table_schema not in ('mysql','information_schema','performance_schema','sys');
```

Less important variables

*  max_connections   : Monitor max connections. If you need more, it is can be set dynamically. 
*  wait_timeout      : Unless you have long running queries, rarely you need to afjust his. This can be specified per session if needed. 
*  thread_cache_size : Monitor. It is reaches to a low amount, increase it. It can be set dynamically. 
*  key_buffer_size   : Only for MyISAM. Nobody uses it. 
*  query_cache_size  : Nobody uses this. Cache in redis or other caching before MySQL is hit. 
*  tmp_table_size, max_heap_table_size, and temptable_max_mmap   : For tables that are created im memory, if you analyze the slow log and you see a lot of temporary tables made and hitting disk, you may want to increase this. You can use Analyze Explain on slow queries to see if they mention "using filesort ; using temporary tables". Filesort just means a table
was made for sorting, but it might not have hit disk. Using temporary tables also means a temporary table was created but it might not have hit disk/. 

* * *
<a name=c>Client settings</a>
-----



* * *
<a name=s>Replication</a>
-----


* * *
<a name=s>Clusterset</a>
-----


* * *
<a name=o>Other</a>
-----
