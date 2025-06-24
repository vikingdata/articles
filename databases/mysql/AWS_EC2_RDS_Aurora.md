--------
title: AWS : EC2 vs RDS MySQL vs Aurora

--------
Being updated on 1-27-2025 (not done yet)

* [EC2](#e)
* [RDS](#r)
* [Aurora](#a)
* [Difference](#d)
* [Multi AZ](#m)
* [Aurora Techniques](#at)
-------------------------

* Links
    * [Aurora CheatSheet](https://tutorialsdojo.com/amazon-aurora/)
    * [Aurora vs RDS: How to Choose the Right AWS Database Solution](https://www.percona.com/blog/when-should-i-use-amazon-aurora-and-when-should-i-use-rds-mysql/#:~:text=Aurora%20replicates%20data%20to%20six,process%20is%20slower%20than%20Aurora.)
    * [HA databases](https://www.percona.com/blog/the-ultimate-guide-to-database-high-availability/)
    * [AWS RDS MySQL vs. Aurora MySQL](https://houseofbrick.com/blog/aws-rds-mysql-vs-aurora-mysql/)
    * [Aurora vs. RDS: An Engineer’s Guide to Choosing a Database](https://www.lastweekinaws.com/blog/aurora-vs-rds-an-engineers-guide-to-choosing-a-database/#:~:text=You%20use%20a%20database%20engine,RDS%20is%20your%20only%20choice.)
    * [AWS — Difference between Amazon Aurora and Amazon RDS](https://medium.com/awesome-cloud/aws-difference-between-amazon-aurora-and-amazon-rds-comparison-aws-aurora-vs-aws-rds-databases-60a69dbec41f#:~:text=In%20RDS%2C%20Failover%20to%20read,time%20is%20faster%20on%20Aurora.)

* * *
<a name=e></a>EC2
-----

* EC2
    * You install and maintain your own system. It is like a computer in your own data center. You have many operating systems to choose from. 
    * Backups, monitoring, etc are all on you.
    * You don't have to upgrade MySQL if you don't want to. You can put any version on it.
* * *
<a name=r></a>RDS MySQL
-----

* RDS MySQL
    * It is a MySQL service.
    * Its has Cloudwatch monitoring.
    * There is DMS to migrate MySQL to RDS MySQL.
    * Supports versions 5.7 and 8.0.
       * [Recent supported versions](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/MySQL.Concepts.VersionMgmt.html#MySQL.Concepts.VersionMgmt.Supported)
    * Backups are automatic.
    * Resizing is allowed.
    * Adding Read Replicas is easy.
    * Point in time recovery (time travel).
    * Caching, like memcache or ElasticCache is available.
    * [Features not supported](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/MySQL.Concepts.FeatureSupport.html#MySQL.Concepts.Features)
    * [Limitations](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/MySQL.KnownIssuesAndLimitations.html)
    * Automatic failover is available.
        * 60 to 120 seconds
    * Replication to Read Replica is done by normal MySQL replication.
    * Storage auto scaling available vertically.

* * *
<a name=a></a>Aurora
-----


* Aurora
    * It is a MySQL service.
    * Its has Cloudwatch monitoring.
    * There is DMS to migrate MySQL to RDS MySQL.
    * Supports versions 5.7 and 8.0.
    * Backups are automatic.
    * Resizing is allowed.
    * Adding Read Replicas is easy.
    * Caching, like memcache or ElasticCache is available.
    * Features not supported [5.7](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.CompareMySQL57.html]
    and [8.0](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.MySQL80.html)
    * Automatic failover is available
        * 60 seconds, even 30 seconds.
    * Aurora has auto scaling vertically and horizontally.

* * *
<a name=d></a>Difference
-----

* RDS has that Aurora doesn't
    * NEW: In November 2023, RDS has group replication with version 8.0.35 and higher. This makes failover faster than aurora.     * It can use more storage engines.  

* Aurora has that RDS MySQL doesn't
    * Replication is done differently. Instead of normal MySQL replication [Aurora has faster replication](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Replication.html) because the read replicas are physical copies or primary. [Cluster Volume](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Overview.StorageReliability.html#Aurora.Overview.Storage)
    * Supposedly x5 faster than MySQL, but heavy write loads may not see the benefit. 
    * Aurora Serverless is available.
        * An on demand database.
        * Version 1 and 2
    * Parallel queries are available. Queries are divided among all the servers.
    * Data is copied to 3 Availability Zones, with each Availability Zone persisting 2 copies of each write.
    * Backtrack for Aurora MySQL -- time travel. Lets you go back to a previous state in time of the database.
    * Encryption at rest is available. Affects Backups and snapshots.
    * Aurora has auto scaling read replicas. It will spin up read replicas if needed automatically.
    * Aurora is also PostgreSQL compatible.
    * Can have upto 15 read replicas, while RDS MySQL can have 5.
    * Built For High Availability. Multiple copies in different Availability zones makes it HA along with automatic failover. 
    * Except for Group replication, failover in Aurora in faster than RDS.
* Future topics
  * cost
  * Aurora Serverless versus Aurora
  * more performance
  * Links on what to maintain in RDS MySQL and Aurora. 
  * Different versions of Aurora and Aurora DSL and serverless.
  * Update this doc.
  * Different security layers. 

* * *
<a name=m></a>Multi AZ
-----

	
 * Multi AZ
     * RDS
         * Use normal replication with semi-synchronous to the other 2 AZs. Thus
         there is one server in each of the 3 locations with committed data for each transaction.
         The rest of the servers are synchronous (delayed).
         * Scale up to 64 Tib
         * Automatic Failover with Standby Instance (Multi AZ). If not its done manually. 
     * Aurora
         * Cloud native design for syncing data.
         * Built in fault tolerance and automatic
        failover whether Multi AZ or not. Failover is faster than RDS. 
         * Better performance and higher limit on diskspace.
         * Data is on 3 AZ or availability zones in a region. 
* * *
<a name=at>Aurora Techniques
-----

### Online Schema Change

Links
* https://aws.amazon.com/blogs/database/deploy-schema-changes-in-an-amazon-aurora-mysql-database-with-minimal-downtime/
* https://orangematter.solarwinds.com/2017/01/27/three-things-that-differentiate-amazon-aurora-from-mysql/

* Use Online schema change in RDS or Aurora where possible. Instance DDL in Aurora 3.
    * Aurora Fast DLL seems faster than MySQL online DDL. Aurora's fast dll can be done in transactions. 
* Use pt-schema change.
* Use Blue/Green Deployments Aurora in AWS. Basically, it uses regular replication from one environment to another.
    * Make schema changes backwards compatible with software.
    * After you make schema changes in the NEW cluster, let the software run for a few days to make sure
    there are no errors in replication.
    * https://aws.amazon.com/blogs/database/deploy-schema-changes-in-an-amazon-aurora-mysql-database-with-minimal-downtime/
    * https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/blue-green-deployments-overview.html
    * https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/blue-green-deployments-switching.html


### Data Migration
Links
* 
    