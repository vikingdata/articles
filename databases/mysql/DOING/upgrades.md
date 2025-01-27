
https://www.rapydo.io/blog/mysql-5-7-vs-mysql-8-0-new-features-migration-planning-and-pre-migration-checks
https://medium.com/arzooo/upgrading-from-mysql-5-7-to-mysql-8-0-benefits-challenges-and-solutions-5791162799f4

https://medium.com/arzooo/upgrading-from-mysql-5-7-to-mysql-8-0-benefits-challenges-and-solutions-5791162799f4

https://severalnines.com/blog/moving-mysql-57-mysql-80-what-you-should-know/

https://www.percona.com/blog/mysql-8-0-vs-5-7-are-the-newer-versions-more-problematic/


* differences in variables
* diferences in engines, SQL, etc
* upgrade methods, and what to do with errors
*

SQL Differences
* Window Functions
* recursive queries
* CTE
* Descding and invisible indexes
* Roles
* Hisotgrams
* GRANT statements can no longer create accounts. 

Engine and internal Differences
* The redo log, formerly know as ib_logfile0 and ib_logfile1 are now in their own files, and should
  be specified their own directory. The new files look like '#ib_redo582' and mysql takes care of creating
  new ones. This also means temporary tables are not recorded in Created_tmp_disk_tables if they use memory
  mapped files like the TempTable engine uses for overflow temporary internal tables. It also
  doesn't affect this status variable if you create
  temporary tables with the innodb engine. TODO: CHECK THIS
* Undo logs now have their own files out of the tablespace of the tables. Rollback segements reside in undo
logs and main tablespace. 
* Security now uses plugins. Defaults to caching_sha2_password but you can still use the old method.
There are also other plugins. Also some password checking and history to accounts. 
* There is an upgrade check script and fix. TODO: check fix script.
* Upgrades in place automatically happen. TODO: Check limitations. 
* Innodb tables no longer have frm files.
* CHECK THIS : The mysql database no defaults to innodb engine and not MyISAM. 

Enhanced Differences
* information_scheman and performance_schema enhancements and sys reports
* Atomic DDL

Other new Features
* InnoDB Group replication or ClusterSets

Upgrade methods
* [Inplace](#https://dev.mysql.com/blog-archive/inplace-upgrade-from-mysql-5-7-to-mysql-8-0/)
* mysqldump restore
* load balance. Setup slaves, upgrade, failover to slaves with load balance.
* Add slave and failover one at a time.

Other Enahcements
* json
* security
* dynmaic plugin
* audit? check when added
* connection pooling

Check
* Decpreted features, variables
* Removed features, variables
* Changes in functions
* Changes in Character Set and Collation
* Data type changes
