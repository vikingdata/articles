---
title : PostgreSQL Schema Inheritance
author : Mark Nielsen
copyright : March 2025
---


PostgreSQL Schema Inheritance
==============================

_**by Mark Nielsen
Original Copyright March 2025**_


---
PostgreSQL : Schema Inheritance
---

* [Links](#links)
* [Slow queries](#slow)
* [Basic info](#basic)
* [schema explained](#s)

* * *
<a name=links>Links</a>
-----
* https://medium.com/@shaileshkumarmishra/find-slow-queries-in-postgresql-42dddafc8a0e

* * *
<a name=slow></a> Slow Queries
-----
The goal is to have postgresql log queries and explain them. 
* config file : /etc/postgresql/17/main/postgresql.conf
    * If your location of config file is different, change the location below.
* As the user "root"
```
echo "" >> /etc/postgresql/17/main/postgresql.conf
echo "
log_min_duration_statement = 1000

# Enable auto_explain module and pg_stat_statements
shared_preload_libraries = 'pg_stat_statements,auto_explain'

# Log slow queries with execution plans
auto_explain.log_min_duration = 1000  
auto_explain.log_analyze = on
auto_explain.log_buffers = on
auto_explain.log_format = text

pg_stat_statements.track = all
pg_stat_statements.max = 10000
track_io_timing = on

logging_collector = on                # Enable capturing of stderr, jsonlog,
                                        # and csvlog into log files. Required
                                        # to be on for csvlogs and jsonlogs.
# These are only used if logging_collector is on:
log_directory = 'log'                  # directory where log files are written,
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'        # log file name pattern,
log_file_mode = 0600                   # creation mode for log files,
log_rotation_age = 1d                  # Automatic rotation of logfiles will
log_rotation_size = 10MB               # Automatic rotation of logfiles will


" >> /etc/postgresql/17/main/postgresql.conf

service postgrelsql restart

```
* As user postgresql inside psql
```

CREATE EXTENSION pg_stat_statements;
```
* See https://www.postgresql.org/docs/current/pgstatstatements.html for sample queries looking at
pg_stat_statements.

* * *
<a name=basic></a> Basic Info
-----


* Find general log file location
```
select name, sourcefile 
  from pg_settings
  where name like '%log%'
    and sourcefile like '%postgresql.conf%';

SHOW data_directory;
sELECT  pg_current_logfile();
```
* show loaded libraries
```
show shared_preload_libraries ;
SELECT current_setting('shared_preload_libraries');
```

* Show processes
```


```

* List table_catalog, table_schema, and tables.
```
-- List catalogs

SELECT distinct table_catalog FROM information_schema.tables;

-- List catalogs and table_schemas

SELECT distinct table_catalog, table_schema FROM information_schema.tables;

-- table_catalog |    table_schema
-- ---------------+--------------------
--  postgres      | public
--  postgres      | pg_catalog
--  postgres      | information_schema

-- List catalogs and table_schemas and table_names

SELECT distinct table_catalog, table_schema, table_name FROM information_schema.tables order by table_catalog, table_schema, table_name;

SELECT table_name FROM information_schema.tables where table_schema = 'public';

SELECT table_name FROM information_schema.tables where table_schema = 'pg_catalog';

```

* Describe tables
```
select column_name, data_type, character_maximum_length, column_default, is_nullable
from INFORMATION_SCHEMA.COLUMNS
where table_catalog = 'postgres'
  and table_schema= 'information_schema'
  and table_name = 'columns';

select column_name, data_type, ordinal_position
from INFORMATION_SCHEMA.COLUMNS
where table_catalog = 'postgres'
  and table_schema= 'information_schema'
  and table_name = 'columns';

```

* Show create table : in Linux
```

pg_dump information_schema -t columns --schema-only

```

* List database
```
\d

 -- or

select datname from pg_catalog.pg_database;


```

* Get any sql from postgresql command
```
psql -E

postgres=# \d
/******** QUERY *********/
SELECT n.nspname as "Schema",
  c.relname as "Name",
  CASE c.relkind WHEN 'r' THEN 'table' WHEN 'v' THEN 'view' WHEN 'm' THEN 'materialized view' WHEN 'i' THEN 'index' WHEN 'S' THEN 'sequence' WHEN 't' THEN 'TOAST table' WHEN 'f' THEN 'foreign table' WHEN 'p' THEN 'partitioned table' WHEN 'I' THEN 'partitioned index' END as "Type",
  pg_catalog.pg_get_userbyid(c.relowner) as "Owner"
FROM pg_catalog.pg_class c
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
     LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam
WHERE c.relkind IN ('r','p','v','m','S','f','')
      AND n.nspname <> 'pg_catalog'
      AND n.nspname !~ '^pg_toast'
      AND n.nspname <> 'information_schema'
  AND pg_catalog.pg_table_is_visible(c.oid)
ORDER BY 1,2;
/************************/

                  List of relations
 Schema |          Name           | Type  |  Owner
--------+-------------------------+-------+----------
 public | pg_stat_statements      | view  | postgres
 public | pg_stat_statements_info | view  | postgres
 public | test1                   | table | postgres
(3 rows)

```

* * *
<a name=s></a> Schema Explained
-----
Whenever you connect to a database, you automatically get 3 table_schemas public, pg_catalog, and information_schema. 
```
postgres=# SELECT distinct table_catalog, table_schema FROM information_schema.tables;
 table_catalog |    table_schema
---------------+--------------------
 postgres      | public
 postgres      | pg_catalog
 postgres      | information_schema

postgres=# \c d1
You are now connected to database "d1" as user "postgres".
d1=# SELECT distinct table_catalog, table_schema FROM information_schema.tables;
 table_catalog |    table_schema
---------------+--------------------
 d1            | public
 d1            | pg_catalog
 d1            | information_schema
(3 rows)
```

* "pg_catalog" is a system catalog. It connects all the databases together.
* "information_schema" contains all the tables and information of this database.
* "public" is where you store the data for the database. 
* Only "public" is writable. The others are read only (except for internal commands that
make changes like "create table".

Here is the confusing part. To create a database you use "create schema". But in information_schema.tables
the database is named "table_catalog". In addition, "table_schema" is used for different schemas in the
database you are in. It can be confusing when "database" and "schema" are used hapzardly. 