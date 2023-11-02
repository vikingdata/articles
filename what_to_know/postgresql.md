-----
title : what to know PostgreSQL 12
-----

Many of these things for postgresql applies to later versions. 

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
        * reload reads configuration without restart
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
    