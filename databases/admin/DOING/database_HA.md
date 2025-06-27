
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
* https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/USER_LogAccess.MySQL.LogFileSize.html
* Monitoring
    * https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/MonitoringOverview.html
    * https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PerfInsights.html
    * https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Monitoring.OS.html 
* * *
<a name=a></a>Aurora MySQL
-----

### Setup Aurora
* Set Primary and Replicas sets.
* Set up replicas sets so that the Aurora "Cluster" is setup in 3 availability zones.
* Enable time travel to 35 days
* Enable backups to 35 days
* Enable auto scalaing for read replicas and diskspace. 


