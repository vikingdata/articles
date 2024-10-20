


---
title : MySQL Replication
author : Mark Nielsen
copyright : August 2024 
---

MySQL GTID Replication
==============================
_**by Mark Nielsen
Original Copyright August 2024**_

Other issues:
* When slave is identical to a Master, if a slave executes commands in order they happened on the Master, there will be 0% errors. Let me repeat that, there will be 0 errors with identical servers
where the SQL commands are issued in order.
    * There are issues with this statement. What if the commands on the master affect each other?
    The Master has many connections committing data almost at the same time. Those commands get converted most of the time to  linear set of commands on the slave(s).
    All those connections committing data on the master
    must NOT affect each other, or the commands executed on other server
    may not yield the same result of data. 
* For both normal and GTID replication, you can set the replication to a point in the binlogs of the
master. GTID replication has other options to fix replication. 

Index

0. [Links](#links)
1. [Setup GTID](#setup)
    * [Multiple MySQL in Linux under VirtualBox under Windows](https://github.com/vikingdata/articles/blob/main/databases/mysql/Multiple_MySQL_virtualbox.md)
2. [Convert replication to GTID](#convert)
3. [Causing replication break with normal replication](#break)
    * Execute commands on master without recording it to binlog. 
    * Run out of diskspace on Master and restart Master.
    * Make data or schema changes on Slave(s)
6. [Repairing replication](#replication)
   * Try start slave
   * Skipping a statement
   * Reset to a point
   * Backup, restore, start replication.
7. Reset replication to beginning
   * [Reset GTID replication to beginning](#resetgtid)
   * [Reset normal replication to beginning](#resetnormal)

* * *
<a name=links></a>Links
-----
* [Repair - replace -  a slave gtid](https://docs.percona.com/percona-xtrabackup/2.4/howtos/recipes_ibkx_gtid.html)
* Setup GTID
    * [Setting Up Replication Using GTIDs](https://dev.mysql.com/doc/mysql-replication-excerpt/8.0/en/replication-gtids-howto.html)
    
* SKip Query GTID
    * [MySQL replication — Skipped GTID and how to fix it](https://medium.com/@brianlie/mysql-replication-skipped-gtid-and-how-to-fix-it-a2d836452724)
    * https://www.percona.com/blog/how-to-skip-replication-errors-in-gtid-based-replication/
    * https://mysqlwall.com/2021/11/30/how-to-skip-transaction-on-replica-when-gtid-replication-is-broken/
* Other
   * [A Useful GTID Feature for Migrating to MySQL GTID Replication – ASSIGN_GTIDS_TO_ANONYMOUS_TRANSACTIONS](https://www.percona.com/blog/useful-gtid-feature-for-migrating-to-mysql-gtid-replication-assign_gtids_to_anonymous_transactions/)
   * https://www.red-gate.com/simple-talk/blogs/a-beginners-guide-to-mysql-replication-part-4-using-gtid-based-replication/
   * https://percona.community/blog/2021/11/08/the-errant-gtid-pt1/
   * https://www.percona.com/sites/default/files/presentations/mysql_56_GTID_in_a_nutshell.pdf

* * *
<a name=setup></a>Setup GTID
-----

* On both servers in Linux
```
 ## Add this to /etc/my.cnf

gtid_mode=ON
enforce-gtid-consistency=ON
log-slave-updates=ON
```
* On both servers : service mysql restart
* <a href=#reset>Reset</a> the servers described below. 



* * *
<a name=convert></a>Convert replication to GTID
-----
* https://dev.mysql.com/doc/refman/8.4/en/replication-gtids-howto.html
* https://www.percona.com/blog/convert-mariadb-binary-log-file-and-position-based-replication-to-gtid-replication/
* https://dev.mysql.com/doc/refman/8.4/en/replication-mode-change-online-enable-gtids.html

NOTE: You can set gtid_mode and enforce-gtid-consistency in global variables without restarting. Try
   * In mysql on master <pre>
set GLOBAL enforce_gtid_consistency=on;
set GLOBAL gtid_mode=OFF_PERMISSIVE;
set GLOBAL gtid_mode=ON_PERMISSIVE;
set GLOBAL gtid_mode=ON
                        </pre>
   * On Slave <pre>
set GLOBAL gtid_mode=OFF_PERMISSIVE;
set GLOBAL gtid_mode=ON_PERMISSIVE;
start slave;
select sleep(5);
stop slave;
set GLOBAL enforce_gtid_consistency=on;
set GLOBAL gtid_mode=ON;
start slave;
select sleep(2);
show slave status\G
              </pre>
    * On both master and slave in my.cnf <pre>
gtid_mode=ON
enforce-gtid-consistency=ON
                                         </pre>
    

* * *
<a name=break></a>Causing replication break with normal or GTID replication
-----

### Execute commands on master without recording it to binlog.
* On the master
```
create database if not exists test1;
use test1
create table t (t int, PRIMARY KEY (t));
insert into t values (1);

SELECT * FROM performance_schema.global_variables
  WHERE VARIABLE_NAME like 'gtid_executed'
      OR VARIABLE_NAME like 'gtid_purged';

SET sql_log_bin = 0;
insert into t values (2);

SET sql_log_bin = 1;
SELECT * FROM performance_schema.global_variables
  WHERE VARIABLE_NAME like 'gtid_executed'
      OR VARIABLE_NAME like 'gtid_purged';

```
* To Fix: You may not be able to do so easily. Unknown data is committed on the Master and not other servers.
    * If you know the changes, commit them with "set sql_log_bin=0;" on the other servers. 
    * Backup and restore the Master to the other servers.
    * Use pt_sync from Percona. 


### Run out of diskspace
When you run out of diskspace, you may end of with partially written commands to the binlog. If the service
is restarted, you might end up with partial commands to the binlog which will error out on slaves.

The real fix would have been to free up diskspace if possible, or extend diskspace if VM, and then restart MySQL. 

* Error
    * Got fatal error 1236 from source when reading data from binary log: 'Could not find first log file name in binary log index file', Error_code: MY-013114
    * Error reading packet from server for channel '': Could not find first log file name in binary log index file (server_errno=1236)
* Links
    * https://www.percona.com/blog/mysql-replication-how-to-deal-with-the-got-fatal-error-1236-or-my-013114-error/

* Solution : [Set replication to the next position](#point)



* * *
<a name=replication></a>Repairing  replication
-----
* Try starting slave
   * Just in mysql: "start slave; select sleep(2); show slave status\G" and look at output.
   
* Skipping a statement
   * Skip errors -- this is very very bad. Identical servers should be able to execute the same queries in order and have NO errors. Only do this if you KNOW the data won't matter. 
       * https://www.ducea.com/2008/02/13/mysql-skip-duplicate-replication-errors/
       * ex: SET global slave-skip-errors = 1062;
       * This will skip all duplicate key errors. 
   * Skip for normal replication
       * https://dev.mysql.com/doc/refman/5.7/en/set-global-sql-slave-skip-counter.html
       * example on Slave: <pre>stop slave;
       SET GLOBAL sql_slave_skip_counter = 1;
       start slave;
       select sleep(2);
       show slave status</pre>
   * Skip GTID by empty commit
       * https://dev.mysql.com/doc/refman/8.4/en/replication-administration-skip.html
       * Steps:
           * Get current GTID position <pre>
mysql> SELECT * FROM performance_schema.global_variables   WHERE VARIABLE_NAME like 'gtid_executed';
+---------------+-----------------------------------------------------------------------------------+
| VARIABLE_NAME | VARIABLE_VALUE                                                                    |
+---------------+-----------------------------------------------------------------------------------+
| gtid_executed | 7ca9a3f5-f52b-11ee-b56f-080027a5063b:1-12,
                                       </pre>
           * "13" is the "next" downloaded command you want to skip. Basically, add "1" to the highest executed number "12".<pre>
stop slave;
SET GTID_NEXT='7ca9a3f5-f52b-11ee-b56f-080027a5063b:13';
BEGIN;
COMMIT;
SET GTID_NEXT='AUTOMATIC';
SELECT * FROM performance_schema.global_variables   WHERE VARIABLE_NAME like 'gtid_executed';
-- gtid_executed should be  7ca9a3f5-f52b-11ee-b56f-080027a5063b:1-13
start slave;
select sleep(2);
show slave status\G
                                                                                                                            </pre>
   * Skip GTID by new method.
       * https://www.percona.com/blog/how-to-skip-replication-errors-in-gtid-based-replication/ <pre>
STOP SLAVE;
SET GTID_MODE=ON_PERMISSIVE;
SET GLOBAL SQL_SLAVE_SKIP_COUNTER = 1;
START SLAVE;
&nbsp;
select sleep(2);
show slave status\G
 -- if good
stop slave;
SET GTID_MODE=ON;
start slave;
show slave status\G 
                                                                                                </pre>


* <a name=point></a>Reset to a point for normal or GTID
    * For normal or GTID replication, on slave find Master_Log_File and Exec_Master_Log_Pos from "show slave status\G".
        * Ex: binlog.000001 and 537
    * On master, find next position <pre>
/var/lib/mysql/binlog.000001 --base64-output=decode-rows --verbose | grep "&#35; at 537" -A 10 -B 10 | grep "&#35; at"
&#35; at 421
&#35; at 537
&#35; at 610
                                   </pre>	   
        * position 610 is after 537
	   * If there is no "next" position, then its the next log file binlog.000002	   <pre>
/home/mark# mysqlbinlog /var/lib/mysql/binlog.000002 --base64-output=decode-rows --verbose \
  | grep "&#35; at" \
  | head -n1 "&#35; at"
  "&#35; at 4
           </pre>
	   * example: binlog.000002 and 4 
   * On normal replication <pre>
stop slave;
change master to  master_log_file='binlog.000001', master_log_pos = 610;
start slave;
select sleep(2);
show slave status\G
                           </pre>
   * On GTID <pre>
stop slave;
change master to sOURCE_AUTO_POSITION=0;
change master to  masteR_log_file='binlog.000001', master_log_pos = 610;
start slave;
select sleep(2);
show slave status\G
 -- if good
stop slave;
change master to sOURCE_AUTO_POSITION=1;
start slave;
select sleep(2);
show slave status\G
            </pre>
   * If that doesn't work with GTID, reset the slave to the master's gtid. TODO
       * Find gtid position on master
           * show global variables like 'GTID_EXECUTED'
       * reset master on slave;
       * set gtid_purged on slave
           * set global GTID_PURGED="&lt;gtid from master&gt;";
       * start slave;
       * TODO : give example 

* Backup, restore, start replication.
    * Normal replication
        * https://www.linode.com/docs/guides/mysqldump-backups/
    * GTID replication
        * https://www.percona.com/blog/how-to-createrestore-a-slave-using-gtid-replication-in-mysql-5-6/
    * NOTE: Replication starting may be an issue. 


* * *
<a name=resetgtid></a>Reset gtid replication
-----
* On slave in MySQL
```
stop slave;
--  removes slave settings
reset slave all;

-- removes slave binlog gtid settings
reset master;    
```

* On master in mysql
```
drop user if exists 'repl'@'%';
drop user if exists 'remote'@'%';
CREATE USER if not exists 'repl'@'%' IDENTIFIED BY 'repl';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
GRANT REPLICATION client ON *.* TO 'repl'@'%';
CREATE USER if not exists 'remote'@'%' IDENTIFIED BY 'bad_password';
GRANT all privileges ON *.* TO 'remote'@'%';

```

* On both servers at Linux prompt
```
  ## REmoves all binlogs, starts fresh
service mysql stop
rm -vf /var/lib/mysql/binlog.*
service mysql start
```

* On master in mysql
```
stop slave;
reset slave all;
reset master; -- removes gitd settings from master
drop database if exists rep_test;
create database rep_test;
```

* On master in Linux
```
ip=`ifconfig | grep inet | head -n1 | sed -e 's/  */ /g' | cut -d ' ' -f3`
echo "master ip = $ip"
```
Output
```
  # NOTE your ip address will be different. 
master ip = 192.168.0.217
```

* On both is GTID is turned off
```
stop slave;
set GLOBAL gtid_mode=off_permissive;
set GLOBAL gtid_mode=on_PERMISSIVE;
set GLOBAL enforce_gtid_consistency=on;
set GLOBAL gtid_mode=on;
CHANGE REPLICATION SOURCE TO SOURCE_AUTO_POSITION = 1;
```


* On slave in mysql
```
 drop database if exists rep_test;
 CHANGE REPLICATION SOURCE TO
 SOURCE_HOST = '192.168.0.217',
 SOURCE_USER = 'repl',
 SOURCE_PASSWORD = 'repl',
 SOURCE_AUTO_POSITION = 1;
 start slave;
stop SLAVE; 
select sleep (1);
start slave;
select sleep (1);
show slave status\G
show databases like '%rep_test%';

```



* * *
<a name=resetnormal></a>Reset normal replication
-----
* We assume no connections are written to master.
* On masteR
```
drop user if exists 'repl'@'%';
drop user if exists 'remote'@'%';
CREATE USER if not exists 'repl'@'%' IDENTIFIED BY 'repl';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';

CREATE USER if not exists 'remote'@'%' IDENTIFIED BY 'bad_password';
GRANT all privileges ON *.* TO 'remote'@'%';
```
* On both servers in Linux
```
service mysql stop
rm -vf /var/lib/mysql/binlog.*
service mysql start
```

* Stop GTID replication, on both if given. If GTID is turned off, skip this. 
```
stop slave;
set GLOBAL gtid_mode=on_permissive;
set GLOBAL gtid_mode=OFF_PERMISSIVE;
CHANGE REPLICATION SOURCE TO SOURCE_AUTO_POSITION = 0;
set GLOBAL gtid_mode=OFF;
set GLOBAL enforce_gtid_consistency=off;

```

* On master
```
drop database if exists rep_test;
create database rep_test;

```

* On master  in Linux
```
ip=`ifconfig | grep inet | head -n1 | sed -e 's/  */ /g' | cut -d ' ' -f3`
echo "master ip = $ip"
```
Output
```
  # NOTE your ip address will be different.
  master ip = 192.168.0.217

```

* On Slave, make a dummy connection. For some reason, I needed to connect on my system before
the replication thread could connect. It makes no sense. 
```
mysql -u repl -prepl -h 192.168.0.217 -e "show status"
```


* On slave, you can configure replication starting from the first statement if you do not give it
a position to start from. 
from the beginning;
```
reset slave all;

drop database if exists rep_test;
CHANGE REPLICATION SOURCE TO
 SOURCE_HOST = '192.168.0.217',
 SOURCE_USER = 'repl',
 SOURCE_PASSWORD = 'repl';

start slave; 
stop SLAVE;
select sleep (1);
start slave;
select sleep (1);
  -- Verify replication is running fine without errors. 
show slave status\G
 -- Verify the rep_test database exists
show databases like '%rep_test%';

```

* * *
<a name=checks></a>Checks
-----
* Master binlog position -- both master and slave. The positions on here should match show slave status on slave.
On the master, is should be the most recent queries.
* On master
```

SELECT * FROM performance_schema.global_variables
  WHERE VARIABLE_NAME like 'gtid_executed'
      OR VARIABLE_NAME like 'gtid_purged';

show master status\G

select 'gtid_executed from global variables should match Executed_Gtid_Set in show master status';

```

* On slave in Linux
    * In Linux ```mysql  -e "show slave status\G" | grep Gtid ```

    * in mysql ```
SELECT * FROM performance_schema.global_variables
  WHERE VARIABLE_NAME like 'gtid_executed'
        OR VARIABLE_NAME like 'gtid_purged';
               ```
    * "Executed_Gtid_Set" in show slave status should match gtid_executed in global variables.

* Slave status info
```
mysql  -e "show slave status\G" | egrep -i "Gtid|master_log_file|master_log_pos|running:"
```