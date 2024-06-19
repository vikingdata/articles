
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

Index

1. [mysqldump](#mysqldump)
    * [all databases](#all)
    * [ all but accounts ](#data)
2. [Replication non-gtid ](#replication)
    * [Non-gtid. Switch Slave from Master to replicate off another slave](#switchSlave)
3. [tail a gzip file](#tailgzip)
4. [Percona Xtrabackup](#p) 
5. [Copy ssh keys](#ssh)
6. [Restore and replication mistmatch](#rrm)

* * *

<a name=mysqldump></a>MySQL Dump
-----

### Dump all databases <a name=all></a>

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

### Dump all but mysql database or accounts <a name=data></a>
* You could use mysqlpump pr pt-grants
    * mysqlpump : ```mysqlpump -uUSER -p --exclude-databases=% --add-drop-user --users > accounts.sql" ```
    * Pt-grants : ``` pt-show-grants -uUSER --ask-pass --drop > accounts.sql```

* Get databases except mysql
    * Mysqlpump : ``` mysqlpump --user=user --password --exclude-databases=mysql --result-file=data.sql ```
    * With mysqldump : 


* to make a list of databases to ignore, select databases you want and add --databases to the option. Or use mysqlpump which has an exclude option.
```

echo "
SELECT group_concat( schema_name SEPARATOR ',')
  FROM information_schema.schemata
  where
     schema_name     not in ('sys', 'performance_schema', 'information_schema', 'mysql_innodb_cluster_metadata')
     and schema_name not in ('mysql)
     and schema_name not like '%Ignore_pattern2%';
" > select_database.sql

echo "DATABASE_LIST='"                            >  dump_variables.sh
mysql -u root -p -e "source select_database.sql" >>  dump_variables.sh 
echo "'"                                         >>  dump_variables.sh

source dump_variables.sh
mysqldump -u root -p --single-transaction --events --triggers --routines --opt --dump-replica=2 --source_data=2 \
 --databases $DATABASE_LIST | gzip > mysqlbackup_`hostname`_`date +%Y%m%d_%H%M%S`.sql.gz


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


### On both source and remote servers, check mysqld version and innobackupex version.

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

```
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

* * *
<a name=ssh></a>Copy ssh keys 
-----


* https://www.ssh.com/academy/ssh/copy-id

TODO: make key, copy, login

ssh-copy-id -i ~/.ssh/mykey user@host



* * *
<a name=rrm></a>Restore and replication mistmatch
-----
* https://www.percona.com/blog/using-mysql-8-persisted-system-variables/

When there is a mismatch in replication, check these things. `

These checks should be the same for replicating servers
* Check my.cnf on both servers
* Check persistent variables on both servers.
    * query:
```select v.VARIABLE_NAME,g.VARIABLE_VALUE current_value,p.VARIABLE_VALUE as persist_value,VARIABLE_SOURCE,VARIABLE_PATH
   from performance_schema.variables_info v
     JOIN performance_schema.persisted_variables p USING(VARIABLE_NAME)
     JOIN performance_schema.global_variables g USING(VARIABLE_NAME)\G
```
* Global variables
    * default_collation_for_utff8m4

* character

```
mysql>  show global variables like '%character%';
+-------------------------------+--------------------+
| Variable_name                 | Value              |
+-------------------------------+--------------------+
| character_set_client     | utf8mb4                             |
| character_set_connection | utf8mb4                             |
| character_set_database   | utf8mb4                             |
| character_set_filesystem | binary                              |
| character_set_results    | utf8mb4                             |
| character_set_server     | utf8mb4                             |
| character_set_system     | utf8mb3                             |
| character_sets_dir       | /usr/share/percona-server/charsets/

```

* collation
```
mysql>  show global variables like '%coll%';
+-------------------------------+--------------------+
| Variable_name                 | Value              |
+-------------------------------+--------------------+
| collation_connection          | utf8mb4_0900_ai_ci |
| collation_database            | utf8mb4_0900_ai_ci |
| collation_server              | utf8mb4_0900_ai_ci |
| default_collation_for_utf8mb4 | utf8mb4_0900_ai_ci |
+-------------------------------+--------------------+
```
 

 
* strict
```
mysql>  show global variables like '%stric%';
+--------------------+-------+
| Variable_name      | Value |
+--------------------+-------+
| innodb_strict_mode | ON    |
+--------------------+-------+
1 row in set (0.00 sec)
```
* Check create database and create table and diff them from the master to the slave.

* If all else fails, take a percona xtrabackup, or binary backup, restore, and make sure all database, tables, and variables are the same. The reason? If you do an ALTER TABLE or create new schema, they ma not be the same. 