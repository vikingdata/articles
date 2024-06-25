
---
title : MySQL Backup Restore Replication
author : Mark Nielsen
copyright : June 2024 
---

MySQL Backup Restore Replication
==============================
_**by Mark Nielsen
Original Copyright June 2024**_




Index

1. [mysqldump](#mysqldump)
    * [List events, triggers, stored procedures](#stuff)
    * [all databases](#all)
    * [all but accounts ](#data)
    * [Problems with mysqlpump](#pumpproblems)
    * [Restore](#mr)
2. [Percona Xtrabackup](#p)
    * [Backup](#pbackp)
    * [Restore](#prestore)
3. [Replication](#replication)
    * [Replication AFTER restore](#repr) 
    * [Non-gtid. Switch Slave from Master to replicate off another slave](#switchSlave)
    * [Restore and replication mismatch](#rrm) 

* * *

<a name=mysqldump></a>MySQL Dump
-----

### List events, triggers, stored procedures <a name=stuff></a>
* See if you have triggers or stored procedures
   * Unless you dump mysql and all-databases, you can ignore dumping triggers and stored procedures if you find none
```
SELECT  routine_schema,  
        routine_name,  
        routine_type 
FROM information_schema.routines 
WHERE routine_schema not in ('sys', 'mysql_innodb_cluster_metadata', 'information_schema', 'performance_schema') 
ORDER BY routine_name;

  # just trigger name
select trigger_schema, trigger_name
  from information_schema.triggers
  WHERE trigger_schema not in ('sys', 'mysql_innodb_cluster_metadata', 'information_schema', 'performance_schema');
```

### Dump all databases <a name=all></a>
* NOTE: You could also add
    * Pre.80 : --dump-slave=2
    * 8.0 : --dump-replica=2

* mysqldump pre-8.0 command, with triggers, stored procedure, and replication position, everything
```
  # pre 8.0
mysqldump -u root -p --single-transaction --events --triggers --routines --opt --all-databases \
--master-data=2 | gzip > mysqlbackup.sql.gz 

```

* mysqldump 8.0 command, with triggers, stored procedure, and replication position, everything
```
  # 8.0.26
  # needs testing
mysqldump -u root -p --single-transaction --events --triggers --routines --opt --all-databases \
--source_data=2    | gzip > mysqlbackup.sql.gz

```

### Dump all but mysql database or accounts <a name=data></a>
* You could use mysqlpump or pt-grants to get just the accounts
    * mysqlpump : ```mysqlpump -uUSER -p --exclude-databases=% --add-drop-user --users > accounts.sql" ```
    * Pt-grants : ``` pt-show-grants -uUSER --ask-pass --drop > accounts.sql```

* Get databases except mysql
    * Mysqlpump : ``` mysqlpump --user=user --password --exclude-databases=mysql --events --routines --result-file=data.sql --add-drop-ddatabase --add-drop-table ```
    * With mysqldump : 


* to make a list of databases to ignore, select databases you want and add --databases to the option. Or use mysqlpump which has an exclude option.
```

echo "
SELECT group_concat( schema_name SEPARATOR ' ')
  FROM information_schema.schemata
  where
     schema_name     not in ('sys', 'performance_schema', 'information_schema', 'mysql_innodb_cluster_metadata')
     and schema_name not in ('mysql')
     and schema_name not like '%Ignore_pattern2%';
" > select_database.sql
  # select database.sql should looke like : DATABASE_LIST='mark1 temp1 temp2'

echo "DATABASE_LIST='"` mysql -N -u root -p -e "source select_database.sql" `"'"   >>  dump_variables.sh

source dump_variables.sh
  # For 8.0.25 and later, replace --master-data with --source-data
  # Add --set-gtid-purged=on IF GTID is used and all entries in the binlogs have GTID stats.
mysqldump -u root -p --single-transaction --events --triggers --routines --opt --master_data=2 \
 --databases $DATABASE_LIST  > mysqlbackup.sql


```

   * Verify databases
```
  # Uncompressed
grep '^CREATE DATABASE' mysqlbackup.sql

  # compressed
gunzip -c mysqlbackup.sql | grep '^CREATE DATABASE"

```

### Problems with mysqlpump <a name=pumpproblems></a>
* If mysqlpump gives a weird message like it aborted, use mysqldump. MysqlPump is still good for getting accounts. 


### Restore <a name=rm><a/>

* Check if you have the exact same version of mysql and settings.
* If not, you may want to exclude mysql from the backup. You may want to use mysqlpump to get the accounts. 

```

cat mysqlbackup.sql | mysql -u root -p 2>&1 | tee restore.log

```
* Look at restore.log to make sure the restore finished.
   * Grep for errors. 


TODO: other checks : count events, triggers, stored procedures, no of DATABASES, no of tables



* * *

<a name=p></a>Percona xtrabackup
-----

### Percona Backup <a name=pbackup></a>

* https://docs.percona.com/percona-xtrabackup/2.4/howtos/recipes_ibkx_local.html
    * innobackupex command
* https://docs.percona.com/percona-xtrabackup/8.0/backup-overview.html#backup-types
    * xtrabackup command

### On both source and remote servers, check mysqld version and innobackupex version.

The versions should be the same or close. You may have to check documentation if they are compatible. The remote server should have versions that are NOT older.

```
mysqld --version
innobackup --version

```

### Method 1

#### Make initial backup
```

  # make backups
BACKUP_DIR=/data/backups
PASSWORD="bad_password"

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
#### The rest of the commands are on the REMOTE server, not the source server. 

```
  # Stop mysql and empty out directories
sudo  service mysqld stop
  # Remember to empty out the mysql directories
  # Remove ALL Mysql data files: idbdata, binlogs, relay logs, logfiles, and all data files (all databases)

  # Copy back the data
  # Change the name of the dated directory to your date. 
sudo innobackupex --copy-back /data/backups/2010-03-13_02-42-44/

```

### Method 2 -- similar to method one

#### On source server

```
   # You may need the BACKUP privilege on root, i had too
   # If Xtrabackup fails and you get backup priv message, in mysql
# mysql > grant backup_admin on *.* to root@localhost;


BACKUP_DIR=/data/backup

   # Enter password if necessary
sudo xtrabackup --target-dir $BACKUP_DIR -u root -p --backup 2>&1 | tee backup.log
sudo xtrabackup --target-dir $BACKUP_DIR --prepare 2>&1 | tail prepare.log
```

### Restore on target server <a name=prestore></a>

* Transfer files to target server.
    * Use directory /data/restore for example
* Stop Mysqld : service mysql stop
* Remove ALL Mysql data files: idbdata, binlogs, relay logs, logfiles, and all data files (all databases)
* Copy files back and restore
```
sudo xtrabackup --target-dir=/data/restore --copy-back 2>&1 | tee copy-back.log

```

### For method 1 or 2

```

  # Change ownership, let's assume the data is under /data/mysql
sudo chown -R mysql.mysql /data/mysql


# Start mysql, look at logfile, see if you can log in
sudo service mysqld start

  # I assume the logfile is /var/log/mysql/error.log
sudo tail -n 10 /var/log/mysql/error.log

  # enter the password when asked, and change USER to the loginname you log into mysql as
mysql -u USER -p -e "show databases"

```

* * *

<a name=replication></a>Replication
-----
### Replication AFTER restore.
* For GTID
    * Links
        * RPM LOCATION: https://ftpmirror.your.org/pub/percona/percona/yum/release/7/os/x86_64/
        * https://dev.mysql.com/doc/refman/8.4/en/replication-mode-change-online-enable-gtids.html
        * https://docs.percona.com/percona-xtrabackup/8.0/create-gtid-replica.html
        * We assume "GIT_MODE" is ON when the backup was performed. Also, GTID_Consistency should be ON.
    * Make sure both master and slave ON
        gtid_consistency
        * gtid_mode
	    * If GTID_MODE on slave is OFF
```
   -- on slave
SET GLOBAL gtid_mode = "OFF_PERMISSIVE";
SET GLOBAL gtid_mode = "ON_PERMSSIVE";
SET GLOBAL gtid_consistency= "ON";
SET GLOBAL gtid_mode = "ON";

```

     
### For GTID or non-GTID
* Make sure there is an account on the Master with has Replication Client as a grant. 
* From mysqldump or from xtrabackup you should get a log file and log position. It doesn't matter if its GTID or not, set replication on the SLAVE
    * Why must you do this on a GTID_MODE=ON? Because there is no guarantee all the binlogs on the master have GTID stamps. If there are, you will get "anonymous" errors in replication. 
```
   # These commands may at some point be deprecated. 
change master to master_host="<host>", master_user='<user>', master_password='<password>';

change master to master_log_file='<log file>', master_log_pos=<log postition>;
```
* Start slave
* Check replication: show slave status
    * or : while sleep 5; do clear; mysql -u root -p<PASSWORD> -e "show slave status\G" | egrep -i "running|seconds|gtid"; done


###  GTID, setting up replication from using Percona Xtrabackup
* RPM LOCATION: https://ftpmirror.your.org/pub/percona/percona/yum/release/7/os/x86_64/
* https://dev.mysql.com/doc/refman/8.4/en/replication-mode-change-online-enable-gtids.html
* https://docs.percona.com/percona-xtrabackup/8.0/create-gtid-replica.html
* We assume "GIT_MODE" is ON when the backup was performed. Also, GTID_Consistency should be ON.



TODO: GTID multiple replication, error inserting slave and it messes up replication, xtrabackup without GTID as first. Converting existing setup to GTID, master and slave.

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
change master t0 master_host='server1', MASTER_LOG_FILE='><bin_log file of of slave 1>', MASTER_LOG_POS=<binlog position of slave 1>;
```
* Start slave on slave 2 : start slave
* Check slave 2 with "show slave status\G"
* start slave on slave 1 : start slave
* Check replication on slave 1 and slave 2 : show slave status

		  
### <a name=rrm></a>Restore and replication mismatch

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
* Execute: status;
   * see if both servers match critical settings. 
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

* If all else fails, take a Percona xtrabackup, or binary backup, restore, and make sure all database, tables, and variables are the same. The reason? If you do an ALTER TABLE or create new schema, they ma not be the same.



