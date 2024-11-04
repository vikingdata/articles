
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
I find no document about how to handle memory satisfactory. This is mostly Linux and can be used for any application
but there are some specific MySQL queries and configurations. 


1. [Links](#links)
3. [Mysql](#mysql)
4. [linux](#linux)
5. [MySQL Memory Monitoring](#memory)
6. [Show Innodb Status](#si)

* * *
<a name=links></a>Links
-----
* https://dev.mysql.com/doc/refman/8.4/en/monitor-mysql-memory-use.html
* https://dev.mysql.com/doc/refman/8.4/en/performance-schema-memory-summary-tables.html
* https://dba.stackexchange.com/questions/56454/get-memory-usage-of-mysql-query-during-runtime
* https://severalnines.com/blog/what-check-if-mysql-memory-utilisation-high/
* https://my.f5.com/manage/s/article/K40027012
* https://confluence.atlassian.com/bamkb/how-to-review-swap-space-usage-on-a-linux-server-865042927.html
* https://lefred.be/content/mysql-and-memory-a-love-story-part-1/
* https://lefred.be/content/mysql-and-memory-a-love-story-part-2/

* * *
<a name=mySQL></a>MySQL
-----
Maximum about of memory used. Note: This doesn't include memory leaks. I have found this equation not to be true if
there is a bug. 

### MySQL Queries

```

#### MySQL maximum memory
  -- Maximum amount of memory in theory. 
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

  # See memory by thread. 
select processlist_id as id,
  processlist_db as db,
  floor(MAX_CONTROLLED_MEMORY) mc_mem_kb ,
  floor(TOTAL_MEMORY/1024) t_mem_kb ,
  floor(MAX_TOTAL_MEMORY/1024) as mt_mem_kb,
  processlist_info as info
from performance_schema.threads
where processlist_id is not null
  and processlist_info is not null limit 1;
```

#### MySQL memory by threads. 8.0 or higher
```
  -- sum memory by all threads MySQL 8 and higher only (maybe 5.7 also)
  -- https://dev.mysql.com/doc/refman/8.4/en/performance-schema-threads-table.html
  -- total memory is current amount of memory used.
select
  floor(sum(MAX_CONTROLLED_MEMORY)/(1024)) mc_mem_kg ,
  floor(sum(TOTAL_MEMORY)/(1024)) t_mem_kg ,
  floor(sum(MAX_TOTAL_MEMORY)/(1024)) mt_mem_kg ,
  
  floor(sum(MAX_CONTROLLED_MEMORY)/(1024*1024)) mc_mem_mb ,
  floor(sum(TOTAL_MEMORY)/(1024*1024)) t_mem_mb ,
  floor(sum(MAX_TOTAL_MEMORY)/(1024*1024)) mt_mem_mb 
from performance_schema.threads
;

select
  floor(sum(TOTAL_MEMORY)/(1024)) total_mem_kb ,
  floor(sum(TOTAL_MEMORY)/(1024*1024)) total_mem_mb ,
  floor(sum(TOTAL_MEMORY)/(1024*1024*1024)) total_mem_gb 
from performance_schema.threads
;

```

```
### Linux Commands

These queries and techniques are to get information about the system and mysql.

#### Free -- see how much swap is being used. 
```
  # Get the total memory and swap usage. 
free -h
```

#### 'ps' -- see how much memory is used by mysql, no swap

```
  # get ps output of mysqld
ps auxw |egrep -i "mysqld|^USER" | grep -v grep

ps -e -o pid,user,rss,size,share,vsize,pmem,args | egrep -i "pid user|mysqld" | grep -v grep
 #output should be like
 #    PID USER       RSS  SIZE -    VSZ %MEM COMMAND
 #  10141 mysql    220644 894020 - 1371204  5.5 /usr/sbin/mysqld
````

#### Loop through every process to see how much swap is used. Find mysqld

```
  # Loop through every process to see what takes up most swap
for file in /proc/*/status ; do
  awk '/VmSwap|Name/{printf $2 " " $3}END{ print ""}' $file;
done | sort -k 2 -n -r | head

  # Show swap for mysql
for file in /proc/*/status ; do
  awk '/VmSwap|Name/{printf $2 " " $3}END{ print ""}' $file;
done | grep mysqld | awk '{print "SWap Usage: " $1 " " $2 " kb " int($2/1024) " mb " int($2/(1014*1024)) " gb"}';

# output should look like: SWap Usage: mysqld 334848 kb 327 mb 0 gb

```

#### vmstat -- see the acitivty on swap
```
  # See swap activity
vmstat 1 5
```
#### proc/meminfo -- maybe you can get some useful info out of it. 

```
#### /proc/meminfo
cat /proc/meminfo
```

### TOP

Use top to show swap. Different versions of top have different ways to do it.

* Start top
* Press h for help
* Follow the instructions to
    * Add SWAP
    * Order by SWAP
    * Make it the first column
    * Press "E", not "e" to cycle through kilobytes, megabytes, gigabytes, etc
* Press <shift> w to save the format.
* Execute
```
top -b -n 1 > /tmp/top_swap.log
egrep "^[a-za-Z\%]|mysqld|SWAP" /tmp/top_swap.log

# or
top -b -n 1 | egrep "^[a-za-Z\%]|mysqld|SWAP" /tmp/top_swap.log

```

The output of top should look like this. I switched it to gigabytes. 
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
<a name=memory></a>MySQL memory monitoring
-----

 Memory monitoring -- I believe 5.7 or 8.0 and later. 
* https://dev.mysql.com/doc/refman/8.4/en/monitor-mysql-memory-use.html
* https://dev.mysql.com/doc/refman/8.4/en/performance-schema-setup-instruments-table.html

You can setup instruments to monitor mysql memory, but I am interested in memory right not.
I use graphing or other monitoring to view memory and swap usage. 

* Check which instruments are enabled.
```
  -- if an instrument is not enabled, set it to enabled. 
SELECT * FROM performance_schema.setup_instruments WHERE NAME LIKE '%memory%';
```

* See the memory by event, and the summary for current values. 
```
mysql> select event_name,current_alloc from sys.memory_global_by_current_bytes limit 10;
+-----------------------------------------------------------------------------+---------------+
| event_name                                                                  | current_alloc |
+-----------------------------------------------------------------------------+---------------+
| memory/innodb/buf_buf_pool                                                  | 130.88 MiB    |
| memory/performance_schema/events_statements_summary_by_digest               | 40.28 MiB     |
| memory/innodb/ut0link_buf                                                   | 24.00 MiB     |
| memory/innodb/log_buffer_memory                                             | 16.00 MiB     |
| memory/performance_schema/events_statements_history_long                    | 14.42 MiB     |
| memory/sql/TABLE                                                            | 13.80 MiB     |
| memory/performance_schema/events_errors_summary_by_thread_by_error          | 13.24 MiB     |
| memory/performance_schema/events_statements_summary_by_thread_by_event_name | 11.97 MiB     |
| memory/performance_schema/events_statements_summary_by_digest.digest_text   | 9.77 MiB      |
| memory/performance_schema/events_statements_history_long.sql_text           | 9.77 MiB      |
+-----------------------------------------------------------------------------+---------------+
10 rows in set (0.00 sec)

 --- Get sum of memory used in 2 different ways. 

mysql>
mysql> select format_bytes(sum(current_alloc)) from sys.x$memory_global_by_current_bytes;
+----------------------------------+
| format_bytes(sum(current_alloc)) |
+----------------------------------+
| 468.69 MiB                       |
+----------------------------------+
1 row in set (0.00 sec)

mysql>

mysql> select * from memory_global_total;
+-----------------+
| total_allocated |
+-----------------+
| 472.52 MiB      |
+-----------------+
1 row in set (0.00 sec)

 -- This is grouped by event_name, which may be helpful. 

mysql> SELECT SUBSTRING_INDEX(event_name,'/',2) AS code_area,
            sys.format_bytes(SUM(current_alloc)) AS current_alloc
     FROM sys.x$memory_global_by_current_bytes
     GROUP BY SUBSTRING_INDEX(event_name,'/',2)
     ORDER BY SUM(current_alloc) DESC;
+---------------------------+---------------+
| code_area                 | current_alloc |
+---------------------------+---------------+
| memory/performance_schema | 235.78 MiB    |
| memory/innodb             | 195.51 MiB    |
| memory/sql                | 30.46 MiB     |
| memory/mysys              | 9.03 MiB      |
| memory/temptable          | 1.00 MiB      |
| memory/mysqld_openssl     | 838.15 KiB    |
| memory/mysqlx             | 3.26 KiB      |
| memory/myisam             |  728 bytes    |
| memory/component_sys_vars |  648 bytes    |
| memory/csv                |  120 bytes    |
| memory/blackhole          |  120 bytes    |
| memory/vio                |   80 bytes    |
+---------------------------+---------------+
12 rows in set, 1 warning (0.00 sec)


```

See how it compares to ps, top, and proc.
```
  ## From /proc
for file in /proc/*/status ; do
  awk '/VmSwap|Name/{printf $2 " " $3}END{ print ""}' $file;
done | grep mysqld | awk '{print "SWap Usage: " $1 " " $2 " kb " int($2/1024) " mb " int($2/(1014*1024)) " gb"}';

#  SWap Usage: mysqld 331520 kb 323 mb 0 gb

  ## from top
#  SWAP  %CPU     PID USER      PR  NI    VIRT    RES    SHR S  %MEM     TIME+ COMMAND
# 331520   0.7   10141 mysql     20   0 1371204 224868  18304 S   5.6  78:11.02 mysqld
let top_mem=331520+224868
echo $top_mem

# output : 556388 kb

  # Calculate non swap memory used from ps and free. 

nonswap=`free -m | egrep "Mem:" | sed -e 's/  */ /g' | cut -d ' ' -f2`
per=`ps -eo pmem,command | grep mysqld | grep -v grep |  head -n 1 |cut -d ' ' -f2`
echo "non-swap memory used by mysql $nonswap*$per/100 = `echo "$nonswap*$per/100" | bc`"

# output
# non-swap memory used by mysql 3916*5.6/100 = 219

  ## From /proc, non-swap memory
for file in /proc/*/status ; do
  awk '/VmRSS|Name/{printf $2 " " $3}END{ print ""}' $file;
done | grep mysqld | awk '{print "Resident memory: " $1 " " $2 " kb " int($2/1024) " mb " int($2/(1014*1024)) " gb"}';

# output : Resident memory: mysqld 224868 kb 219 mb 0 gb

```
* Summary swap
  * top   331 MiB
  * proc  331 MiB

* Summary total memory
    * MySQL 468 MiB
    * top   556 MiB

* Summary non-swap memory
    * top         224 MiB
    * ps + free   219 MiB
    * proc        224 MiB

*  Let's take 224 Mib + 331 Mib = 575 Mib which is close to top.

It seems MySQL and Linux is a little off, but with large systems it is probably closer to the same.

I guess if swap is heavily used, use the summary table by event_name to see what is eating up the memory. 

* * *
<a name=is></a>Show innodb status
-----


output of memory sections of "show enging innodb status".
```
----------------------
BUFFER POOL AND MEMORY
----------------------
Total large memory allocated 0
Dictionary memory allocated 577854
Buffer pool size   8191
Buffer pool size, bytes 134201344
Free buffers       1025
Database pages     7160
Old database pages 2623
Modified db pages  0
Pending reads      0
Pending writes: LRU 0, flush list 0, single page 0
Pages made young 3284, not young 257351
0.00 youngs/s, 0.00 non-youngs/s
Pages read 221484, created 486740, written 496023
0.00 reads/s, 0.00 creates/s, 0.00 writes/s
No buffer pool page gets since the last printout
Pages read ahead 0.00/s, evicted without access 0.00/s, Random read ahead 0.00/s
LRU len: 7160, unzip_LRU len: 0
I/O sum[0]:cur[0], unzip sum[0]:cur[0]
--------------
```