
---
title : MySQL causes
author : Mark Nielsen
copyright : September 2024
---


MySQL causes
==============================

_**by Mark Nielsen
Copyright February 2024**_

1. [Links](#links)

* * *
<a name=links></a>Links
-----


* * *
<a name=slow></a>Slow Queries or blocked queries
-----

  large transactions with join that takea long time -- causes lag on slave-- the largest time for a trnasctio\
n causes slave delay because it takes that long on slave,
  backups blocks DDL queries and hence slave in blocked,

* * *
<a name=slow></a>Spike in cpu
-----

* Many long running queries

* * *
<a name=slow></a>Ineffcient Memory
-----

* Innodb buffer pool
* pemalloc not used
* temporary tables
* unidexes queries
* Buffers for join, inserts, etc not set. 

* * *
<a name=slow></a>Spike in IO
-----

* Many quries writing to disk
* Many temporary tables writing to disk. 

* * *
<a name=slow></a>Spike in load
-----

* * *
<a name=slow></a>Other
-----

* Not enough network bandwidth
* Threads cache not able to generate new threads.
* Connection pool not able to keep up.
* Other resources not able to keep up

* * *
<a name=slow></a>Slave lag
-----

* Master runs more queries than slave threads on slave.
* Each write query uses multiple joins and is slow not from the write, but from the joins.
This causes queries on the slaves to take forever.
* Master runs in parallel, but slave only single threaded.
* Inefficient write queries
* Another process blocks replication.
    * Example, a backup with an alter statement in replication.
    * A Query blocks replication : select for update
* The slave runs many intense select queries slowing down the entire system.
* Not enough slave threads.
* Configuration not same as Master in terms if buffer, memory, etc.
* Slave hardware different than Master. 
