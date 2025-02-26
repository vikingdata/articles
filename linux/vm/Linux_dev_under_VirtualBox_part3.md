
title : Linux Dev environment on Windows Part 3
author : Mark Nielsen
copyright : Feb 2025
---


Linux Dev environment on Windows Part 2
==============================

_**by Mark Nielsen
Original Copyright Feb 2025**_

The goal is to setup very cheap services on GCP and AWS. Other inexpensive cloud solutions may be added later. 

* [Links](#links)
* GCP
    * Compute server
* AWS : For all the services, you make and destroy them when done to reduce costs. 
    * S3
    * [AWS Aurora serverless 2](#s)
    * Glue
    * Lambda
    * SQS
    * Redshift 
    

* * *
<a name=links></a>Links
-----

* * *
<a name=s></a>AWS Aurora serverless 2
-----

Links
* https://www.youtube.com/watch?v=ciRbXZqBl7M

Goals:
* Make and destory clusters only to test.
    * Maximum $50 an month if left on all the time.
    * Use for an hour each day. Thus price should ne $50/24 per month, or less than $5.
    * Specify minimum ACU of 0 and max 1. Make sure cluster goes down after 5 minutes of inactivity. 

* OPTIONAL: Create AWS Management Console and open the AWS Cloud9

* Create a EC2 instance with mysql 8.0.41 installed.
    * Make sure it is within the same region as the aurora serverless servers. 

* Create Aurora Serverless 2
    * Make sure you choose the same region as the EC2 server. 
    * Clickd on RDS
    * Click on create new database
    * Select Aurora mysql or postgresql compatible.
        * Select engine 3.08.1 or higher
    * Templates : Choose dev/test
    * Credentials : Create own password
        * Select : self managed
	* Enter in master password
    * Cluster Storage : No changes
    * Instance COnfiguration
       * Choose Serverless 2
       * Capacity range
           * Minimum ACU : 0
           * Maximum ACU : 1
           * This will enble pause the cluster after 5 minutes
    * Availability & durability
        * Don't create an Aurora Replica
    * Connectivity : CONNECT TO YOUR EC2 INSTANCE
        * Connect to an EC2 compute resource
             * Select your EC2 instance you made earlier.
        * Additional VPC security group
            * OPTIONAL : Choose the security groups of your EC2 server. Be careful. Especially inbound rules.
	* RDS Data API: Supposedly its free with serverless. 
            * Enable the RDS Data API
    * Database authentication
        * IAM database authentication	    

** TODO : report on whether the pausing SAVE money.

* Connection to database. NOTE: You cannot connect to aurora server less unless you are inside the VPC. 
    * Through Ec2
       * EC2 should already be able to connect.
           * Make sure mysql client is installed.
	   * Look up password. TODO: how to do this
	   * Look up HOST: TODO: how to do this. 
	   * Execute : mysql -h <HOST> -u admin -p<PASS>
    * Through RDS Data API
    * Through ssh tunnel through your EC2 instance. This will enable you to connect from anywhere.

* To start over with new severless server
     * Select database cluster.
     * Make sure delete protection is off. Check by clicking on "Modify" for the cluster. 
     * Make sure the databse is running.
     * Delete the cluster.


Tasks to perform
* Input any data.
    * Delete data and restore from backup.
* Add a Reader node.
    * Switch writer node to a read node.
* Turn on Backtrack
    * Insert data and count
    * wait
    * Add some more data and do count
    * Restore data from backtrack
        * Count should be the same as the original
    * Turn off backtrack
* Look at Cloudwatch.
    * It should be free.
        * Turn on alarms.
	* Turn on insights, perform tasks, turn off insights.

* Turn on sdlow logs, error logs, and make some entries and look at them. 
* Upload data, turn on Glue or Lamda.
* Put data into S3.
    * Lamda process should process data into your database.
    * Make a glue script and execute.


TODO multiAZ