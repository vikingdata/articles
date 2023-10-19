# What to know : MySQL et

* * *

<a name=et></a>et
-----



* persistent stats : optimizer saved acrosss restarts, when innodb_stats_persistent_sample_pages is increased it improves precision on execution plans of transient index statistics

* enterprise firewall can1. read incoming queries to create a whitelist, blocking queries bvy pre approved whitelists
  https://www.mysql.com/products/enterprise/firewall.html

* Slave can fall behind master, because the slave is configured to be single thread and the master is mutiple queries
at a time. Master might be too busy, but transferring the binlog is fast. 

* For --ssl-mode, lowest to highest security, DISABLED, preferrred, required, verify_ca, verify_identity

* kill -9 is bad, kill -15 mysql will tell it to stop and gracefully shutdown

* To stop sql injection, preprared staements, stored procedures, vlidate input, escaped input
  https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html

* 15 roles are active by default. They need to be activated or set as default.

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

[[O* to install audit, mysql < audit_log_filter_linux_install.sql

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

* Backup backups up ibd and CSV files. MyISAM, other tables by other engines. FILES: frm, csv, ibd 

* For DDL changes. a serialized copy is kept in SDI in json format, a copy is stored in tablespace for innodb tables


* Snapshots: No recovery is usually necessary. If copied into anoher system, can be brought up immediately.

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

* mysqlpump excludes
      * Does not dump performance_schema, ndbinfo, or sys, schema_information


* to ensure X.509-compliant certificate  use
   * VERIFY_IDENTITY
   * VERIFY_CA

* username and password settings
    * .mylogin.cnf use by mysql_config_editor
    * $HOME/.my.cnf -- clear teat values
    * $HOME/.mysqlrc -- maybe-- its not officially documented
    * NOT /etc/my.cnf or $MYSQL_HOME/my.cnf

* by default roles and internal accounts are locked 49

* locks
    * shared S -- allows reading of rows
    * exlcudive X -- row is locked for read and writes
    * terms
         * shread_write - shared on table, write on row
	 * HARED, SHARED_HIGH_PRIO, SHARED_READ, SHARED_WRITE, SHARED_UPGRADABLE, SHARED_NO_WRITE, SHARED_NO_READ_WRITE, or EXCLUSIVE.
    * https://dev.mysql.com/blog-archive/innodb-data-locking-part-1-introduction/
    * https://dev.mysql.com/blog-archive/innodb-data-locking-part-2-locks/

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

* AFTER RPM installation, you need to initialize data directory, and password can be found in log file. 


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
