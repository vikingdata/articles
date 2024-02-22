
---
title : MySQL speeddup
author : Mark Nielsen
copyright : February 2024
---


MySQL Speedup
==============================

_**by Mark Nielsen
Copyright February 2024**_

1. [Links](#links)

* * *
<a name=links></a>Links
-----

* (severalnines MySQL Performance Cheat Sheet)[https://severalnines.com/blog/mysql-performance-cheat-sheet/]


* * *
<a name=variables></a>Variables
-----

```text
explain analyze TABLES on slow queries
   * have tables with appropriate indexoing

applications should
	     1. not select many rows
	     2. If a large amount of rows is required, see if you can loop through them. 

On Slaves, turn off binlog, and when caught up, turn it back on. Turning it off and on will require a restart of mysql and check slave is running when it restarts or turn slave back on

slow queries
     pt-digest
     internal tools

Use table partitioning for big tables

Separate tables into separate databases where each database has a purpose. You can then have mutiple slave threads. 


Variables
	innodb_buffer_pool_size -- One of the most important variables. You want to have its size equal to all the hot data being updated or selected.
	innodb-buffer-pool-instances -- take total buffer_pool_size, divide buffer pool size by 1 Gig, and that's how
				     many pool instances you should have. The advantage of using pool-instances
				     is locks on the buffer pool is divided into chucks of the buffer pool.
				     TODO: better explanation for this.
	buffers : read, join
	threads: purge, io threads, etc
	sync_binlog -- setting to 0 will improve speed but reduce ACID
 	raage_optimizer_max_mem_size -- if too small, it will result in full tables scans, which is horrible for large tables.
	binlog file size -- get 8.0 settings
	undo logs -- for 8.0


	thread_pool
	tempoary table size: check for 8.0 : max_heap_table_size, tmp_table_size -- changed in 8.0
	innodb_flush_log_at_trx_commit -- check on 8.0
	innodb_flush_method
	table_open_cache =- compare size to no of tabeles, open connections, and global statsu variable.
	table_open_cache_instances -- little userful, 8 or more instances for DML
	table_definition_cache
	max_allowed_packet -- if you get app error, or replication errors
	skip_name_resolve
	thread_cache_size

	innodb_autoinc_lock_mode -- for many inserts
	innodb_io_capacity / innodb_io_capacity_max

	innodb_log_file_size - check 8.0
	innodb_log_buffer_size -- check 8.0
	innodb_thread_concurrency
	innodb_flush_log_at_trx_commit -- check 8.0
	innodb_flush_log_at_trx_commit
	innodb_adaptive_flushing -- check percons and community versions
	

Monitor
	swapspace use
	innodb buffer pool ratio
	tables with unused indexes
	slow logs
	temp tables to disk

OS
	turn swapiness to 0
	have a swap space, and monitor if it is ever used
	Turn off huge pages

Tools
	PMM
	 MySQLTuner

```
