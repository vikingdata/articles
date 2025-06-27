
---
title : Database Configuration
author : Mark Nielsen
copyright : June 2025 
---


Database Configuration
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
    * Authentication
        * https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/UsingWithRDS.IAMDBAuth.html
	* https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/UsingWithRDS.IAMDBAuth.Enabling.html
	* https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.IAMPolicy.html
	* https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_managed-policies.html
    * Encryption comunications
        * https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/UsingWithRDS.SSL.html

* * *
<a name=a></a>Aurora MySQL
-----

* Setup IAM authentication for accounts.
   * Enable IAM authentication for database.
   * Create IAM account.
   * Assign role to account
   * Create policy
   * Attach policy to role or permissions