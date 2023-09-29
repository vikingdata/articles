# What to know : MySQL et

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

* to install audit, mysql < audit_log_filter_linux_install.sql

* ADMIN OPTION with role just grants the ability to give and revoke role to other users. 20

* Data Dictionary  Holds information about database objects
   * table, view, and stored procedure definitions
   * server configuration rollback
   * triggers
   * NOT users, user groups, privs, roles
   * Physical partitions, files, backups
   * size of tables, indexes, and no of rows


