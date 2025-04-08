
title : Architecture Yugabyte
author : Mark Nielsen
copyright : March 2025
---


 Architecture Yugabyte
==============================

_**by Mark Nielsen
Original Copyright March 2025**_

Sections
* [Links](#links)
* Use (service plus installation)
* Connections
* Data (insert, update, delete)
* Engine - RocksDB
* Transaction
* Replication, Cluster, Distribution - HLC, RAFT, NTP
* Engine
* Overall Architecture
* Server types
* * *
<a name=l></a>Links
-----

* General Docs
    * https://www.yugabyte.com/distributed-sql/
    * https://docs.yugabyte.com/preview/architecture/
    * https://www.yugabyte.com/blog/distributed-sql-yugabytedb-two-layer-architecture/
    * Youtube
        * https://youtu.be/5wWcQHmmIcs
	
* * *
<a name=y></a>Yugabyte
-----

* * *
<a name=r></a>Replication, Cluster, Distribution - HLC, RAFT, NTP
-----
Terms
* HLC -- hybrid logical clock 
* NTP -- Network Time Protocol
* RAFT-- cluster consensus (monotonic)

* * *
<a name=o></a>Overall Architecture
-----
There are two layers
* Yugabyte Query Layer (YQL)
* DocDB  -- handles storage, transaction, distribution of data
* Servers -- yugabyted,  YB-TServers managing the data,  YB-Masters managing the metadata, ui.



#### DocDb
Links
* https://docs.yugabyte.com/preview/architecture/docdb-sharding/
    * https://docs.yugabyte.com/preview/architecture/docdb-sharding/sharding/
    * https://docs.yugabyte.com/preview/architecture/docdb-sharding/tablet-splitting/
* https://docs.yugabyte.com/preview/architecture/docdb-replication/
* https://docs.yugabyte.com/preview/architecture/transactions/
* https://docs.yugabyte.com/preview/architecture/yb-master/
* https://docs.yugabyte.com/preview/architecture/yb-tserver/

* Stores key/pair
* Data is stored synchronous
* Replication with no data loss.
* Many things are handled upstream (explain)
* Sharding
    * HASH sharding
    * Range sharding
    * Tables split into tablets
        * Can be split with pre-splits, manually, or automatic
	* Good splitting to prevents hot spots and
* Underlying engine is based on PostgreSQL and RocksDB

#### Servers
-------------
Links
* UI : https://www.youtube.com/watch?v=fEm1ArpeFpk

* YB-TServers (Tablet Servers): https://docs.yugabyte.com/preview/architecture/yb-tserver/

 T hese servers manage the I/O operations of one or more tablets, store data persistently using DocDB (a highly optimized implementation of RocksDB), and replicate data to other servers using Raft.
 It handles requests of users and also background actions such as: tODO

* YB-Masters (Metadata Servers): https://docs.yugabyte.com/preview/architecture/yb-master/

These servers manage cluster metadata, coordinate system-wide operations (like creating, altering, and dropping tables), and initiate maintenance operations like load balancing.

* YugabyteDB automatically shards, replicates, and distributes data for dynamic, on-demand scaling.
  You can use the yugabyted configure data_placement command to set or modify the placement policy of the nodes of the
   deployed cluster, and specify the preferred region(s).

* UI

* * *
<a name=c></a>Capanbilities
-----
#### CAP

#### Replication
*  Synchronous : https://docs.yugabyte.com/preview/architecture/docdb-replication/replication/


* Asynchronous : https://docs.yugabyte.com/preview/architecture/docdb-replication/async-replication/

Yugabyte has asynchronous replication capabilities. Why? Well it is used for entire replicate of data from one cluster to
another. If cluster to cluster replication was synchronous, a write query in Cluster 1 would have to wait for the
same query to finish in Cluster 2 before it can return to the software and say it has been comitted.
If Cluster 2 is not available or is very slow because of network or local performance problems, this can severly
hurt the query speed in Cluster 1 (because Cluster 1 has to wait).

In addition, you can set it up to write only to one cluster or to both at the same time. 

To help decide how you will use the target cluster, two modes are available:
* Non-transactional replication: "Writes are allowed on the target universe,
but reads of recently replicated data can be inconsistent." This means, writes will happen as fast as thy can be applied,
but the target cluster will always behind the source cluster. This means if you open connections to the source and
target clusters and run the same query, the target cluster response and data may be a little out of data
and not the same as the source cluster. In this scenario, you can write to both clusters.
* Transactional replication: "Consistency of reads is preserved on the target universe, but writes are not allowed."


#### Sharding


####Load Balancing

#### High Availability

#### Transactions