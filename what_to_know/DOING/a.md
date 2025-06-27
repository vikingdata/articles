
Aurora
* Backup limits to 35B days
* Does not have relay logs.
* Performance problems, when secondaries crash. 
    * https://aws.amazon.com/blogs/database/achieve-a-high-speed-innodb-purge-on-amazon-rds-for-mysql-and-amazon-aurora-mysql/
    * Use cloudwatch to monitor replication lag.
    * Variables: io/aurora_redo_log_flush
        * RollbackSegmentHistoryListLength : number of undo records stored by the database
	* io/aurora_redo_log_flush : If this is high, lots of queries are waiting.
	* innodb_purge_threads : how many purge threads. You might want to increase this. 
* Other performance issues with auroa.
* Making changes
    * Where in console do you make changes to variables, set IAM roles for the database.
* Time travel is up to 35 days. 
    * Restore a backup for timetravel to a new cluster.
    * Restore backup and use binlogs. 

MySQL Cluster
* full table scans -- how do you configure slow log to capture it. A. queries using no index: log_queries_not_using_indexes.

* Performance
    * schema_unused_indexes
    * RollbackSegmentHistoryListLength

* HA
    * https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.AuroraHighAvailability.html
