
---
title : Database HA
author : Mark Nielsen
copyright : June 2025 
---


MySQL Cluster
==============================

_**by Mark Nielsen
Original Copyright June 2025**_

This article will grow over time. 

* [Links](#links)
* Aurora Mysql
* RDS MySQL
* MySQL
* MySQL Innodb Cluster
* MongoDB


* * *
<a name=Links></a>Links
-----
Aurora
* Monitoring
    * https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/MonitoringOverview.html
    * https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PerfInsights.html
    * https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Monitoring.OS.html
    * https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/accessing-monitoring.html
    * https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/USER_PerfInsights.EnableMySQL.html
    * https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/MonitoringAurora.html
    * https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/ams-workload-memory.html
* * *
<a name=a></a>Aurora MySQL
-----
TODO:
* Provide detailed solution methods.
* Provide detailed methods of monitoring and alarms.
* Provide brief purpose of monitoring tools and what they can do. 
* Slow log reports: pt-query digest, mysqldump slow, mysqldumpslow modifed for Percona,
   Python version of mysqldumpslow. 

### Setup
* Enable time travel to 35 days
* Enable backups to 35 days
* Enable cloud watch with Enhancd Monitoring.
* Enable Performance Insights.
* Enable the sys database.
     * Locate the performance_schema parameter and change its value to 1
*  Configuration Variables
    * Save slow log. Enable or adjust: long_query_time, log_queries_not_using_indexes,
          log_output to FILE
* Turn on Auditing	  

### Monitoring
* Run slow log reports using pt-quert-digest or mysqldumpslow.
* Use Cloudwatch and set alarms for queries, slow queries, etc. Enable Enhanced Monitoring. 
* Use Performance Insights. Monitor load, cpu activity, and other. 
* Manually, examine variables like :
    * RollbackSegmentHistoryListLength : This tells you how far behind the Read Replicas are. 
* Design a plan to predict how diskspace, cpu, memory, and queries will perform in 6 months from now. 

### Example situtaions
* Too many connections
    * Set alarms if connections hits 75%. 
* Unauthorized connections
    * Turn on Auditing and make an alarm for unaothorized access.
* High resources
    * Monitor load, cpu, disk through enhaned monitoring. Make alarms.
    * RollbackSegmentHistoryListLength
* Failed Authorizations
    * Make alarms for failed authorizations above a certain amount in a given time period.
* Restarts or severe issues.
    * Make an alarm for unplanned restarts.
* Slow queries
    * Make slow log reports.
    * Look at Show processlist.
* Memory Issues
    * Use the sys schema to run memory queries.
        * See: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/ams-workload-memory.html
* Need backups for more than 35 days.
    * Take your own backups and store them locally. You could use pt xtrabackup with incremtal backups.
    * If you don't need to backup all data.
        * OPTIONAL: set slave locally and replicate from AWS filtering only database or table you need.
	* Tell pt xtabackup only to backup certain databases or tables.
    * Backup binary logs from AWS. 