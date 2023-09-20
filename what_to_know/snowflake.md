# What to know : Snowflake

* [https://community.snowflake.com/s/article/Snowflake-What-the-Cluster](https://community.snowflake.com/s/article/Snowflake-What-the-Cluster)  
  Cluster Keys are used to override Snowflakes natural clustering so that certain keys are on the same micro parition.
  Thei example :  
  ALTER TABLE UNICORNS CLUSTER BY (AGE,SIZE,LOCATION);  
  ALTER TABLE UNICORNS RECLUSTER;  

* [Snowflake mulit-cluster virutal warehouse scaling policies](https://docs.snowflake.com/en/user-guide/warehouses-multicluster)  
  Economy : Adds more clusters if query load is estimated to be more than 6 minutes.    
  Standard (default). This creates more clusters as needed  

* [A database can onlyt exist within one account.](https://docs.snowflake.com/en/sql-reference/ddl-database.html)

* [AccountAdmin should manage users and roles.](https://docs.snowflake.com/en/user-guide/security-access-control-considerations.html)

* You can bulk unload data from a table into a staging file. [Use COPY INTO](https://docs.snowflake.com/en/user-guide/data-unload-overview#bulk-unloading-using-queries)

* [Internal stages ](https://docs.snowflake.com/en/user-guide/data-load-local-file-system-create-stage)  
  user  
  table  
  named  

* Account level storgae can be monitored in the Web Interface (UI) under  Account  under Billing & Usage section

* Credit consumption by virtual warehouses is caluclated by type of warehouse and number of clusters.

* (Cluster is how data is grouped by Snowflakes micro-partitions.)[https://docs.snowflake.com/en/user-guide/tables-clustering-micropartitions.html]

* (COPY command needs a file format)[https://interworks.com/blog/hcalder/2018/07/26/the-basics-of-loading-data-into-snowflake/]

* ["user waerhouse WH1" : to set a session](https://docs.snowflake.com/en/user-guide/warehouses-tasks.html)

* [Certain items can be clone](https://docs.snowflake.com/en/sql-reference/sql/create-clone)
  Data Containment Objects  
  Databases  
  Schemas  
  Tables  
  Streams  
  Data Configuration and Transformation Objects  
  Stages  
  File Formats  
  Sequences  
  Tasks  
  and NOT users, shares

* [Resource Monitor](https://docs.snowflake.com/en/user-guide/resource-monitors) can use used to limit credits for
  resources.

* [Workloads in Snowflake : OLAP and OLTP](https://www.snowflake.com/guides/olap-vs-oltp)

* [3 layers of Snowflake: Cloud, Query Processing - warehouse, Storage](https://docs.snowflake.com/en/user-guide/intro-key-concepts)




