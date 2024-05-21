 
---
title : MySQL Variables
author : Mark Nielsen  
copyright : May 2024  
---


MySQL Variables
==============================

_**by Mark Nielsen
Original Copyright May 2024**_


NOTE: This article is always in progress.

1. [Links](#links)
2. [Server Configuration](#s)
3. [Client Configuration](#c)
4. [Replication](#r)
5. [ClusterSet](#cluster)
6. [Other](#other)

* * *
<a name=Links></a>Links
-----
* [MySQL Performance Cheat Sheet](https://severalnines.com/blog/mysql-performance-cheat-sheet/)
* [Tuning MySQL System Variables for High Performance](https://geekflare.com/mysql-performance-tuning/)
* [MySQL Configuration](https://releem.com/docs/mysql-performance-tuning/mysql-configuration)
* [Enhancing MySQL 8 on Modern Hardware: A Guide to Tuning InnoDB I/O Threads for Optimal Performance](https://minervadb.xyz/tuning-mysql-innodb-io-threads-for-optimal-performance/#:~:text=1.,innodb_read_io_threads%20and%20innodb_write_io_threads%20to%204.)

* * *
<a name=s>Server Configuration</a>
-----

### Very Important Variables
* server-id : Used to identify a server in replication or cluster. You should always have it.
* report-host : Name of the server. Again, you should always have this.

Optimization Important Variables
* innodb_buffer_pool_size : Typically set to 80% of memory, but I like 70%. Other things may use memory, connections, temporary tables, and as such I like to monitor memory. This variable
caches data for the innodb storage in ram, which greatly increases speed for read queries. 
* innodb_buffer_pool_instances: Locks in the innodb buffer pool can be a problem with large data. In general innodb_buffer_pool_instances should be set to amount of ram divided by 1 gig.
* innodb_log_file_size -- pre 8.0 -- transactions use this file. If the log is full, its slows down the system. For older versions of MySQL, making this large is good.
* innodb_flush_log_at_trx_commit - pre 8.0. 0 means not ACID. 1 means data is flushed to disk. 2 means it is flushed to logs, which is not ACID compliant and on crash recovery takes longer. 


* table_cache : The amount of tables cached. Is this is too small, it may cause problems. 
    * SHOW OPEN TABLES : shows currently opened tables.
    * SHOW OPENED TABLES : If this value is large, your table cache may be too small.
    * Also count how may tables you have. 
        * group by database or total
```
select count(1), table_schema
  from INFORMATION_SCHEMA.TABLES
  where table_schema not in ('mysql','information_schema','performance_schema','sys')
  group by table_schema;

select count(1)
  from INFORMATION_SCHEMA.TABLES
  where table_schema not in ('mysql','information_schema','performance_schema','sys');
```
* Threads
    * innodb_write_io_threads and  innodb_write_io_threads
         * Look at the ratio of read threads and write threads and determine if you should increase either. Also, you may want to increase them slightly and see if it has an effect by
	 monitoring.
```
 # Sum the writes and compare to the reads
  SHOW GLOBAL STATUS WHERE Variable_name RLIKE '^(Com_select|Com_insert|Com_delete|Com_update)$';
```
* innodb_page_cleaners - Set as high as innodb_buffer_pool_instances. 

* innodb_flush_method : Changes based on the hardware used. How data is flush to disk. 
* innodb_file_per_table : Always use this. The main reason is if you drop a table diskspace is returned to the OS.
* slow_query_log
* sync_binlog. Under Cluster, it may be okay to set to 0. 1 means flush to disk transactions for the binlog, which is the safest. If 0, you rely on the operating system which is about every second. In a crash, 0 means you may lose some data. Value 9 i not durable. 
* thread_pool_size . The number of threads you are allow to have. With lots of cpu and disks, this can be higher. Generally set to the no of cores on your system.
* replica_parallel_workers : Default is 4. 

### Less important variables
* datadir : You generally don't want to use /var/lib/mysql. You want to put the database on its own partition like /database and have the data directory at /database/mysql/data. The directory "/database/mysql" can have other directories for bin-logs, errors logs, and other things.


*  max_connections   : Monitor max connections. If you need more, it is can be set dynamically. 
*  wait_timeout      : Unless you have long running queries, rarely you need to adjust his. This can be specified per session if needed. 
*  thread_cache_size : Monitor. It is reaches to a low amount, increase it. It can be set dynamically. 
*  key_buffer_size   : Only for MyISAM. Nobody uses it. 
*  query_cache_size  : Nobody uses this. Cache in redis or other caching before MySQL is hit. 
*  tmp_table_size, max_heap_table_size, and temptable_max_mmap   : For tables that are created in memory, if you analyze the slow log and you see a lot of temporary tables made and hitting disk, you may want to increase this. You can use Analyze Explain on slow queries to see if they mention "using filesort ; using temporary tables". Filesort just means a table
was made for sorting, but it might not have hit disk. Using temporary tables also means a temporary table was created but it might not have hit disk/. 
* Buffers -- if you have big sorts, joins, reads, or can take advantage of read ahead.
   * sort_buffer
   * read_buffer_size
   * read_rnd_buffer_size
   * join_buffer_size
* long_query_time : Time query needs to execute before saved to slow logs. If your server experiences bad performance and it doesn't show any slow queries, you may want to lower this variable to capture queries that are the slowest. 
* innodb_purge_threads - Number of background threads dedicated to InnoDB purge operations. The default is normally enough. 
* innodb_page_cleaners - Set as high as innodb_buffer_pool_instances. It is responsible for cleaning out data in the innodb buffer. 
* max_allowed_packet : increase if you are uploading large data, images, files are large varchar, text, or binary. 
* innodb_thread_concurrency : The default is no limit on threads, which most systems are okay with. By testing, you may want to limit innodb_thread_concurrency;
* Huge transparent page
    * If you don't have huge transparent pages on it may use swap, which is okay. just have a big swap. 
        * https://www.percona.com/blog/settling-the-myth-of-transparent-hugepages-for-databases/

* * *
<a name=c>Client settings</a>
-----
* defaults-file : For different authetications have different files. Default, .my.cnf in home directory. 
* Also, for authentication, use mysql_config_editor  with uses .mylogin.cnf to encrypt login credentials.
* -vvv
    * Turn on verbose mode. Useful with "tee" to record your commands.
```
mysql -vvv -u USER -p

  # And after you log in
tee TICKET_NO-sql.log
select now(), @@hostname, @@server_id;
```
    * You can also do "mysql --tee FILE -vvv -u USER -p"
* -e : Let's you execute a command and then exit mysql
* --batch : prints output in tabular format.
* To have commands NOT quit on first error "mysql -vvv -tee FILE.log -u USER -e 'source commands.sql'"
* To have commands quit on first error: ``` cat commands.sql | mysql -vvv -tee FILE.log -u USER ```

* * *
<a name=r>Replication</a>
-----
* server-id : Needed for replication.
* server_uuid : Made by MySQL server. Used by GTID. 
* skip-replica-start : Important if you don't  want replication to start when the system starts. 
* log_slow_replica_statements : If you want to log slow queries from replication.
* replica_compressed_protocol : May save network speed over cpu usage.
* replica_parallel_workers :  default 4 in later versions of MySQL. 
*  replica_preserve_commit_order=ON. This prevents gaps from occurring.
* report_host : This should always be setup. Match it with DNS.
* Stop collisions from multiple masters
   * auto_increment_offset : Adds X to the starting point defined for this server for new rows. 
   * auto_increment_increment : determines the starting point. 
   * NOTE: auto_increment_increment should be equal or more than the highest auto_increment_offset.

* * *
<a name=cluster>Clusterset</a>
-----
* [Group Replication Requirements](https://dev.mysql.com/doc/refman/8.0/en/group-replication-requirements.html)
    * Innodb Storage Engine
    * server_id
    * binlog
    * log_replica_updates=ON
    * binlog_format=row.
    * binlog_checksum=NONE
    * gtid_mode=ON and enforce_gtid_consistency=ON. 
    * transaction_write_set_extraction=XXHASH64 
    * Set lower_case_table_names the same, normally 1.
    * replica_parallel_type=LOGICAL_CLOCK
    * replica_preserve_commit_order=ON

* [Requirements for Cluster](https://dev.mysql.com/doc/mysql-shell/8.0/en/mysql-innodb-cluster-requirements.html)

* [Requirements](https://dev.mysql.com/doc/mysql-shell/8.0/en/innodb-clusterset-requirements.html):
    * Every table has a primary key
    * Single Primary Mode : default. If Multi, ClusterSet is not supported,
    * No inbound replication. 

* server_uuid : Made by MySQL server. Used by GTID. 

* Option. Because Cluster is being used, if you can assume an entire datacenter won't go down you might want to relax
    * sync_binlog
    * innodb_flush_log_at_trx_commit
    * innodb_flush_method    

* * *
<a name=o>Other</a>
-----
