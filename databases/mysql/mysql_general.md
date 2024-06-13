
---
title : MySQL General
author : Mark Nielsen
copyright : June 2024 
---


MySL General
==============================

_**by Mark Nielsen
Original Copyright June 2924**_

This article will grow over time. 

Not including
* Info queries
* MySQL variables

1. [mysqldump](#mysqldump)


* * *

<a name=mysqldump></a>MySQL Dump
-----

* See if you have triggers or stored procedures
   * Unless you dump mysql and all-databases, you can ignore dumping triggers and stored procedures if you find none
```
SELECT  routine_schema,  
        routine_name,  
        routine_type 
FROM information_schema.routines 
WHERE routine_schema not in ('sys', 'mysql', 'mysql_innodb_cluster_metadata', 'information_schema', 'performance_schema') 
ORDER BY routine_name;

  # just trigger name
select trigger_schema, trigger_name
  from information_schema.triggers
  WHERE trigger_schema not in ('sys', 'mysql', 'mysql_innodb_cluster_metadata', 'information_schema', 'performance_schema');
```

* mysqldump command,, with triggers, stored procedure, and replication position, everything
```
  # pre 8.0
  # needs testing
mysqldump -u root -p --single-transaction --events --triggers --routines --opt --all-databases \
--master-data=1 --dump-slave=2 --master-data=2 \
   | gzip > mysqlbackup_`hostname`_`date +%Y%m%d_%H%M%S`.sql.gz 

```

* to make a list of databases to ignore, select databases you want and add --databases to the option. Or use mysqlpump which has an exclude option.
```

SELECT group_concat( schema_name SEPARATOR ',')
  FROM information_schema.schemata
  where
     schema_name not in ('sys', 'performance_schema', 'information_schema', 'mysql_innodb_cluster_metadata')
     and  schema_name not like 'Ignore_pattern1%'
     and schema_name not like '%Ignore_pattern2%';

```


* * *

<a name=replication></a>Replication non-gtid
-----

## Switch Slave from Master to replicate off another slave.

Basically, a Master has two slaves, slave 1 and 2. We want to make Slave 2 replicate from Slave 1. Turn Slave 1 into a slave relay.


We make some assumptions
* Each server has a unique server-id
* Each server has bin-log turned on.
* Replication is setup between the Master and two Slaves.
* We can stop replication temporarily without applications being affected.
* We assume the accounts for replication are the same on all servers.

Steps.
* Stop slave on Slave 2: stop slave
* Stop slave on slave 1: stop slave
* Get Replication position on Slave 1
    * Show slave status : and record two fields
       * Exec_Master_Log_Pos
       * Master_Log_File
* Replicate on Slave 2 to the position on Slave 1
```
START SLAVE UNTIL MASTER_LOG_FILE='><Master_Log_File of slave 1>', MASTER_LOG_POS=<Exec_Master_Log_Pos of slave 1>;
### Keep doing show slave status until it stops. 

```
* Check Show slave status on slave1 and slave2 are the same for Master_Log_File and Exec_Master_Log_Pos.
* Change replication on Slave 2 to Slave 1
    * You will need to execute "show master logs" on slave 1. Note the last line. 
        * Name of the file in first column
	* Position in 2nd column. 
    * Execute on Slave 2
```
change master t0 master_host='server1', MASTER_LOG_FILE='><bin_log file of of slave 1>', MASTER_LOG_POS=<bilog position of slave 1>;
```
* Start slave on slave 2 : start slave
* Check slave 2 with "show slave status\G"
* start slave on slave 1 : start slave
* Check replication on slave 1 amd slave 2 : show slave status
    

