 
---
title : MongoDB Variables
author : Mark Nielsen  
copyright : May 2024  
---


MongoDB Variables
==============================

_**by Mark Nielsen
Original Copyright May 2024**_


NOTE: This article is always in progress.

1. [Links](#links)
2. Configuration
3. Replica
4. Sharding

* * *
<a name=Links></a>Links
-----

* * *
<a name=c>Configuration</a>
-----
* cacheSizeGB : Set the cache size. Memory is faster than disk.
* directoryForIndexes : With RAID, IO and be spread across drives.
* directoryPerDB : Have one directory per database. 
*  blockCompressor : Compress data on disk. Saves diskspace, uses more cpu, less I/O
* operationProfiling:    mode: slowOp,    slowOpThresholdMs: 100
    * Turn on profiling. Detect slow queries. Bad queries can affect performance and other queries. 
* net:   compressors : snappy : Make communication compressed. 
* Set threads
    * setParameter:  wiredTigerEngineRuntimeConfig: eviction=(threads_min=6,threads_max=12)
       * Sets eviction threads. Eviction removes data from memory.
    * read and write by default mongodb auto scales.
* oplogSizeMB -- stores commands executed in memory. This is used for Replica Sets.
    * Comments, if the oplog is too small. Backups may not work as the latest command has to be before the time of backup.
       * Set the oplog size.
       * Also set the no of hours to hold onto queries. oplogMinRetentionHours
       * To calculate the size of oplog
           * Set hours
	   * Wait 24 hours and monitor oplog size. 
	   * Run ``` use local; local.oplog.rs.stats().totalSize ```
	   * In megabytes ``` use local; db.oplog.rs.stats({scale: 1024*1024} ).totalSize ```
           * With hours set, you don't need to set the size, but you can.  

Per Connection
* Set max execution time
*

* * *
<a name=s>Replica</a>
-----
* arbiterOnly : A member with no data. Primarily used in keeping a cluster up. Counts as a single server being up. 
* hidden :  member in a replica must have priority 0. They can still participate in votes for other members when there is  failover.
   * Hidden to applications.
       * Unless you directly connect to it.
   * Won't respond to read concerns.
   * Will respond to write concerns if ts defined as a number of servers. It will not respond when write concern it majority ( no voting). 
* Priority : If 0, cannot become primary and cannot trigger elections. Higher priority will give the member a more likely chance to become primary in a failover. 
* Votes -- no of votes a server will cast in an election. Members have 0 or 1. Arbiters have 1. If you have priority > 0 it must be one. This is confusing.
* secondaryDelaySecs : How many seconds this member is behind the primary.
* tags : Used for read and write preferences.


Connection settings affected by replica set or shards. 

* read concern : Secondaries respond to read queries. When a certain numbers of servers have committed data for the to occur. Basically a majority of servers have committed data being read.  
    * local -- from any node, no promise data has been written to a majority of nodes. With sharded, it communicates with primary or config servers to filter out data that has been orphaned. 
    * available -- same as local with unsharded collections. With sharded collections it doesn't wait for consistency checks from servers it asks data for. Thus my return orphaned data.
    The purpose is to allow a return even with possible errors -- faster response. 
    * majority -- a majority of servers written the most recent data.
    * linearizable -- all majority acknowledged writes have finished. It forces a check on the primary to as for write concern of majority to the secondaries. In the event of a failover,
    it forces the Primary to request a write concern majority of the secondaries. If it can't, it isn't the "true" primary. 
    * snapshot - for shards. 
    * Comments
        * local and available -- local requires more overhead as it communicates with primary or config servers if data has been moved. Local is more accurate than linearizable. 
        * majority and linearizable -- linearizable is more overhead and is requires the primary to have a majority write concern at start of read. linearizable has more overhead but
    can be more accurate if in the middle of a failover.
        * During a failover, The OLD primary thinks all secondaries and written the data. If you connect the OLD primary, data can be returned with a read concern majority because the
	OLD primary doesn't realize a failover has occurred. linearizable forces the primary to check a write concern with each secondary which the OLD primary cannot do.
        * In non-sharded environments, local and available are the same.
	* In non-failover situations, majority and linearizable are the same. 
* read preferences
    * primary -- primary only
    * primaryPreferred -- will try the primary, but it may come from a secondary if primary is not available.
    * secondary -- secondaries only
    * secondaryPreferred  -- secondary -- but will use primary if there are no secondaries.
    * nearest -- calculates based on latency threshold of servers and uses tags.
    * Comments: For mongos (shards), with Hedged reads, multiple queries are sent to secondaries and use the first one that responds. Can only be used with non-primary read priority. 
    
* write concern : How many secondaries have committed the data before the primary returns a response to the application. 
    * Unacknowledged -- same as ignore errors.
    * Acknowledged -- written to primary. Could be just in memory. Not journal or disk.
    * Journaled -- confirmed to disk. In event of crash, data is recoverable. 
    * Replica Acknowledged -- Replica set confirms data has been written.
        * 1 is the primary only
        * greater than  1 includes primary. Waits till X servers have committed data.
        * Majority -- a majority of servers have committed data.
        * Comments
            * getLastError has an "fsync" option, that data must be synced to Primary (not just Journaled)


* * *
<a name=s>Shards</a>
-----
