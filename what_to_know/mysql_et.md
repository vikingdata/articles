# What to know : MySQL et

* * *

* <a name=et></a>et
* <a name=other></a>other
-----

* https://dev.mysql.com/doc/refman/8.4/en/server-system-variable-reference.html
* https://dev.mysql.com/doc/refman/8.4/en/server-system-variables.html
* https://dev.mysql.com/doc/refman/8.4/en/server-status-variables.html
* TODO: replication and other variable links. 
* * *
<a name=et></a>et
-----

* Spatial index for spaital column. https://dev.mysql.com/doc/refman/8.4/en/create-index.html


* characterstics of role : can be dropped, is locked, granted to users

* to reset GTID replication on slave if someone added data
   1. reset naster On slave
   2. SET GLOBAL gtid_purged to the purged values of slave.
   3. SET GLOBAL gtid_executed to values execued in the thread.
   4. Make sure the master still has the data.
https://www.percona.com/blog/how-to-createrestore-a-slave-using-gtid-replication-in-mysql-5-6/
   5. Test by entering bad command in slave and then reset.

* With more memeory then data and no binlog, what improvements an you do? innodb_flush_log_at_trx_commit=2
    * innodb_doublewrite=0
    * innodb_undo_directory=/dev/shm --- undo logs in memory
    * NO:  sync_binlog=0 - normally yes, but binlog isn't used.
    * NO : trx commit is already 2, 0 would be faster.
    * More memory might help
    * larger innodb_file_size -- help organize things to commit

* persistent stats : optimizer saved acrosss restarts, when innodb_stats_persistent_sample_pages is increased it improves precision on execution plans of transient index statistics
    * innodb_stats_auto_recalc causes new indexes and if data is changed more then 10% to be updated

* enterprise firewall can1. read incoming queries to create a whitelist, blocking queries by pre approved whitelists
  https://www.mysql.com/products/enterprise/firewall.html

* Slave can fall behind master, because the slave is configured to be single thread and the master is mutiple queries
at a time. Master might be too busy, but transferring the binlog is fast. Tables not having primary keys can also cause issues. 

* For --ssl-mode, lowest to highest security, DISABLED, preferrred, required, verify_ca, verify_identity

* kill -9 is bad, kill -15 mysql will tell it to stop and gracefully shutdown

* To stop sql injection, preprared staements, stored procedures, validate input, escaped input
    * https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html
    * Connection Control plugin limits connections, nothing to do with sql injection

* No roles are active by default. They need to be activated or set as default.

* mysqlbinlog can use rewrite to rewrite queries for a database
  mysqlbinlog --rewrite-db='db1->db2'
  https://dev.mysql.com/doc/refman/8.0/en/mysqlbinlog.html#option_mysqlbinlog_rewrite-db
  Its also best to use the --database option. Rewrite comes first. So rewrite db1->db2 and then databases db2.

* dba.rebootClusterFromCompleteOutage() will attempt to start the node the shell is connected to and the cluster
based on the latest meta data. Only a majority are servers need to be up. Only starts the nodes on the clsuter,
does not restart. 
https://dev.mysql.com/doc/dev/mysqlsh-api-javascript/8.0/classmysqlsh_1_1dba_1_1_dba.html#ac68556e9a8e909423baa47dc3b42aadb


* Multi source replication use relay_log_recovery to resolve crashes, does not resolve conflicts between 2 replication
streams.

* to install audit, mysql < audit_log_filter_linux_install.sql : https://dev.mysql.com/doc/mysql-secure-deployment-guide/5.7/en/secure-deployment-audit.html

* ADMIN OPTION with role just grants the ability to give and revoke role to other users. 20

* Data Dictionary  Holds information about database objects
   * table, view, and stored procedure definitions
   * ??? server configuration rollback
   * triggers
   * NOT users, user groups, privs, roles
   * Physical partitions, files, backups
   * size of tables, indexes, and no of rows
   * https://dev.mysql.com/doc/refman/8.0/en/data-dictionary-information-schema.html
   * https://downloads.mysql.com/docs/mysql-infoschema-excerpt-8.0-en.pdf

^ When restoring an innodb cluster, to get rid of the running gitd plugin for updating purge
  * when dumping, -set-gtid-purged=OFF or Remove the @@GLOBAL.gtid_purged statement from the dump file

* for TDE, the right keyring plugin will keeps keys stored in a central location and table keys can be regenerated fro mmaster key

* innodb_directories=’/innodb_extras’ allows for sacnning other directories for innodb tablespaced.

* mysql_config_editor can be used to store credentials, but it is not foolproof. 

* mysqlbackup only innodb files with backup id and  ib_logfile files.  ib_logfile which contains data if things changes during backup.
https://dev.mysql.com/doc/mysql-enterprise-backup/4.1/en/meb-files-backed-up-innodb.html  

