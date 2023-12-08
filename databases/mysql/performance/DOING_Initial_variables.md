
---
title : MySQL Initial Variables
author : Mark Nielsen
copyright : December 2023
---


MySQL Initial Vaiables
==============================

_**by Mark Nielsen
Copyright December 2023**_

1. [Links](#links)
2. [Setup](#setup)
3. [Variables](#variables)
    * General
    * AWS Aurora 8.0/8.1
    * AWS RDS MySQL 8.0/8.1
    * MySQL 8.0/8.1
    * 5.7 to 8.0/8.1 differences

* * *
<a name=links></a>Links
-----
* table partitioning
    * [AWS Aurora](https://docs.aws.amazon.com/dms/latest/oracle-to-aurora-mysql-migration-playbook/chap-oracle-aurora-mysql.storage.partition.html)
    * [MySLQL](https://dev.mysql.com/doc/refman/8.0/en/partitioning.html)
    * [AWS RDS MySQL](https://aws.amazon.com/blogs/database/perform-parallel-load-for-partitioned-data-into-amazon-s3-using-aws-dms/)
    * [Overview and best practices](https://hevodata.com/learn/mysql-partition/)
* TDE - table Encryption on Disk
    * [Enterprise MySQL](https://www.mysql.com/products/enterprise/tde.html)
    * [Percona MySQL](https://www.percona.com/blog/transparent-data-encryption-tde/)
* Aurora Setup
    * [Creating an Amazon Aurora DB cluster](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.CreateInstance.html)
    * [Amazon Aurora MySQL Setup Guide](https://fivetran.com/docs/databases/mysql/aurora-setup-guide)
* RDS MySQL Setup
    * [Creating and connecting to a MySQL DB instance](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_GettingStarted.CreatingConnecting.MySQL.html)
* Automation
    * Ansible
    * Terraform on AWS

* Performance
    * [MySQL Performance Cheetsheet](https://severalnines.com/blog/mysql-performance-cheat-sheet/)
    * [Best practices for configuring parameters for Amazon RDS for MySQL, part 1: Parameters related to performance](https://aws.amazon.com/blogs/database/best-practices-for-configuring-parameters-for-amazon-rds-for-mysql-part-1-parameters-related-to-performance/)
       * [part 2](https://aws.amazon.com/blogs/database/best-practices-for-configuring-parameters-for-amazon-rds-for-mysql-part-2-parameters-related-to-replication/)
       * [part 3](https://aws.amazon.com/blogs/database/best-practices-for-configuring-parameters-for-amazon-rds-for-mysql-part-3-parameters-related-to-security-operational-manageability-and-connectivity-timeout/)
* Other
    * [21 settings for RDS MySQL](https://hackmysql.com/post/21-parameter-group-values-to-change-in-amazon-rds-for-mysql/)

* * *
<a name=Setup></a>Setup
-----


## General
* For large tables, use Table Partitioning or convert table to Table Partitioning. The trick is defining a primary key and the pattern for partitioning.
* Generate slow logs reports by Percona pt-digest-query or mysqldumpslow.
* Analyze queries using the most resources by New Relic or Solar Winds or something similar.
    * Use graphing tools to monitor performance schema.
    * Turn on performace schema.
    * [MySQL Enterprise Query Analyser](https://www.mysql.com/products/enterprise/query.html)
    * Solar Winds -- 30 day trial available. 
        * SolarWinds Database Performance Analyzer
        * SolarWinds Database Performance Monitor
    * NOTE : new relic has a [free service](https://docs.newrelic.com/docs/accounts/accounts-billing/new-relic-one-pricing-billing/new-relic-one-pricing-billing/#:~:text=Free%20edition%20details,use%20New%20Relic%20free%2C%20forever.) with limitaions. It has slow query tools too and performance monitoring.
        * [Monitoring MySQL database performance with New Relic](https://newrelic.com/blog/how-to-relic/how-to-monitor-mysql)
    * AWS
        * RDS Enhanced Monitoring
        * RDS Performance Insights
        * CloudWatch
* Schema policy
    * Use pt-schema-change or [ONLINE non-blocking DDL changes for MySQL](https://dev.mysql.com/doc/refman/8.0/en/innodb-online-ddl-operations.html). This can work for AWS Aurora and AWS RDS MySQL.
    * Do schema changes and application changes on different days.
* Backup policy
    * Determine SLA for backup and diskspace required and retention.
    * Perform restoration from backup once every 6 months to a test server.
    * Determine method for backups : mysqldump, percona xtrabaxkup, enterprise backups, LVM or other snapshots, or autoamtic for AWS
* Security
    * TDE or on disk encryption at rest
        * Authorization and Authentcation modules (method)
        * Client encryption (ssl mode)
    * Slaves or secondaries : Determine the purpose of them and how many. One for ETL, one for backup, 2 or more for applications
    * Load balancing read queries amoung slaves
    * Slave delay : For MySQL semi-snyschronous in AWS RDS MySQL or your own managed MySQL.
        * For AWS RDS MySQL or your own managed servers you can use MySQL group cluster and setup a ClusterSet. There is no slave delay.
        * Aurora Clustering is usually very very fast. But, [How can I resolve common issues when using read replicas in Amazon Aurora?](https://repost.aws/knowledge-center/aurora-mysql-read-replicas)
* Turn on Audit
* The total size, memory, cpu, I/O needs. 
* High Availability needs
* Failover SLA defined and needs. 

* Automation
     * Ansible
     * Terraform on AWS
## Specific environments

### MySQL
* Setup a separate for directory for binlogs, relay logs, undo logs.
* Setup directory for general, slow, and error logs.
* Put the data directory on its own partition.
* USE TDE or table disk encryption as rest, if needed.
   * NOTE: AWS RDS MySQL and Aurora don't have TDE.
   * NOTE: The percona TDE requires a restart every 30 days, or it used to be.     
* Are other engines besides InnoDB needed?

### AWS Aurora
* Automatic backups
* Time travel
* Security
* Auto horizontal and vertical scaling
* Size of server

### AWS RDS MySQL
* Automatic backups
* Auto scaling vertically
* Are other engines besides InnoDB needed.

* * *
<a name=variables></a>Variables
-----


## General Variables

### Important Variables
* innodb_buffer_pool_size
* innodb_buffer_pool_instances
* innodb_log_file_size -- redo logs
    * this changes in 8.0/8.1
* innodb_file_per_table
* slow_query_log : turn on
* lower_case_table_names : turned on
* GTID replciation turned on (except Aurora)
   * enforce_gtid_consistency : on
   * gtid_mode : on
* performance_schema : Turn on but limited. [Deep dive performance_schema](https://www.percona.com/blog/deep-dive-into-mysqls-performance-schema/)

### Variables to watch
* table_open_cache -- should equal the number of tables and table partitions you have.
* max_connections
* thread_cache_size
* innodb_log_buffer_size
* innodb_flush_log_at_trx_commit
    * changes in 8.0/8.1
    * Watch if IO is an issue. 
* innodb_write_io_threads
* innodb_write_io_threads
* innodb_purge_threads
* long_query_time
    * Recommend 1 sec and rotate logs policy (AWS auromatic otherwise logrotate)
* innodb_io_capacity - If Innodb_buffer_pool_bytes_dirty stays high.
* innodb_rollback_on_timeout

### Only if you need to change these

* sort_buffer_size
* read_buffer_size
* read_rnd_buffer_size
* join_buffer_size
* max_heap_table_size and tmp_table_size
    * This changes in 8.0/8.1
* table_open_cache_instances
* table_definition_cache
* max_allowed_packet
* innodb_thread_concurrency
* innodb_flush_method
* innodb_stats_on_metadata
* innodb_io_capacity
* innodb_adaptive_flushing
* sync_binlog
* innodb_change_buffering
* innodb_io_capacity_max
* innodb_thread_concurrency
* slave_parallel_type : If used, slave_preserve_commit_order = 1

## Specific environments

### MySQL
* slow_log_file
* general_log

#### Aurora
* [Aurora parameters](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.Reference.ParameterGroups.html)
* [Best practices for Amazon Aurora MySQL database configuration](https://aws.amazon.com/blogs/database/best-practices-for-amazon-aurora-mysql-database-configuration/)

