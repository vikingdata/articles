
title : Free Services for Mark
author : Mark Nielsen
copyright : August 2024
---


Free Cloud services for Mark
==============================

_**by Mark Nielsen
Original Copyright August 2024**_


These are Cloud services I am interested in and how to use them. Its really easy, get an account and use their dashboards.

1. [Links](#links)
2. [Summary](#s)
3. [GCP](#g)
4. [AWS](#a)
5. [MongoDB](#m)
6. [CockroachDB](#c)
7. [New Relic](#n)
8. [Snowflake](#s)

* * *
<a name=Links></a>Links
-----


* * *
<a name=s></a>Summary
-----

These services are free until you go beyond a resource limit. I don't list all the services, just the ones I am interested in. 


* * *
<a name=g></a>GCP
-----

* [GCP](https://cloud.google.com/free)
   * Storage
       * Cloud storage ; 5GB and traffic -- enough for testing
       * database
          * Big Query, pub/sub, firestore
       * Programming -- secret manager


* * *
<a name=a></a>AWS
-----

* [AWS](https://aws.amazon.com/free/?all-free-tier.sort-by=item.additionalFields.SortRank&all-free-tier.sort-order=asc&awsf.Free%20Tier%20Types=tier%23always-free&awsf.Free%20Tier%20Categories=*all)
   * Limits by usage  -- up 100%
       * database : redshift, Dynamo, SimpleDB
       * Monitoring -- cloudwatch, GLue, Key management
       * Programming -- lambda
       * Infrasturcture -- CLoudFront, Route

   * No longer
      * EC2 -- now if you make a 3 year contract, you pay per month for your ip address. GCP per month at the lowest costs is about $4 per month.
      I am paying over $10 a month with a 3 year contract. Its better to just stop using AWS and use GCP. You recupe your costs quickly.
   * There are other free services, but I am not interested in them right now.



* * *
<a name=m></a>MongoDB
-----
MongoDB is not always free on the cloud.

But you can get free monitoring : https://www.mongodb.com/docs/v4.0/administration/free-monitoring/

* * *
<a name=c></a>CockroachDB
-----

Free : https://www.cockroachlabs.com/pricing/

* Make sure you use GCP --- I believe AWS charges for traffic. Be careful what region you chose in GCP. Check the charts. 


* * *
<a name=n></a>New Relic
-----

Links
* https://newrelic.com/pricing/free-tier

Free monitoring. Be careful how often you alert and load data. You have 100 GB free a month.Reduce the checking of your servers.

Edit monitors:
* https://docs.newrelic.com/docs/synthetics/synthetic-monitoring/using-monitors/add-edit-monitors/
* In accounts: go to Synthetic Monitoring
    * edit /etc/newrelic-infra.yml
    * Use the templte at https://github.com/newrelic/infrastructure-agent/blob/master/assets/examples/infrastructure/newrelic-infra-template.yml.example
    * wget -O /etc/newrelic-infra.yml https://github.com/newrelic/infrastructure-agent/blob/master/assets/examples/infrastructure/newrelic-infra-template.yml.example
* Commands
    * Start/Stop : https://docs.newrelic.com/docs/infrastructure/install-infrastructure-agent/manage-your-agent/start-stop-restart-infrastructure-agent/
    


* * *
<a name=s></a>Snowflake
-----
You can sign up with the same email every 30 days. It means, you can make it always free, but you have to sign up again. 

https://signup.snowflake.com/

I recommend using the $2 option per month and limiting the amount of data and traffic after the free month. 

https://www.snowflake.com/en/data-cloud/pricing-options/