* For DDL changes. a serialized copy is kept in SDI in json format, a copy is stored in tablespace for innodb tables


* Snapshots: No recovery is usually necessary. If copied into anoher system, can be brought up immediately.
They can greatly reduce time. 

* To run multiple mysql instances: Docker, different systemd settings, use different options for each instance and
different systemd settings can specify different startup configs. 29

* For a 5 group replication, 3 disconnected and 2 connected, You should hust them all down and writing is down, so you need
manual commands to remove the 3 non-connected servers and make the group just the 2 nodes. Check first if the 3 nodes are
truly down and have not gotten data relative to the 2 nodes.

* If the datadir becomes world readable, writable, executable : Data could be altered, config files could be altered.

* TO lock accounts
    * ALTER USER ... ACCOUNT LOCK;
    * ALTER USER .... IDENTIFIED WITH mysql_no_login;
    
* To convert from normal replication to GTID
    * Restart MySQL (master and slave) with these options enabled:--gtid_mode=ON –log-bin –log-slave-updates –enforce-gtid-consistency
    * On the slave, alter the MySQL master connection setting with: CHANGE MASTER TO MASTER_AUTO_POSITION = 1;
    * MAYBE : RESET SLAVE; START SLAVE GTID_NEXT=AUTOMATIC;

* MySQL with -- protocol can have the options 36
   * TCP, socket
   * For windows, pipe, memory

* locks from data_locks
    * lock_type : record or table
    * lock_mode : S Shared (reads are okay), X is exclusive (everything is blocked) 

* In order to replicat
    * TCP/IP connections only
    * Each server must have a unique server ID.
    * Master must have binary logs turned on. 

* mysql_config_editor
    * manages configuration of client including storing of other things. 
    * Uses [client] in config files for user. 

* explain analyze
    * https://www.percona.com/blog/using-explain-analyze-in-mysql-8/
    * https://dev.mysql.com/worklog/task/?id=4168
    * https://dev.mysql.com/blog-archive/mysql-explain-analyze/

* mysqlpump excludes
      * Does not dump performance_schema, ndbinfo, or sys, schema_information


* to ensure X.509-compliant certificate  use
   * VERIFY_IDENTITY
   * VERIFY_CA

* username and password settings
    * .mylogin.cnf use by mysql_config_editor
    * $HOME/.my.cnf -- clear teat values
    * $HOME/.mysqlrc -- maybe-- its not officially documented
    * Maybe /etc/my.cnf but not $MYSQL_HOME/my.cnf

* by default roles and internal accounts are locked 49

* binlogs are pulled from master, and just record changes are master.

* mysqlpump --exclude-databases=% --users backups user accounts

* locks
    * shared S -- allows reading of rows
    * exlcudive X -- row is locked for read and writes
    * terms
         * shread_write - shared on table, write on row
	 * HARED, SHARED_HIGH_PRIO, SHARED_READ, SHARED_WRITE, SHARED_UPGRADABLE, SHARED_NO_WRITE, SHARED_NO_READ_WRITE, or EXCLUSIVE.
    * https://dev.mysql.com/blog-archive/innodb-data-locking-part-1-introduction/
    * https://dev.mysql.com/blog-archive/innodb-data-locking-part-2-locks/

* ibdata1 has table data and primary indexes (primary index is how data is written)

56 -- skip

* Mandatory roles
    * Can't be dropped.
    * Dropping tow more more rolls will fail for all if one role doesn't exist.

* Proxy : Grant users to masquerade as another user. 58
   * When defined as proxy, ignore your permissions, you adopt the other account.
   * SELECT USER(), CURRENT_USER(), @@proxy_user;
      * user is the account that is logged in
      * current_user is the proxy user
      * ''@'' is proxy is used, otherwise NULL 

* TDE keeps the data encrypted in memory until it is needed.
  Blob type can be encrypted.
  Does not interfere with transportable tablespaces.
  data is not decryopted in memory, except temporarily when processed.
  Data is encrypted on disk, memory, and over network. 

* AFTER RPM installation, you need to initialize data directory, and for PERCONA password can be found in log file.
  rpm is split many rpms, password might not be in log file. 

* for mysqlpump, ro backup databases that it doesn't normally backup
   * mysqlpump --include-databases=% > full-backup-$(date +%Y%m$d).sql
   * or use --databases
   * Backups done in parallel
   * database not normally inlcuded : performance_schema, ndbinfo, or sys, information_schema, and mysql accounts
   * to dump accounts : mysqlpump --exclude-databases=% --users

* binlog dump, is on master. It acquires a lock to send data to slaves.

