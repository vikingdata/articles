
title : Linux Dev Cloud environment
author : Mark Nielsen
copyright : Feb 2025
---


Linux Dev Cloud Environment
==============================

_**by Mark Nielsen
Original Copyright June 2025**_

The goal is to setup very cheap services on GCP and AWS. Other inexpensive cloud solutions may be added later. 

THIS ARTICLE IS NOT DONE YET, but needed for links. 

* [Links](#links)
* Setup
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
<a name=setup></a>Setup
-----
* Have an "admin" server you can log into where we will setup access from that server. For some services
we will need a computer on the remote server for access, we will still connect by making the computer
a proxy computer for our "admin" server.
* Our admin server can be setup by
  [VirtualBox](https://github.com/vikingdata/articles/blob/main/vm/Linux_db_vm_vb_part1.md),
 Dagger, another computer, or maybe emulation (cygwin or WSL
on windows). 


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
    * Backtrack will be very cheap.
    * Free backups for 7 days.
    * Free Cloud Watch Insights
    * Database Insights is cheap. RDS insights is free with 7 days of data. 
    * Multi-AZ  costs -- TODO Verify this
        *  No separate standby cost: Unlike traditional RDS instances, you don't pay for a standby instance when not actively in use.    Pay per usage: You only pay for the ACUs used during active database operations. 
    * General Steps
        * Make Aurora serverless cluster with Mutli-AZ and backtrack and Extended Insights
        * Perform actions
        * Wait a day, and then do backtrack and backup actions
        * Destory Aurora serverless cluster and remake one without Multi AZ, backtrack, and Database insights. Keep RDS insights. 
            * OPTIONAL: Keep database insights, its cheap


#### Make stuff
	    
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

#### Connect to database

* Connection to database. NOTE: You cannot connect to aurora server less unless you are inside the VPC. 
    * Through Ec2
       * EC2 should already be able to connect.
           * Make sure mysql client is installed.
	   * Look up password. TODO: how to do this
	   * Look up HOST: TODO: how to do this. 
	   * Execute : mysql -h <HOST> -u admin -p<PASS>
    * Through RDS Data API
    * Through ssh tunnel through your EC2 instance. This will enable you to connect from anywhere.

#### Setup bash
```
  ### Change user, pass, and host for your server.
  ## Make sure you are logged into the EC2 server that has
  ## network access to Aurora Serverless.
  ## You can change this user "Connected compute resources" for your Aurora Serverless. 
echo "MUSER='user'
MPASS='pass'
MHOST='XXX.YYY.rds.amazonaws.com'
" > serverless_auth.txt

source serverless_auth.txt

mysql -u $MUSER -p$MPASS -h $MHOST -e "select now()"


```

#### Steps to perform

* Input any data
```
   -- while connected inside as mysql client or other client
create database if not exists test_db;
use test_db;
create table i (i int);
insert into i values (1),(2),(3),(4),(5);


```
* Test backup and backtrack
    * Input more data and do count
    *  perform backtrack and do count
    * Perform restore from backup and do count

* Test failovers and add readers
    * Add reader
    * Failover to Reader
    * Failover to other AZ
    * Failback to original server

* Look at Cloudwatch.
    * It should be free.
        * Turn on alarms.
	* Turn on insights, perform tasks, turn off insights.

    * Turn on sdlow logs, error logs, and make some entries and look at them. 
* Upload data, turn on Glue or Lamda.
* Put data into S3.
    * Lamda process should process data into your database.
    * Make a glue script and execute.
* Turn on RDS proxy and test it

### Remake cluster

* To start over with new severless server
     * Select database cluster.
     * Make sure delete protection is off. Check by clicking on "Modify" for the cluster.
     * Make sure the databse is running.
     * Delete the cluster.
     * Wait for it to finish, and then optionally recreate the cluster. 