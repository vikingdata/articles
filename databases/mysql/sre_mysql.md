
---
title : MySQL SRE
author : Mark Nielsen
copyright : Novemeber 2023
---


MySQL SRE
==============================

_**by Mark Nielsen
Original Copyright Feb 2021**_

1. [Links](#links)
2. [Basic](#basic)

* * *
<a name=links></a>Links
-----

* [MySQL’s SRE Golden Signals](https://steve-mushero.medium.com/mysqls-sre-golden-signals-67e2adf88824)
* [Aurora’s SRE Golden Signals](https://steve-mushero.medium.com/aws-auroras-sre-golden-signals-d0400c4801b1)
* [Linux’s SRE Golden Signals](https://steve-mushero.medium.com/linuxs-sre-golden-signals-af5aaa26ebae)
* [How to Monitor the SRE Golden Signals](https://faun.pub/how-to-monitor-the-sre-golden-signals-1391cadc7524)
* [https://linkedin.github.io/school-of-sre/level101/databases_sql/mysql/](https://linkedin.github.io/school-of-sre/level101/databases_sql/query_performance/)
* [MySQL @ Klaviyo Ops Crash Course](https://klaviyo.tech/mysql-klaviyo-ops-crash-course-71ccecb7f4ef)
* [A Simple Approach to Troubleshooting High CPU in MySQL](https://www.percona.com/blog/a-simple-approach-to-troubleshooting-high-cpu-in-mysql/)
* [pidstat Command Examples in Linux](https://www.thegeekdiary.com/pidstat-command-examples-in-linux/)
* [10 pidstat Examples to Debug Performance Issues of Linux Process](https://www.thegeekstuff.com/2014/11/pidstat-examples/)
* [How to know which process is eating your hard disk](https://brundlelab.wordpress.com/2010/02/19/how-to-know-which-process-is-eating-your-hard-disk/)
* [How Percona does a MySQL Performance Audit](https://www.percona.com/blog/how-percona-does-a-mysql-performance-audit/)
* [What You Can Do With Auto-Failover and Percona Distribution for MySQL (8.0.x)](https://www.percona.com/blog/what-you-can-do-with-auto-failover-and-percona-distribution-for-mysql-8-0-x/)

* * *
<a name=Basic></a>Basic
-----

* Linux CPU : Is the Linux CPU okay? If the CPUs on the system as high, it could be an issue. Eachcore of a cpu can ONLY process one query at a time. It can balance the queries amoung the cpus. 
* Linux Mem
* Linux Diskspace
* Linux Processes
* Linux Load
* MySQL Processes
* MySQL Replication
* Monitoring Graphs


* * *
<a name=rates></a>Rates
-----
* Request
* Error
* Latency
* Saturation
* Utilization

* * *
<a name=problem></a>What could cause the problem
-----

* MySQL Bad Queries
* MySQL Performance
    * Indexes
    * Size of tables
    * Configuration
        * Innodb
        * Buffers
    * Replication or Clustering
    * Locks
    * IO
* Linux CPU    
* Linux Memory
* Linux Diskspace
* Linux Network
* Linux IO
* MySQL Account settings
* Uknown. Test queries on another server. 

* * *
<a name=#order></a>Order of Attack
-----

1. Check processes
2. Look at graphs
3. Look at monitoring
4. Check Performance Schema
5. Check network from the applications

* * *
<a name=#queries></a>Queries & Commands
-----

* MySQL Rates
* MySQL Memory
* MySQL Processes
* MySQL Performance
    * Indexes
    * Locks
    * Size of table
    * Configuration
* MySQL Slow logs
* Linux CPU
* Linux Processes
* Linux Memory
* Linux LOAD
* Linux Strace
* Linux IO
* Linux general
   * pidstat
```shell
 PID=`ps auxw | grep mysqld  | grep -v grep  | head -n 1 | sed -e 's/  */ /g' | cut -d ' ' -f2`
 pidstat -t -p $PID 1

  # or
pidstat -C "mysql"

  # or
pidstat -t -C "mysql"
  
```

   * To sort by -h, cpu

```
   # First execute this
pidstat -h | head -n 3 | tail -n 1

   # Then execute one of these for the highest 5
   # Highest % USR cpu 
pidstat -h | tail -n +4 | sort -nr -k 5 | head -n 4 

   # Highest % system cpu
pidstat -h | tail -n +4 | sort -nr -k 6 | head -n 4

   # Highest % virtual cpu
pidstat -h | tail -n +4 | sort -nr -k 7 | head -n 4

   # Highest % wait time
pidstat -h | tail -n +4 | sort -nr -k 8 | head -n 4

   # Highest % Total CPU used -- this is probably what you want. 
pidstat -h | tail -n +4 | sort -nr -k 9 | head -n 4
```
   * IO stats
```
pidstat -d | head -n 3 | tail -n 1

  # Then choose one of these

  # Kilobytes read
pidstat -d | tail -n +4 | sort -nr -k 5 | head -n 4
  # KB written
pidstat -d | tail -n +4 | sort -nr -k 6 | head -n 4
  # KB cancelled write
pidstat -d | tail -n +4 | sort -nr -k 7 | head -n 4


```

* * *
<a name=#monitoring></a>Monitoring
-----
* On Prem
* AWS
* Solar Winds, New Relic
* Performance Schema

* * *
<a name=#audit></a>Performance Audit
-----
* Performance Schema
* Analyze Graphs from monitoring


* * *
<a name=#failover></a>Atomatic Failover
-----
Can be done usng GTID replication and automatic failover or with a Cluster (Percona Cluster, NDB
Cluster, or group replication - MySQL Cluster).


* * *
<a name=#failovertesting></a>Failover Testing
-----



* * *
<a name=#slow></a>Slow Logs
-----
* (mysqldumpslow)[https://dev.mysql.com/doc/refman/8.0/en/mysqldumpslow.html]
* (pt-query-digest)[https://docs.percona.com/percona-toolkit/pt-query-digest.html]
* (Summarizing the MySQL Slow Query log
)[https://www.stephenrlang.com/2018/12/summarizing-the-mysql-slow-query-log/]


* Slow log variables

```
log_output = FILE
slow_query_log = ON
slow_query_log_file = /var/log/mysql/mysql-slow.log
long_query_time = 1
log_slow_admin_statements = ON
log_queries_not_using_indexes = ON
log_output = FILE
log_queries_not_using_indexes=5

```

* Executing  pt-query-digest

* Executing mysqldumpslow

```


```

* * *
<a name=#logrotate></a>Logrotate
-----

* slow log

```
/var/lib/mysql/mysql-slow.log {
    size 5G
    daily
    dateext
    compress
    missingok
    rotate 5
    notifempty
    delaycompress
    sharedscripts
    nocopytruncate
    create 660 mysql mysql
    postrotate
        /usr/bin/mysql -e 'select @@global.slow_query_log into @sq_log_save; set global slow_query_log=off; select sleep(1); FLUSH SLOW LOGS; select sleep(1); set global slow_query_log=@sq_log_save;'
    endscript
    rotate 150
}


* binlog

In MySQL shell

```mysql
set GLOBAL expire_logs_days = 14;
set GLOBAL max_binlog_size=1G;
```

In my.cnf
```text
expire_logs_days = 14
max_binlog_size=1G
```


* * *
<a name=#ansible></a>ANisble sysctl
-----


* * *
<a name=#ptesting></a>Performance Testing
-----
* (How to Benchmark MySQL Performance)[https://blog.purestorage.com/purely-informational/how-to-benchmark-mysql-performance/]
* (HammerDB)[https://www.hammerdb.com/about.html]
* (mysqlslap)[https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html]
* (How To Measure MySQL Query Performance with mysqlslap)[https://www.digitalocean.com/community/tutorials/how-to-measure-mysql-query-performance-with-mysqlslap]
* (How to Benchmark Replication Performance in MySQL)[https://www.percona.com/blog/how-to-benchmark-replication-performance-in-mysql/]



* * *
<a name=#todo></a>ToDos
-----
* MicroSoft Doc, Python, get data from system and integrate. 