* Ways to show indexes
  *  SELECT * FROM information_schema.statistics WHERE table_schema=’?' AND TABLE_NAME=’?’;
  * SHOW INDEXES FROM TABLE;
  * show crate table TABLE;


* on Windows three ways to connect  Pipe, memory, tcpip.

skip 65

* mysqldump all databases delete logs, will delete all but last binlog and dump all databases except sys, iformation_schema,
and performance_schema

* to force error logs. rename and flush


* For importing tabls:
    * MyISAM
	* cp TBALE.MY* /var/lib/mysql/DB/ # This copies the twp miysam files
	* import the sdi from backup ; IMPORT TABLE FROM  '/tmp/mysql-files/TABLE.sdi'
    * Innodb
        * export tables and cfg file is created(contains meta data).
        * Copy over ibd and cfg to destination
        * unlock table on source. 
        * use DB; ALTER TABLE TABLE1 IMPORT TABLESPACE;

* Global variables : key_buffer_size, table_open_cache,  innodb_buffer_pool_size 77

* Memory, MyISAM, and archive don't rollback. 

* MySQLcheck will do a read lock for check, write lock for others, and renaming the binary will do repair. 


* MySQL monitoring agentless, query analysis, 

* MySQL clone plugin has limitations. Only Innodb and other limitations. 

* To stop an account from acessing 86
   * ALTER USER 'user'@'%' ACCOUNT LOCK
   * ALTER USER 'user'@'%' IDENTIFIED BY '*expired*' PASSWORD EXPIRE

* mysqlbackup with backup_to_image, backs the file to image, and backup_dir holds meta data and other

* mysql --print-defaults hows option files and the order they are read

* mysqld --help --verbose also shows the cnf files and in which order they are read.

* Use on master binlog-ignore-db to reduce traffic to slave. Slave filters will still get the commands, and just not execute them. It doesn't reduce traffic that way.

* --upgrade=FORCE checks everything, do if auto errors out.

* tablspace : innodb temporary tables, undo, data . NOT redo.

* semi stnchronus replication with slave. rpl_semi_sync_master_timeout  not reached and the master crashes
   * no data loss
   * slave is ready for reads, and if configured, can take writes 102

* For control plugin, if SET GLOBAL connection_control_min_connection_delay is set higher than SET GLOBAL connection_control_max_connection_delay it errors out.

