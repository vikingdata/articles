
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
* Servers -- yugabyted,  YB-TServers managing the data,  YB-Masters managing the metadata.

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




-------------
YB-TServers (Tablet Servers):
These servers manage the I/O operations of one or more tablets, store data persistently using DocDB (a highly optimized implementation of RocksDB), and replicate data to other servers using Raft. 
YB-Masters (Metadata Servers):
These servers manage cluster metadata, coordinate system-wide operations (like creating, altering, and dropping tables), and initiate maintenance operations like load balancing. 
Data Distribution:
YugabyteDB automatically shards, replicates, and distributes data for dynamic, on-demand scaling. 
Data Placement:
You can use the yugabyted configure data_placement command to set or modify the placement policy of the nodes of the deployed cluster, and specify the preferred region(s). 