
---
title : MySQL Memory
author : Mark Nielsen
copyright : October 2024
---


MySQL Memory
==============================

_**by Mark Nielsen
Copyright October 2024**_

This is for MySQL 8. MySQL 5.7 has different tables and columns. Did not check 8.1 or 8.4, but expect changes. 


1. [Links](#links)
2. [Queries](#queries)
3. [Setup](#setup)
4. [Output](#output)

* * *
<a name=links></a>Links
-----
* https://dev.mysql.com/doc/refman/8.4/en/monitor-mysql-memory-use.html
* https://dev.mysql.com/doc/refman/8.4/en/performance-schema-memory-summary-tables.html
* https://dba.stackexchange.com/questions/56454/get-memory-usage-of-mysql-query-during-runtime
* https://severalnines.com/blog/what-check-if-mysql-memory-utilisation-high/
* https://my.f5.com/manage/s/article/K40027012
* https://confluence.atlassian.com/bamkb/how-to-review-swap-space-usage-on-a-linux-server-865042927.html

* * *
<a name=queries></a>Queries
-----
Maximum about of memory used. Note: This doesn't include memory leaks. I have found this equation not to be true if
there is a bug. 

## MySQL Queries

```
SELECT ( 
-- Uncomment if you have query cache
--  @@key_buffer_size
-- + @@query_cache_size
+ @@innodb_buffer_pool_size
+ @@innodb_log_buffer_size
+ @@max_connections * ( 
    @@read_buffer_size
    + @@read_rnd_buffer_size
    + @@sort_buffer_size
    + @@join_buffer_size
    + @@binlog_cache_size
    + @@thread_stack
    + @@tmp_table_size )
) / (1024 * 1024 * 1024) AS MAX_MEMORY_GB;


## Linux Commands

```

These queries and techniques are to get information about the system and mysql.

```
  # Get the total memory and swap usage. 
free -h

  # get ps output of mysqld
ps auxw |egrep -i "mysqld|^USER" | grep -v grep

ps -e -o pid,user,rss,size,share,vsize,pmem,args | egrep -i "pid user|mysqld" | grep -v grep
 #output should be like
 #    PID USER       RSS  SIZE -    VSZ %MEM COMMAND
 #  10141 mysql    220644 894020 - 1371204  5.5 /usr/sbin/mysqld

  # Loop through every process to see what takes up most swap
for file in /proc/*/status ; do
  awk '/VmSwap|Name/{printf $2 " " $3}END{ print ""}' $file;
done | sort -k 2 -n -r | head

  # Show swap for mysql
for file in /proc/*/status ; do
  awk '/VmSwap|Name/{printf $2 " " $3}END{ print ""}' $file;
done | grep mysqld | awk '{print "SWap Usage: " $1 " " $2 " kb " int($2/1024) " mb " int($2/(1014*1024)) " gb"}';

# output should look like: SWap Usage: mysqld 334848 kb 327 mb 0 gb

  # See swap activity
vmstat 1 5

cat /proc/meminfo

```
## TOP

Use top to show swap. Different versions of top have different ways to do it.

* Start top
* Press h for help
* Follow the instructions to
    * Add SWAP
    * Order by SWAP
    * Make it the first column
    * Press "E" to cycle through kilbytes, megabytes, gigbaytes, etc
* Press <shift> w to save the format.
* Execute
```
top -b -n 1 > /tmp/top_swap.log
egrep "^[a-za-Z\%]|mysqld|SWAP" /tmp/top_swap.log

# or
top -b -n 1 | egrep "^[a-za-Z\%]|mysqld|SWAP" /tmp/top_swap.log

```

The output of top should look like this. I swtiched it to gigbytes. 
```
top - 18:15:10 up 4 days, 23:01,  2 users,  load average: 0.00, 0.00, 0.00
Tasks: 193 total,   1 running, 191 sleeping,   1 stopped,   0 zombie
%Cpu(s):  0.0 us,  0.0 sy,  0.0 ni,100.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
GiB Mem :      3.8 total,      1.0 free,      0.6 used,      2.2 buff/cache
GiB Swap:      2.6 total,      1.9 free,      0.8 used.      2.9 avail Mem
  SWAP  %CPU     PID USER      PR  NI    VIRT    RES    SHR S  %MEM     TIME+ COMMAND
  0.3g   0.0   10141 mysql     20   0    1.3g   0.2g   0.0g S   5.5  76:33.04 mysqld
```


* * *
<a name=ouptut></a>Output
-----

```
* * *
<a name=idb></a>Show InnoDB status
-----
Even the show engine innodb status does have the alter lock. 

```
mysql> show engine innodb status;

* * *
<a name=i></a>Sys schema and memory use
-----
