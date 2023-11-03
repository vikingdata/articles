
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
