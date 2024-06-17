
---
title : MySQL General
author : Mark Nielsen
copyright : June 2024 
---


MySQL General
==============================

_**by Mark Nielsen
Original Copyright June 2924**_

This article will grow over time. 

Not including
* [Info queries](info_queries.md)
* [MySQL variables](MySQL_variables.md)

1. [mysqldump](#mysqldump)
2. [Replication non-gtid ](#replication)
    * [Non-gtid. Switch Slave from Master to replicate off another slave](#switchSlave)
3. [tail q gzip file](#tailgzip)
4. (Percona Xtrabackup](#p]

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

* mysqldump pre-8.0 command, with triggers, stored procedure, and replication position, everything
```
  # pre 8.0
mysqldump -u root -p --single-transaction --events --triggers --routines --opt --all-databases \
--dump-slave=2 --master-data=2 \
   | gzip > mysqlbackup_`hostname`_`date +%Y%m%d_%H%M%S`.sql.gz 

```

* mysqldump 8.0 command, with triggers, stored procedure, and replication position, everything
```
  # 8.0.26
  # needs testing
mysqldump -u root -p --single-transaction --events --triggers --routines --opt --all-databases \
--dump-replica=2 --source_data=2 \
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

<a name=switchSlave></a>
### Non-gtid. Switch Slave from Master to replicate off another slave.

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
* Check replication on slave 1 and slave 2 : show slave status
    

* * *
<a name=tailgzip></a>Tail a gzipped file
-----

Assume a file is called File.gz

### Long way
This takes a long time since it has to unzip the entire file before doing tail.

```
zcat FILE.gz | tail -n 5

  ## or
gunzip -c FILE.gz | tail -n 5

```

### Faster way
A faster way is to NOT decompress the entire file.
For more information: https://github.com/circulosmeos/gztool

```
gztool -t FILE.gz | tail -n 5

```

### Or leave file uncompressed
```
tail -n 5 FILE.sql
```

* * *

<a name=p></a>Percona xtrabackup
-----


* https://docs.percona.com/percona-xtrabackup/2.4/howtos/recipes_ibkx_local.html


### On both source and remote servers, checl mysqld version and innobackupex version.

The versions should be the same or close. You may have to check documentation if they are compatible. The remote server should have versions that are NOT older.

```
mysqld --version
innobackup --version

```


### Make initial backup
```

  # make backups
BACKUP_DIR=/data/backups
PASSWORD="bad_passsword"

sudo innobackupex $BACKUP_DIR -u root -p$PASSWORD
  # prepare backup

sudo innobackupex --use-memory=4G --apply-log $BACKUP_DIR


  # Transfer to other computer
  # On the remote side, make sure the username has right to write to /data/backups
  # If not on REMOTE server: sudo  chown -R username /data/backups

sudo rsync -av $BACKUP_DIR username@otherserver:/data/backups

  # Log into REMOTE server
ssh username@remote_server

```
### The rest of the commands are on the REMOTE server, not the source server. 

````
  # Stop mysql and empty out directories
sudo  service mysqld stop
 # Rememeber to empty out the mysql directories


  # Copy back the data
  # Change the name of the dated directory to your date. 
sudo innobackupex --copy-back /data/backups/2010-03-13_02-42-44/

  # Change onwership, let's assume the data is under /data/mysql
sudo chown -R mysql.mysql /data/mysql


  # Start mysql, look at logfile, see if you can log in
sudo service mysqld start

  # I assume the logfile is /var/log/mysql/error.log
sudo tail -n 10 /var/log/mysql/error.log

  # enter the password when asked, and change USER to the loginname you log into mysql as
mysql -u USER -p -e "show databases"


```