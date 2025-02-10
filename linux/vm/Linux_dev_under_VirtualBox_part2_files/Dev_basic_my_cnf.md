
[mysqld]
### General settings
server-id=__NO__
port=3306

report_host=localhost
character-set-server=latin1
collation-server=latin1_bin
transaction_isolation=READ-COMMITTED
max_connect_errors=100
explicit_defaults_for_timestamp=true
log_timestamps=system
default_authentication_plugin=mysql_native_password

slow_query_log=on
log_slow_admin_statements=on
log_slow_extra=on

# Replication settings
log-replica-updates=on
master_info_repository=table

#MyISAM
key_buffer_size=1M


# Innodb settings
transaction_isolation=READ-COMMITTED
#innodb_dedicated_server=on
innodb_undo_log_truncate=on
innodb_max_undo_log_size=1g
innodb_file_per_table=on
innodb_log_buffer_size=1m

innodb_buffer_pool_instances=1
innodb_buffer_pool_size=5242880
innodb_doublewrite=off
innodb_log_file_size=4194304

[client]


[mysql]
init-command='set autocommit=off, global transaction_isolation="read-committed"'
