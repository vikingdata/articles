
title : Free Setup
author : Mark Nielsen
copyright : August 2024
---


Free Setup
==============================

_**by Mark Nielsen
Original Copyright August 2024**_


This is a way to get free setup material by first getting basic basic server from AWS or GCP.

1. AWS + GCP setup non-free
2. GCP Free
3. AWS Free 
4. Snowflake
5. Mongodb
6. Cockroach
7. New relic
8. Grafana local

* * *
<a name=g></a>AWS + GCP setup non-free
-----
Setup one server in each location, running mysql, other services, other databases. 
Setup AWS S3, which is really cheap.


* * *
<a name=g></a>GCP Free
-----
* [GCP](https://cloud.google.com/free)
Storage
    * Cloud storage ; 5GB and traffic -- enough for testing
Database
    * Big Query
    * pub/sub
    * firestore
Programming
    * secret manager
		    

* * *
<a name=a></a>AWS Free
-----


[AWS Free](https://aws.amazon.com/free/?gclid=Cj0KCQiA1Km7BhC9ARIsAFZfEIvEClUtkGLBpYAb805PJ23Ooec3uR1uURdUFUi_LwLUt_aDOrfOzUwaAoJREALw_wcB&all-free-tier.sort-by=item.additionalFields.SortRank&all-free-tier.sort-order=asc&awsf.Free%20Tier%20Types=*all&awsf.Free%20Tier%20Categories=categories%23compute&trk=6a455a6f-f7f7-4463-917f-b59707d5f462&sc_channel=ps&ef_id=Cj0KCQiA1Km7BhC9ARIsAFZfEIvEClUtkGLBpYAb805PJ23Ooec3uR1uURdUFUi_LwLUt_aDOrfOzUwaAoJREALw_wcB:G:s&s_kwcid=AL!4422!3!646547068075!p!!g!!cloud%20computing!2038862296!75709537127)

Database + Storage
  * Dynamo
  * SimpleDB
  * S3 -- used by databases and storage. It is very very cheap. x
Monitoring
   * Promethesus
   * CLoudtrail
Programming
   * Glue (between dynamo, SimpleDB, and MySQL and MongoDB on EC2)
   * Lambda (same as glue)
   * security - Key Management, Security Hub, cloudtrail,
						        * Storage -- Storage Gateway
Other
   * Route -- DNS
* Billing or admin - Organizations, control tower
							       
* * *
<a name=s></a>Snowflake
-----

* * *
<a name=m></a>MongoDB
-----

* * *
<a name=c></a>CockRoachDB
-----

* * *
<a name=r></a>New Relic
-----
To monitor all database in AWS and GCP and opetating systems when possible. If possible
services. 


* * *
<a name=c></a>Grafana
-----
To monitor all database in AWS and GCP and opetating systems when possible.
If possible services. 