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
* Good reads
    * Architecture
        * Multi node, multi region, multi providers
            * https://www.yugabyte.com/blog/multi-region-database-deployment-best-practices/
            * https://www.yugabyte.com/blog/9-techniques-to-build-cloud-native-geo-distributed-sql-apps-with-low-latency/
            * https://docs.yugabyte.com/preview/deploy/multi-dc/3dc-deployment/
	    * https://docs.yugabyte.com/preview/explore/going-beyond-sql/tablespaces/ : table to only specific regions
	    * https://docs.yugabyte.com/preview/explore/ysql-language-features/advanced-features/partitions/ : Partition of a value for a column.
        * Raft
             * https://raft.github.io/
             * https://en.wikipedia.org/wiki/Raft_(algorithm)
             * https://www.yugabyte.com/tech/raft-consensus-algorithm/
             * https://docs.yugabyte.com/preview/architecture/docdb-replication/raft/
             * https://www.yugabyte.com/blog/how-does-the-raft-consensus-based-replication-protocol-work-in-yugabyte-db/
             * https://www.yugabyte.com/blog/low-latency-reads-in-geo-distributed-sql-with-raft-leader-leases/
             * https://docs.yugabyte.com/preview/launch-and-manage/monitor-and-alert/metrics/raft-dst/
        * [Fundamentals of Distributed Transactions](https://docs.yugabyte.com/preview/architecture/transactions/transactions-overview/)
    * Time
        *  https://www.yugabyte.com/blog/evolving-clock-sync-for-distributed-databases/
        * https://www.yugabyte.com/blog/tag/hybrid-logical-clock/
    * Replication
        * https://www.yugabyte.com/blog/data-replication/
        * https://docs.yugabyte.com/preview/architecture/docdb-replication/replication/
        * https://docs.yugabyte.com/preview/explore/change-data-capture/
	* https://docs.yugabyte.com/preview/develop/build-global-apps/
	

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
