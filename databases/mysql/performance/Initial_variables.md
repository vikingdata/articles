
---
title : MySQL Initial Variables
author : Mark Nielsen
copyright : December 2023
---


MySQL Initial Vaiables
==============================

_**by Mark Nielsen
Copyright December 2023**_

1. [Links}(#links)
2. [Setup)(#setup)
3. [ariables](#variables)
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
        * [AWS RDS MySQL] (https://aws.amazon.com/blogs/database/perform-parallel-load-for-partitioned-data-into-amazon-s3-using-aws-dms/)
        * [Overview and best practices](https://hevodata.com/learn/mysql-partition/)
    * TDE - table Encryption on Disk
        * [Enterprise MySQL](https://www.mysql.com/products/enterprise/tde.html)
	* [Percona MySQL](https://www.percona.com/blog/transparent-data-encryption-tde/)

* * *
<a name=Setup></a>Setup
-----


## General
    * For large tables, use Table Partitioning or convert table to Table Partitioning. The trick is defining a primary key and the pattern for partitioning.
    * Generate slow logs reports by Percona pt-digest-query or mysqldumpslow.
    * Analyze queries using the most resources by New Relic or Solar Winds or something similar.
        * Use graphing tools to monitor performance schema.
	* Turn on performace schema.
	* (MySQL Enterprise Query Analyser](https://www.mysql.com/products/enterprise/query.html)
        * Solar Winds -- 30 day trial available. 
	    * SolarWinds Database Performance Analyzer
            * SolarWinds Database Performance Monitor
	* NOTE : new relic has a [free service](https://docs.newrelic.com/docs/accounts/accounts-billing/new-relic-one-pricing-billing/new-relic-one-pricing-billing/#:~:text=Free%20edition%20details,use%20New%20Relic%20free%2C%20forever.] with limitaions. It has slow query tools too and performance monitoring.
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
        * Aurora Clustering is usually very very fast. But, [How can I resolve common issues when using read replicas in Amazon Aurora?](https://repost.aws/knowledge-center/aurora-mysql-read-replicas]
    * Turn on Audit
    * The total size, memory, cpu, I/O needs. 
    * High Availability needs
    * Failover SLA defined and needs. 

## MySQL
    * Setup a separate for directory for binlogs, relay logs, undo logs.
    * Setup directory for general, slow, and error logs.
    * Put the data directory on its own partition.
    * USE TDE or table disk encryption as rest, if needed.
       * NOTE: AWS RDS MySQL and Aurora don't have TDE.
       * NOTE: The percona TDE requires a restart every 30 days, or it used to be.     
    * Are other engines besides InnoDB needed?

## AWS Aurora
    * Automatic backups
    * Time travel
    * Security
    * Auto horizontal and vertical scaling
    * Size of server

## AWS RDS MySQL
    * Automatic backups
    * Auto scaling vertically
    * Are other engines besides InnoDB needed.

* * *
<a name=variables></a>Variables
-----

