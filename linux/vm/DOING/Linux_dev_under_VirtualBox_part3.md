
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
<a name=#s></a>AWS Aurora serverless 2
-----
Goals:
* Make and destory clusters only to test.
* Maximum $50 an month if left on all the time.
* Use for an hour each day. Thus price should ne $50/24 per month, or less than $5.
* Specify minimum SPU and 10 gig diskspace.

Tasks to perform
* Input any data.
* Delete data and restore from backup.
* Add a Reader node.
* Switch writer node to a read node.
* Time travel (is possible)
* Look at Cloudwatch.
    * It should be free.
    * Turn on alarms.
* Turn on insights, perform tasks, turn off insights.
* Upload data, turn on Glue or Lamda.
    * Put data into S3.
    * Lamda process should process data into your database.
    * Make a glue script and execute.
    
