 
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
* Compress data on disk : blockCompressor. Saves diskspace, uses more cpu, less I/O
** operationProfiling:    mode: slowOp,    slowOpThresholdMs: 100
    * Trn on profling. Detect slow queries. Bad queries can affectt performance and other queirs. 
* net:   compressors : snappy
    * Make communication compressed. 
* Set threads
    * setParameter:  wiredTigerEngineRuntimeConfig: eviction=(threads_min=6,threads_max=12)
       * Sets eviction threads. Eviction removes data from memory.
    * read and write by default mongodb auto scales.

Per Connection
* Set max execution time
*

* * *
<a name=s>Replica</a>
-----
* arbiterOnly : A member with no data. Primarily used in keeping a cluster up. Counts as a single server being up. 
* hidden member in a replica must have priority 0. They can still participate in votes for other memebers when there is  failover.
   * Hidden to applciations.
       * Unless you diretly connect to it.
   * Won't respond to read concerns.
   * Will respond to write concerns if ts defined as a number of servers. It will not respond when write concern it majority ( no voting). 
* Priority : If 0, cannot become primary and cannot trigger elections. Higher priority will give the member a more likely chance to become primary in a failover. 
* read concern : Secondaries respond to read queries when a certain numbers of servers have commited hte data. 
* read prioerity
* write concern : How many secondaries have comitted the data before the primary returns a response to the application. 
* rite proocity
* Votes -- no of votes a server will cast in an election. Members have 0 or 1. Arbiters have 1. If you have priority > 0 it must be one. This is confusing.
* secondaryDelaySecs : How many seconds this member is behind the primary.
# tags : Used for read and write preferences. 

      replication:
         verbosity: <int>
         election:
            verbosity: <int>
         heartbeats:
            verbosity: <int>
         initialSync:
            verbosity: <int>
         rollback:
            verbosity: <int>

* * *
<a name=s>Shards</a>
-----
