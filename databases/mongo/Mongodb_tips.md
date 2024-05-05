 
---
title : MongoDB Tips
author : Mark Nielsen  
copyright : April 2024  
---


MongoDB Tips
==============================

_**by Mark Nielsen
Original Copyright April 2024**_


NOTE: This article is always in progress.

1. [Links](#links)

* * *
<a name=Links></a>Links
-----
* [Replication status](https://www.mongodb.com/docs/v6.0/reference/method/rs.status/)
    * [How to check MongoDB replication status](https://www.dragonflydb.io/faq/how-to-check-mongodb-replication-status)
* https://docs.percona.com/percona-server-for-mongodb/4.4/rate-limit.html#enabling-the-rate-limit
* https://amperecomputing.com/tuning-guides/mongoDB-tuning-guide
* https://kevcodez.medium.com/mongodb-performance-guide-9121dff56cd1
* https://severalnines.com/blog/performance-cheat-sheet-mongodb/

* * *
<a name=os>Operating system config</a>
-----
* Turn off Transparent HugePages
* Swap
    * Set Swapiness to 0
        * Ubuntu : In /etc/sysctl.conf
            * vm.swappiness = 0
    * Make sure you have swapspace. It is for emergencies.
    * Monitor swap, if it gets over 25%, send alarm.
* Change Disk I/O Scheduler  to deadline
* set numactl --interleave
* /etc/sysclt.conf
```
vm.max_map_count = 98000
kernel.pid_max = 64000
vm.swappiness = 0
kernel.threads-max = 64000
vm.max_map_count=128000
net.core.somaxconn=65535
```
* tuned-adm profile throughput-performance

* * *
<a name=m>Mongo Config</a>
-----
* Use XFS over EXT4
* Disable access times
* Always setup replica set and shard your single replica set right away. 
* Wired Tiger strange options
    * Turn on various options
        * Set the cache size if needed: cacheSizeGB
	* Have directory for indexes : directoryForIndexes
	* Have one directory per database : directoryPerDB
    *
```
storage:
   wiredTiger:
       engineConfig:
           cacheSizeGB: 0.25
           directoryForIndexes: true
           compressors=snappy
       collectionConfig:
         blockCompressor: 
   directoryPerDB: true
operationProfiling:
   mode: slowOp
   slowOpThresholdMs: 100
replication
   oplogSizeMB : 1000
   replSetName
net:
   compressors : snappy

TODO eviction threads set to 8
  concurrent write and read transactions
  

```
* AWS -- advantage on large systems
* readahead
   * On /sbin/blockdev --setra 8192 /dev/sda
       * Change sda to partition mongo is mounted on. 
* Percona Mongo features, which are free compared to Enterprise Mongo
* Replica sets
   * Use hidden servers for backups or apps. These servers will not become primary. 
* sharding
    * Always use replica sets
    * Always have shard to put documents onto older than X time.
* Connection pooling

* * *
<a name=u>Using Mongo </a>
-----
* Set max execution time
* Run explain on queries
* Avoid sorts
* Use filter on Pipeline to reduce no of documents.
* Use indexes : 
   * [The ESR Equality, Sort, Range Rule](https://www.mongodb.com/docs/manual/tutorial/equality-sort-range-rule/)
* Drop unuse Indexes
* Drop indexes that cover same fields.
* Insertmany or Blkwrite when possible.


* * *
<a name=t>Tools</a>
-----
Tools

* Grafana
* New Relic or Solar Winds
* PMM
* slow query analysis
* Mongo Compass
    * explain plan
* Percona tools
    * pt-diskstats
    * pt-mongodb-query-digest
    * pt-mongodb-summary
    * pt-summary
* Free monioring
    * db.enableFreeMonitoring()
    * You will be given a url to monitor mongo
* Free monitoring with [New Relic.](https://newrelic.com/pricing/free-tier)
    https://docs.newrelic.com/docs/infrastructure/host-integrations/host-integrations-list/mongodb/mongodb-monitoring-integration-new/

* * *
<a name=c>Check for</a>
-----
Checks

* Do you have backups? Mongodump or hot backups? Do you need incremental backups. 
* Unused Indexes
* Mutiple Indexes covering the same fields
* Is Query Profiler turned on


* * *
<a name=u>Usefull Queries and Commands</a>
-----
* Replica Status
    * start mongosh or mongo
        * enter: rs.status()
    * Check replica
        * ``` mongo --eval "rs.status()" | egrep "name:|state:|uptime:|health:|stateStr:" ```
    * Check replica configuration for all servers in replica set
        * ``` mongo --port 30001 --eval "rs.conf()" | egrep "_id:|arbiterOnly:|hidden:|priority:|votes:"```
* Shard
* Slow queries
* Sharding
* Database stats
* Document stats
* Locks
    * db.serverStatus().globalLock
    * db.serverStatus().locks
* Query explain 