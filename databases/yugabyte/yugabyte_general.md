-------
title: Yugabyte tips
--------

# Yugabyte Tips

*by Mark Nielsen*  
* Original Copyright March 2025*


---

1. [Links](#links)

* * *
<a name=links></a>Links
-----
* [PostgreSQL Tips ](B/vikingdata/articles/blob/main/databases/postgresql/pg_general.md)

* * *
<a name=schema></a>Schema

* List tables

```

```

* Table columns

```
select table_name, column_name, data_type,
  character_maximum_length, column_default, is_nullable
from INFORMATION_SCHEMA.COLUMNS
where table_catalog = 'yugabyte'
  and table_schema= 'information_schema'
  and table_name = 'columns'
order by ordinal_position;
```

* * *
<a name=Accounts></a>Accounts


* Accounts table

```
select table_name, column_name, data_type,
  character_maximum_length, column_default, is_nullable
from INFORMATION_SCHEMA.COLUMNS
where table_catalog = 'yugabyte'
  and table_schema= 'pg_catalog'
  and table_name = 'pg_user'
order by ordinal_position;

```

* List accounts
```
SELECT usename AS role_name,
  CASE
     WHEN usesuper AND usecreatedb THEN
	   CAST('superuser, create database' AS pg_catalog.text)
     WHEN usesuper THEN
	    CAST('superuser' AS pg_catalog.text)
     WHEN usecreatedb THEN
	    CAST('create database' AS pg_catalog.text)
     ELSE
	    CAST('' AS pg_catalog.text)
  END role_attributes
FROM pg_catalog.pg_user
ORDER BY role_name desc;

select usename AS role_name, passwd FROM pg_catalog.pg_user;

```
* Update password


* List processes
```
SELECT datname, user, pid, client_addr,  query_start,  state,
  NOW() - query_start AS elapsed, EXTRACT(EPOCH FROM (NOW() - query_start)) as time,
    query
    FROM pg_stat_activity;
```