* mysql enterprise backup does
    * incemental backups
    * hot backups, col backups
    * [https://www.mysql.com/products/enterprise/backup/features.html](https://www.mysql.com/products/enterprise/backup/features.html)

* mysqlbackup with only-known-file-types backups up mysql files and known storage engines

* mysqlbackup with optimistic-busy-tables does not backup redo, ungo log or system tablespaces. Does not tables.
   * no nonactive tables, does not backup redo, ungo log or system tablespaces. Does not lock tables.
   * busy table are then normally backedup, with redo and others,. 

* seconds behind - "dNot A, not the last transaction of the master. It deals with the current sql being applied. 
"difference between the current timestamp on the replica and the original timestamp logged on the source for the event currently being processed on the replica."

* SSL for cluster, SSL must be defined when clsuter is made, or it must be destroyed and reset.

* encrypting binary logs can be set dynamic, and requires keyring plugin

* clean shutdown, if files are deleted, need mysql.ibd and ibdata1

* mysqld-auto.cnf is in jsonb format and read at the end of files, and represents persistent variables

* I you have enough memory, below max connections, and trx is 2, two variables to speed up innodb_log_file_size=1G and innodb_doublewrite=0.
    * innodb_log_file_size=1G because default is 50 megs 


* for hash joins, The smallest of the tables in the join must fit in memory as set by join_buffer_size.

* data dictionary holds information schema : LRU buffer cache, views, stored procedures. No to performance, access lists, or configuration 128

* MySQL Installer: only for windows, most application installed, gui driven

* For buffer pool
    * "In general, when setting innodb_buffer_pool_instances, it's a good idea to match the maximum number of MySQL threads that will be running simultaneously."

* indexes on functions
   * ALTER TABLE TABLE1 ADD INDEX ((MONTH(date)));
   * ALTER TABLE TABLE1 ADD COLUMN month tinyint unsigned GENERATED ALWAYS AS (MONTH(date)) VIRTUAL NOT NULL, ADD INDEX (_month);

* visiblke is mysql databsae : help topics, timezone,




* Increasing innodb_stats_persistent_sample_pages is better for persistent index stats




* * *

<a name=u1></a>u1
-----



* * *

<a name=u2></a>u2

-----


* * *

<a name=other></a>other

-----
* performance_schema
* How locks are assigned
* Master/Slave Failover
    * General
       * NOTE : the source code looks OLD for MHA. 
       * (How to Automatically Manage Failover of the MySQL Database for Moodle) [https://severalnines.com/blog/how-to-automatically-manage-failover-mysql-database-moodle/]
    * MHA
        * [https://github.com/yoshinorim/mha4mysql-manager] (https://github.com/yoshinorim/mha4mysql-manager)
	* [Google MHA] (https://code.google.com/archive/p/mysql-master-ha/wikis)
        * [Using MHA (Master High Availability)] (https://severalnines.com/blog/how-to-automatically-manage-failover-mysql-database-moodle/#:~:text=Using%20Orchestrator&text=This%20is%20an%20open%20source,can%20be%20easy%20or%20straightforward.)
        * [A Brief Intro To MHA (Master High Availability)] (https://severalnines.com/blog/top-common-issues-mha-and-how-fix-them/) 
        * [Replication and auto-failover made easy with MySQL Utilities] (https://dev.mysql.com/blog-archive/replication-and-auto-failover-made-easy-with-mysql-utilities/)
        * [MHA MySQL Quick Start Guide] (https://www.percona.com/blog/mha-quickstart-guide/)	
    * KeepAlive
        * [KeeepAlive] (http://exabig.com/blog/2019/06/16/mysql-auto-failover-using-keepalived/)
    * ClusterControl
        * [ClusterControl] (https://docs.severalnines.com/docs/clustercontrol/)
    * orchestrator
    
        * [orchestrator] (https://github.com/openark/orchestrator)

* * *
<a name=new></a>Whats New
-----

** [5.0](http://download.nust.na/pub6/mysql/doc/refman/5.0/en/mysql-nutshell.html)
* I am skipping this list. A lot of the stuff is already assumed to exist in a modern database.
* (SHOW ENGINE INNODB STATUS)[https://dev.mysql.com/doc/refman/8.0/en/show-engine.html]
    * SHOW ENGINE INNODB MUTEX
    * SHOW ENGINE PERFORMANCE_SCHEMA STATUS
* (show engines)[https://dev.mysql.com/doc/refman/8.0/en/show-engines.html]

** [5.1](http://download.nust.na/pub6/mysql/doc/refman/5.1/en/mysql-nutshell.html#:~:text=MySQL%205.1%20provides%20much%20more,PROCESSLIST%20%2C%20ENGINES%20%2C%20and%20PLUGINS%20.)
* I am skipping most of this.
* XML

* [5.4](http://download.nust.na/pub6/mysql/doc/refman/5.4/en/mysql-nutshell.html#:~:text=MySQL%205.4%20takes%20advantage%20of,InnoDB%20I%2FO%20Subsystem%20changes.)
* I am going to skip mos fo this.
* innodb_adaptive_flushing
* innodb_thread_concurrency

** [5.5](https://www.sitepoint.com/whats-new-in-mysql-55/)
* [Semi-synchronous replication](https://dev.mysql.com/doc/refman/8.0/en/replication-semisync.html)

** [5.6](https://www.percona.com/blog/mysql-5-6-improvements-in-the-nutshell/)
* GIID replication
* Separate Tablespaces for Innodb Undo Logs
* [nline DDL](https://dev.mysql.com/doc/refman/8.0/en/innodb-online-ddl-operations.html)

** [5.7](https://dev.mysql.com/doc/refman/5.7/en/mysql-nutshell.html)
* innodb_buffer_pool_size  became dynamic
* json native support
* sys database tied to prformance schema
* multiple triggers allowed
* multi source replication
* Group replication - MySQL Cluster


* (8.0)[]
* (SHOW ENGINE INNODB STATUS)[https://dev.mysql.com/doc/refman/8.0/en/show-engine.html]
    * SHOW ENGINE INNODB MUTEX
    * SHOW ENGINE PERFORMANCE_SCHEMA STATUS
* (show engines)[https://dev.mysql.com/doc/refman/8.0/en/show-engines.html]
*[Stored and virtual columns](https://dev.mysql.com/doc/refman/8.0/en/create-table-generated-columns.html)
* Data dictionary : transactonal, stores information of database objects,
* Atomic DDL
* Automtic upgrades might need force option)
* Resource management : resources given to defined groups
* TDE or table encryption
* Information_schema views on data dictionary
* "mysql system tables and data dictionary tables are now created in a single InnoDB tablespace file named mysql.ibd"
* TempTable storage engine supports storage of binary large object (BLOB) type columns.
    * [temp tables](https://dev.mysql.com/doc/refman/8.0/en/internal-temporary-tables.html)
         * For engine temptable, when temptable_max_ram is reached, it uses  temptable_max_mmap, until tmp_table_size is reached, which then goes to disk innodb tables. 
* online DDL improved


