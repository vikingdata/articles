-------
title: Yugabyte General
--------

# Yugabyte General

*by Mark Nielsen*  
* Original Copyright March 2025*


---

1. [Links](#links)
2.  [Information](#info)
3. [Common commands][#commands]
4. [Terms and brief hierarchy](#terms)
5. [Brief Explanation)[#brief]
6. [Xcluster](#xcluster)
7. [Important Variables](#var)
8. [Methods](#methods)
9. (Features)(#features)
10. [TODOS](#todos)

* * *
<a name=links></a>Links
-----
* [PostgreSQL Tips ](B/vikingdata/articles/blob/main/databases/postgresql/pg_general.md)
* Good reads
    * Architecture
        * https://www.javacodegeeks.com/quick-guide-to-yugabytedb/
        * https://docs.yugabyte.com/preview/architecture/design-goals/
        * https://docs.yugabyte.com/preview/architecture/key-concepts/
        * https://docs.yugabyte.com/preview/explore/ysql-language-features/
        * Multi node, multi region, multi providers
            * https://www.yugabyte.com/blog/multi-region-database-deployment-best-practices/
            * https://www.yugabyte.com/blog/9-techniques-to-build-cloud-native-geo-distributed-sql-apps-with-low-latency/
            * https://docs.yugabyte.com/preview/deploy/multi-dc/3dc-deployment/
	    * https://docs.yugabyte.com/preview/explore/going-beyond-sql/tablespaces/ : table to only specific regions
	    * https://docs.yugabyte.com/preview/explore/ysql-language-features/advanced-features/partitions/ : Partition of a value for a column.
	    * https://docs.yugabyte.com/preview/explore/ysql-language-features/advanced-features/partitions/ : Look for CAP. Yugabyte focuses on
	    Consistency and Partition over Availability. 
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
	* https://www.yugabyte.com/blog/distributed-database-transactional-consistency-async-standby/
        * https://docs.yugabyte.com/preview/deploy/multi-dc/async-replication/async-transactional-setup-automatic/
           * You must choose single, multi active (bi directional) , or other.
           * We will use single active.
        * https://docs.yugabyte.com/preview/launch-and-manage/monitor-and-alert/xcluster-monitor/

* Performance and server variables
        * https://docs.yugabyte.com/preview/develop/learn/transactions/transactions-performance-ysql/
	* https://docs.yugabyte.com/preview/develop/best-practices-ysql/
        * https://docs.yugabyte.com/preview/explore/query-1-performance/
	* https://docs.yugabyte.com/preview/yugabyte-voyager/reference/performance/
	* https://docs.yugabyte.com/preview/develop/learn/transactions/transactions-performance-ysql/
	* https://www.yugabyte.com/blog/optimizing-yugabytedb-memory-tuning-for-ysql/
	* https://university.yugabyte.com/courses/yugabytedb-ysql-tuning-and-optimization
	* https://forum.yugabyte.com/t/how-to-optimize-yugabytedb-for-better-performance/2771
	* https://docs.yugabyte.com/preview/develop/learn/transactions/transactions-global-apps/
        * https://university.yugabyte.com/courses/take/yugabytedb-ysql-tuning-and-optimization/lessons/42570901-on-demand-video
        * https://www.yugabyte.com/blog/reads-in-yugabytedb-tuning-consistency-latency-and-fault-tolerance/
        * https://forum.yugabyte.com/t/optimizing-query-performance-in-yugabytedb/4167
        * https://www.youtube.com/watch?v=AV7lm_5j-I0
        * https://www.yugabyte.com/blog/yugabytedb-cost-based-optimizer/
        * https://www.developerscoffee.com/blog/maximising-postgresql-efficiency-in-yugabyte-best-practices-for-distributed-databases/
        * Reference
            * https://docs.yugabyte.com/preview/reference/configuration/
            * https://docs.yugabyte.com/preview/reference/configuration/yb-tserver/
            * https://docs.yugabyte.com/preview/reference/configuration/
            * https://docs.yugabyte.com/preview/reference/configuration/yugabyted/
    * Schema
        * https://airbyte.com/data-engineering-resources/create-database-schema-in-postgresql#:~:text=A%20schema%20can%20also%20include,organize%20large%20and%20complex%20databases.
        * Default schemas
	    * pg_toast :https://medium.com/quadcode-life/toast-tables-in-postgresql-99e3403ed29b
	        * https://medium.com/quadcode-life/structure-of-heap-table-in-postgresql-d44c94332052
                * https://wiki.postgresql.org/wiki/TOAST
	    * public: The default location of your data.
	    * pg_catalog and information_schema:
	        * https://docs.yugabyte.com/preview/architecture/system-catalog/
            * schema path : When in a database, when you use a table, it looks through
	    the schema path which contains a list of schemas in your current database. This can
	    be overridden by specifying the schema in the query. 
	        * https://yugabytedb.tips/set-schema-search-path/
		* https://www.postgresql.org/docs/17/ddl-schemas.html#DDL-SCHEMAS-PATH
            * https://www.postgresql.org/docs/current/views.html		
* Comparisons and Opinions. 
        * https://www.yugabyte.com/blog/comparing-the-maximum-availability-of-yugabytedb-and-oracle-database/
        * https://fritshoogland.wordpress.com/2021/03/17/my-reasons-for-moving-to-yugabyte/
        * https://dev.to/yugabyte/which-postgresql-problems-are-solved-with-yugabytedb-2gm
        * https://www.yugabyte.com/blog/yugabytedb-resiliency-vs-postgresql-ha-solutions/

* * *
<a name=info></a>Information
--------

### Schema
Links
* https://www.postgresql.org/docs/current/manage-ag-templatedbs.html
* https://docs.yugabyte.com/preview/architecture/system-catalog/
* https://airbyte.com/data-engineering-resources/create-database-schema-in-postgresql#:~:text=A%20schema%20can%20also%20include,organize%20large%20and%20complex%20databases.

* First list databases, then connect to each database, and then list schema for each database. You cannot
query a database from another database.
* There are 5 database by default, unless you make more. 
   * template0 : Used as a template for making new databases. However, you
   should never add anything to this, as it is a pristine database.
   will be copied for new databases. 
   * template1 : By default, new databases will copy everything in here.
   * postgres : For postgresql, the default database. In yugabyte, it is
   empty.
   database holding data.
   * yugabyte : The default database. Unless you make others, this is your
   database holding data.
   * system_platform : Empty by default. 

* Each database has 3 schemas
   * public : Default that holds data.
   * pg_catalog : system catalog about database and more.
   * information_schema : Has views into pg_catalog. 
* List tables : The only database you initially are concerned about is
    yugabyte. 
    * In each database : 

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
### Accounts

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

* Like system variables
```
select * from pg_settings;
SELECT name, setting FROM pg_settings;

```
* Location Information
    * cloud, region, zone, node level
    * yb-ctl status
    * Or sql commands
```
select yb_servers();
select yb_server_cloud(), yb_server_region(), yb_server_zone();
```

* * *
<a name=commands></a>Common Commands
--------
* Restarting yugabyte
```
wget  --no-cache https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main/databases/yugabyte/yugabyte_general_files/restart_yugabyte.sh  -O restart_yugabyte.sh

chmod 755 restart_yugabyte.sh
./restart_yugabyte.sh 

```


* * *
<a name=terms></a>Terms and brief hierarchy
-----
* Nodes - VMs, machines, or containers
* Universe/Cluster -- a group of nodes that forms the entire database.
* Keyspace - The database
* Tablet - Table are split into tablets (shards) across nodes.
  The data on a node(s) for a table is a tablet.  
* Read Replica
* Synchronous Replication -- inside the primary cluster or bidirectional with
a backup cluster.
* Asynchronous replication -- goes to a read replica cluster. 
* RAFT -- failover by consensus
    * Raft leader -- the node that is the leader of a tablet
    * RAFT Followers -- the other nodes of a tablet
* Hybrid clock
    * https://www.yugabyte.com/blog/evolving-clock-sync-for-distributed-databases/
    * ee
* Transactions
    *  
* Services
    * Y-master
    * y-server
    * yugabyted


* Data Flow 2
    * YB-TServer: responsible for managing one or more tablets, which contain the actual data. DocDB is the storage engine used by the YB-TServer to store and manage the data persistently

       * Gets all client connections
       * serves data
       * Holds data in tablets
       * Gives DDL queries to YB-master???
       * Has Doc DB which  : manages replication, and storage
           * Query layer : Parse, Analyze, Rewrite, Execute
	   * Storage Layer
    * YB-Master :  The YB-Master manages the cluster metadata, including information about tablets and their locations. This metadata is stored in an internal table within DocDB. 
        * Stores meta data (how the data is stored. 
        * Performs DDL
        * data balances across nodes.
        * Performs failover for tablets (usually entire nodes)
            * Uses Raft : Uses consensus for failovers.
        * Manages the data.
        * Load balancing
        * Responsible for background operations.
    * DocDB storage engine is used by both YB-Tserver and YB-Master
        * YB-Master uses it to store system metadata,
        * YB-Server uses it for storing and managing data. 
    * Replication in cluster
        * Fault Tolerance FT is the number of nodes that can fail and
	  data is okay.
	* Replication Factor RF are the numbers of nodes for each tablet.
	* To achieve FT of k nodes allowed to fail: RF = (2k + 1)
             * If you allow 1 node to fail, you need at least 3 nodes. For
	     2 nodes to fail, you need 5 nodes.
        * If you have 7 nodes, and 5 copies of data -- how do you spread
        the tablets out?
    * XCluster, Read Replicas, Geo partitioned
        * Geo Partitioned : Data or tables are located in specific regions.
        * Read Replicas : Cluster replicates to a Read Only Cluster.
	* XCluster: Unidirectional or Bidirectional
            * Both can do failovers.
            * Uni means only Primary does writes. Bi means both.
        * Standby 
* High level overview
    * Query Layer
        * query, tun-time commands, statement cache, parser and executor,
        YSQl or YCSQL or client drivers
    
* * *
<a name=rief></a>Brief Explanation
-----
* Schema hierarchy
   * A server as a list of databases.
       * The default is "yugabyte" which you
   will hold you default data.
       * There are 4 other default databases. They are not normally used. 
           * template0 : Used as a template for making new databases. However, you
   should never add anything to this, as it is a pristine database.
           * template1 : By default, new databases will copy everything in here.
           * postgres : For postgresql, the default database. In yugabyte, it is empty.
           * yugabyte : The default database. Unless you make others, this is your
              database holding data.
           * system_platform : Empty by default.
       * You can make new databases.
       * Data in a database cannot be accessed when in another database.
   * Each database has schemas.
       * The 4 default schemas
           * "public" is your default database containing data.
           * pg_catalog lists information about the current database, server,
       and other       databases.
           * information_schema has views into pg_catalog.
           * pg_toast : A database of heap tables that copy
           itself from the public databases. They are
           temporary tables used for internal use.
       * You can create more schemas inside a database.
       * You can access data from other schemas in your database.
       * When you try to do something to a table or other object, it
       will use your search path of schemas to find the table. 
   * Each schema has data, tables, views, and other stuff.

* * *
<a name=xcluster></a>Xcluster
-----
Links
* https://www.youtube.com/watch?v=q6Yq4xlj-wk
* https://university.yugabyte.com/courses/take/yugabytedb-anywhere-operations-xcluster-replication/lessons/49623195-asynchronous-replication

* Xcluster allows Cluster replication between two universes (database).
   * Default Option
       * Multi region: High latency, but other than that like local replication       * Synchronous, like local replication.
   * Geo Partitioned -- only data that is partitioned to a region. 
       * Data is kept in a region.
       * For data kept within a region, latency goes away.
       * Does NOT include global data.
       * Synchronous inside region.
   * Read Replicas -- copy to another cluster
       * Entire Cluster is replicating asynchronously to another Cluster.
       * Low latency.
       * Delayed replication.
       * No Failover
       * No writes.
   * Xcluster deployment -- copy to another cluster
       * Unidirectional or Bidirectional
       * Asynchronous replication.
       * Failover options.
       * Low latency
       * Active-Active, either single master or multi-master. Single
       means only one universe does writes. Bidirectional is both.
       * For unidirectional
           * Schema changes do not automatically happen. Need to do schema changes in both areas.
           * TODO: Design schema changes. 2. Are schema changes transactional like postgresql?
           * Make all schema changes backwards compatible. 
       * For Bidirectional
           * Schema must be done manual.
           * Again, make it backwards compatible.
           * TODO: Design schema change and verify DDL is transactional.
* * *
<a name=var></a>Important Variables
-----
* postgresql docs
    * Enviromental variables: https://www.postgresql.org/docs/current/libpq-envars.html
    * Varibles in SQL :
        * https://www.geeksforgeeks.org/postgresql-variables/
        * https://www.postgresql.org/docs/current/plpgsql-declarations.html
    * pg_settings
        * https://www.postgresql.org/docs/current/view-pg-settings.html	
        * https://www.postgresql.org/docs/current/runtime-config.html
* Yugabyte
    * https://docs.yugabyte.com/preview/reference/configuration/

* Y-tserver
* y-Master
* Performance
    * ROWS_PER_TRANSACTION
    * ysql_session_max_batch_size
    * ysql_max_in_flight_ops
    * [t]server_tcmalloc_max_total_thread_cache_bytes
* dc_wal_retention_time_secs


* * *
<a name=todo></a>TODOS
-----
* Setup various Replications
    * Read Replicas, Geo Partitioned, Uni and Bi Xcluster.
    * Add tables, indexes. Involves manual changes, add to replication,
     and bootstrap replication.
    * Perform failovers to Xcluster while data is running.
    * Perform outage, and then failover for apps to new cluster.
        * Does Uni failover redirect connections to new universe?
    * Perform a schema change on primary, insert data. Error should occur on
    standby cluster. Do DDL on standby and reset replication.
* Comparisons and  other
    * Show processes on node, tablet. cluster
    * Xcluster: Compare tables and schema. Example: table deleted in primary. Or in BI, deleted only on one side and other side
    does an insert.
    * Xcluster for Bi: Restore deleted table on deleted side and remake replication.
* Anywhere
    * Install locally
    * Get region and other info for yugabyte anywhere.


* * *
<a name=Methods></a>Methods
-----
* Add server
* Remove Server
* Change RF
* Backup
* Restore and add to cluster
* Xcluster
    * Read Replicas
    * Uni
    * Bi
    * Failover
* Repair failed node
* Internal Node failover
* Change default schema for a user.
* Create and use, database, schema.


* * *
<a name=Features></a>Features
-----
* Links
    * https://www.infoworld.com/article/2335181/the-9-most-important-new-features-in-yugabytedb.html
    * https://docs.yugabyte.com/preview/explore/ysql-language-features/
* Goals : https://docs.yugabyte.com/preview/architecture/design-goals/
    * scalability
    * High Availbility
    * Single-row linearizability
    * Multi-row ACID transactions
    * Partition Tolerance - CAP
    * Data distribution
    * Load Balancing
    * And others including auto failovers, data balancing, etc. 

* Architecture
    * Failover
    * Load balancing
    * Data balancing
    * Geo partutioned
    * Tables
        * Geo
        * Partitioned by has or range by region or geo.
    * Different Clusters
        * Read Replicas
        * Uni directional Xcluster
        * Bi directional Xcluster
    * ACID
    * CP in CAP thereom.
* PostgreSQL compatibility and SQL
    * Materialized Views