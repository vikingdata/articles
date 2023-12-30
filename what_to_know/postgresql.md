-----
title : what to know PostgreSQL 12
-----

Many of these things for postgresql applies to later versions. 


* [other](#other)
* [general](#general)
* [pf](#pf)
* [fbd](#fbd)

* * *
<a name=other></a>other
-----

* [Cheatsheet](https://www.postgresonline.com/special_feature.php?sf_name=postgresql83_psql_cheatsheet&outputformat=html)
* materialized views


* * *
<a name=general></a>general
-----

## Misc
* ACID : Atomicity, Consistency, Isolation, Durability
* MVCC  : Multicurreny concurrency control
* [naming conventions](https://www.geeksforgeeks.org/postgresql-naming-conventions/)
    * table or indexes : relation
    * row : tuple
    * column : attribute
    * data block : page ( on disk)
    * Page : Buffer (when block is in memory)
* [Limits](https://www.postgresql.org/docs/current/limits.html)
    * db size : unlimited
    * no of database : int or 4 GB
    * relations per database : 1.4 billion
    * relation size : 32 TB
    * rows per table : int or 4 Billion
    * Columns : 1600
    * field size : 1 GB
    * identifier length : 63 bytes
    * indexes : unlimited
    * columns per index : 32
    * partition keys : 32
* [Page](https://www.postgresql.org/docs/current/storage-page-layout.html) : smallest unit of data storage
    * Every table and index is stored as an array of pages
    * default 8 kb
        * Changing page size needs to be recompiled
    * Any row can be stored on any page.
    * Page 
       * header : 24 bytes, general information, tells of free space pointers.
       * special space : access information . empty for ordinary tables 
       * ItemIdData : an array pairs pointing to actual items.
       * Tuple : The items themselves. 
* min requirements
    * 1 GHZ, 2 GB ram, 512 MB diskspace, super privs on windows or linux

## Architecture
* postmaseter controls processed
    * states collector
    * checkpointer - write the data buffers to disk, and files in sync. Every 5 mintes. 
    * wal writer - committed quiries goes here and saves to wal files, Write Ahead Log -- used for replication and recovery is crash??
    * auto vaccum
    * logging collector -- writes errors of startup or other to logs
    * writer
    * archiver - if wal files gets filled up, saves file to archive
# buffers : WAL, CLOG, shared

* on disk
    * archive logs
    * wal files
    * data files
    * log files
* postmaster
    * first process
    * acts as listener
    * restart other processes and monitor them
    * responsible for authentcation and authorizaion
    * spawns a new process for each connection
* Buffers
    * shared buffer
        * user cannot read or write data without going through buffer
        * Data changed here but not on disk is "dirty"
    * wal buffer
        * comitted changes are written to disk for recovery options.
        * wal segements or checkpoint segments
        * wal buffer is written to wal segments by wall writer
    * CLOG buffer
        * Keeps track of whether commands are committed
        * work memory : single sort or has table, merge commands
        * maintenance work memory in vaccum, rebuilding indexes, analyze
        * temp buffer - temporary tables in user session
* Files
     * data files
     * wal files
     * log files
     * archive logs
     * config files
     * default location on Ubuntu: TODO
* Inttialize and startup
    * linux
         * initdb -D /usr/local/pgsql/data
         * pg_ctrl -D /usr/local/pgsqldata initdb
         * systemctl stop|start|restart postgresql-12
         * also pg_ctrl stop and pg_ctrl start and pg_ctrl status
    * shutdown
        * smart : lets connections finish
        * fast  : kills connection. gracefully shutdown
        * immediate: will need recovery on restart
    * Reload and restart
        * reload reads configuration without restart, only variables that can be reloaded, 
        * restart shutdown, and restart reading new configuration
        * reload linux : system reload postgresql-12
            * pg_ctrl : select pg_reload_conf()
        * restart linux : system restart postgresql-12
    * pg_controldata -- sees status of cluster
    * 
* Databases
    * Create databaase newdb TEMPLATE template0;
        * This change template1.
        * Every new database will copy anything in template1.
        * This resets template1 database.
    * select datname, oid from pg_databases;
        This reveals the oid on disk. 
* Configuration files
    * postgresql.conf -- confgiure and manage performance of database.
        * TO see variables
            * show max_connections
            * select nanem source, boot_val, sourcefile, pending_restart from pg_settings where name='max_connections';
        * to reload : select * from pg_reload_conf();
        * select * from pf_file_settings;
            * execute this after relead
        *     
    * initdb -- creates database
    * pg catalog
    * postgresql.auto_conf
        * Saves settings for "ALTER SYSTEM Set". Overrides postgresql.conf
    * pg_ident.conf
        * Which map to use for each individual connection.
        * Maps user of opertaing system to one or more postgresql_database. Used in conjuction with pg_hba.conf
        * changes require reload
    * pg_hhba.confg
        * HBA means host based authentication
        * lists valid hostname or ip addresses for connections.
        * enables authentication
        * Can limit users to connect only from certain hosts.
    * Passswords
        * trust -- dont ask for password
        * MD5 -- ask for passsword
        * reject -- automatically reject
        * password -- same as MD5
        * crypt -- weak encryption
        * krb4 or 5 : Kerberos
	* ident -- user the ident map to map the user

* Create schema
    * Create database
        * Can specify owner,
        * can't drop if any connection is using database
            * Restrict database, kill connections, verify with pg_stat_activity the database is not being used by anybody.
    * Cannot drop users if objects are owned by them.
* create user
    * Linux: create -U postrgres -P password -S user
        * enter password for new user
	* enter passsword for postgre
    * \du in postgres prompt to list users
    * Users can connect to any database.
    * Postgresq: create user SU1 login superuser 'PASS1';
    * creatuser -U postgres --inrteractive
        * asks questions

* restrict access
    * revoke connect on database DB1 from public;


* * *
<a name=pf></a>pf
-----

* Boolean is NOT: alias for integer, you can use t or f as true or false
    * https://www.postgresql.org/docs/current/datatype-boolean.html
* 'PREPARE'/'EXECUTE' iS NOT: can only do select statements.  It is used to opitimize queries.
    * In command line, you prepare a statement. Then execute the statement with variables.
    * https://www.postgresql.org/docs/current/sql-prepare.html
* TO change password, ALTER USER user_name WITH PASSWORD 'new_password';


* * *
<a name=fbd></a>fbd

-----

* for triggers calling  a fucntion with update,
    * every row that updates calls the function.
    * Update takes place before calling the function
    * What the function does does not affect update from being executed.
* [transaction level](https://www.postgresql.org/docs/current/transaction-iso.html)
    * read uncommitted, read committed, read repeatable, Serializable
* False things on indexes:
    * Always improves queries. No not writes.
    * Unused index does not affect performance. Can affect select, does affect writes.
* [Domain](https://www.postgresql.org/docs/current/sql-createdomain.html) creates a datatype based on an exisitng type with constraints. Database specific.
    * Does not define a nampspace, and functions in and out are not needed,
    * create domain, can define default and constraints, defined column type.  
* [data types](https://www.postgresql.org/docs/current/datatype.html)
    * 'n' represents length somtimes, other times fixed with padding
    * anything can be in an array,
    * fields are 1GB size limit [limitations](https://www.postgresql.org/docs/current/limits.html)
    * geomtric is non stnadard????
    * There is not unlimited field type
* [SAVEPOINTS](https://www.postgresql.org/docs/current/sql-savepoint.html) in a transaction, you can rollback and delete everything after a savepoint.

* [Sequences](https://www.postgresql.org/docs/current/sql-createsequence.html)
    * Create sequnce and drop sequence
    * nextval is never rolled back
    * bigint size, not int
    * setval doesn't set the value, it sets the current value, but the next value will be used in the sequence the nest time its used
    * sequences can be negative, not just 0 or positive

* [Listen](https://www.postgresql.org/docs/9.1/sql-listen.html) and (notify)[https://www.postgresql.org/docs/current/sql-notify.html]  10
    * Is inside transction, notify happens at commit.
* [concat strings](https://www.postgresql.org/docs/9.1/functions-string.html) uses 'x' || 'y'
* [views](https://www.postgresql.org/docs/current/tutorial-views.html)
   * The are virtual tables and created mostly to simplify queries.
   * Create View not declare view, cannot be named the same as a table, view are permanent till dropped.
* NULL
   * IS returns t or f
   * quoting null makes a string
* EXTRA :: is for (type casting)[https://www.postgresql.org/docs/current/sql-expressions.html]
* Deletes happen after query is finished if there are conditions. Rows still exist in the query until every row has been examined.
* select with ~ is equivalent to (contains](https://www.postgresql.org/docs/current/functions-matching.html)
* (Rules)[https://www.postgresql.org/docs/current/rules.html]
    * (DO INSTEAD NOTHING)[https://www.postgresql.org/docs/current/sql-createrule.html] means nothing happens. It will never error out.
    * with DO INSTEAD NOTHING, under a few the original is not updated.
* [\copy](https://www.postgresql.org/docs/current/app-psql.html) is generally of the format "\copy TABLE FROM FILE WITH DELIMITER ","; 32
* createlang is for adding a procedurla language
* ["The information schema consists of a set of views that contain information about the objects defined in the current database"])(https://free-braindumps.com/postgresql/free-pgces-02-braindumps.html?p=10)
*  SELECT * FROM information_schema.tables;
    * list tables in defined database
    * list tables in information_schema schema
* EXTRA: [diff between database and schema](https://www.educba.com/postgresql-database-vs-schema/)
* [pg_ctl -m smart stop](https://www.postgresql.org/docs/current/server-shutdown.html)
    * SIGTERM : stops new connections, allows new connections to fnish
    * -m fast : SIGINT : stops new connections, aborts current connection
    * -m immediate : SIGQUIT : Will kill postgresql, bad shutdown, results in recovery of WAL
* [pg_ctl reload](https://www.postgresql.org/docs/current/app-pg-ctl.html)
    * sends a SIGHUP to reload config files
    * Not all variables can be reloaded, things that changes what ip addresses, ports, SSL won't be reloaded, 
* Character set enconding can be set by client_encoding in [postgresql.conf](https://www.postgresql.org/docs/current/config-setting.html)
* Databasae cluster are just tables ordered by indexes.
    * You can copy directory on disk if postregsql is stopped.
    * Upon restore, must be the same version of postgresql.
    * If you use tabelspace function, those files need to copied as well.
* Analyze will collect and save statistical information of a table.
* Users created to have permission to create other suers will become superusers and is not subject to acccesss restrictions.
* to grant select on a table to everyone: grant select on TABLE to public
* For permissions to log in
    * local refers to the socket file
    * /24 is 255.255.255.0
OA    * /16 is 255.255.0.0
* pg_ctrl will wait for disconnects with -m smart. ?????
* [To send logs to syslog](https://www.postgresql.org/docs/current/runtime-config-logging.html), in postgresql.conf: log_destination = syslog 45
    * other location: stderr, csvlog, jsonlog, and syslog
* The [locale](https://www.postgresql.org/docs/current/locale.html) is defined at initdb time. It cant be altered with create database.
* [listen_addresses](https://www.postgresql.org/docs/current/runtime-config-connection.html) will be reloaded when postgresql is restarted, not reloaded, 
* pg_dump is a command utility. postgresql must be running, can dump all or some of database. 
* To set encoding, [pg_ctrl init --encoding=VALUE](https://www.postgresql.org/docs/current/app-pg-ctl.html) or [initdb --encoding=VALUE](https://www.postgresql.org/docs/current/app-initdb.html)
* [vacuum analyze](https://www.postgresql.org/docs/current/sql-vacuum.html) will recover deleted space and reanalyze tables. 
* [CREATE SEQUENCE](https://www.postgresql.org/docs/current/sql-createsequence.html) seq_sample CACHE 20 CYCLE;
    * cycle just says how many numbers need to precached.
    * cycle means cycle from beginning when maxvalue is reached
    * next sequence number is 1
* [Views](https://www.postgresql.org/docs/current/sql-createview.html) are by default non writable. Insert, update, or delete.
* To add a a week to todays date: "SELECT CURRENT_TIMESTAMP::timestamp + '7 day'::interval;"
* prepare/execute to execute statements outside a stored procedure.
* For transction occurs, and error results in all SQL not working until you end the trasnaction
* Domains, like "create domain", creates new data types which can go into tabels. 62
* When a function is created, its executes as the person who made it.
* When inserting into views, create a rule with "do instead" and insert into aa table.


