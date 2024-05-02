 
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
* set numa=off

* * *
<a name=m>Mongo Config</a>
-----
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
   directoryPerDB: true
operationProfiling:
   mode: slowOp
   slowOpThresholdMs: 100
replication
   oplogSizeMB : 1000
   replSetName
```
* AWS
* readahead
   * On /sbin/blockdev --setra 8192 /dev/sda
       * Change sda to partition mongo is mounted on. 
* Percona Mongo features, which are free compared to Enterprise Mongo

* * *
<a name=t>Tools</a>
-----
Tools

* Grafana
* New Relic or Solar Winds
* PMM
* slow query analysis
* Percona tools
   * pt-diskstats
   * pt-mongodb-query-digest
   * pt-mongodb-summary
   * pt-summary

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

