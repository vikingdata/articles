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

* Resizing warehouse. Larger for for complex workloads. More warehouses for more users or concurrent queries.

* [Reader accounts](https://docs.snowflake.com/en/user-guide/data-sharing-reader-create)
are made for other people to accesss your data wihtout having an account. You are charged for uages.

* MFA https://docs.snowflake.com/en/user-guide/security-mfa.html
  Web gui, snowsql, Python, ODBC, JDBC

* Snowflake does not charge any differnet between semi-structure or structure data. Just charged for space however used. https://docs.snowflake.com/en/user-guide/cost-understanding-data-storage

* Can unload data into structured or semi structured formats. https://docs.snowflake.com/en/user-guide/data-unload-prepare

* [meta data is stored in cloud sevices](https://docs.snowflake.com/en/user-guide/intro-key-concepts)

* You cannot delete data in failsafe, but you can turn off fail safe.

* [Virtual warehouses](https://docs.snowflake.com/en/user-guide/warehouses-multicluster.html) can be resized while running, configured to be suspended, and resumed when new queries come in.

* PUT command compressed and encrypts a file. Does not use the last stage or create a file format.

* Recreated pipes lose their load history.

* regulatory compliance requires Enterprise Edition.

* [Pipes](https://docs.snowflake.com/en/user-guide/data-load-snowpipe-rest-overview.html) can be external or internal stages.

* JDBC and ODBC drivers need snowflake specific parameters to connect.

* You can load data into snowflake by using one of the pre defined formats. You don't have to create it.

* For data loads, null values are not the same as variant values, it is recommnded to validate before load, for merge statements it is recommnded to use stage environments (static data).

* Micropartitions are about 16 MB and immutable.

* All queries get a unique id for support.
 
* [Queries will return the same result](https://docs.snowflake.com/en/user-guide/querying-persisted-results) if no data has changed within 24 hours of the first execute.

* Tables are logical views of physical data.

* [maximium size of compressed row is 16 MB](https://docs.snowflake.com/en/user-guide/data-load-considerations-prepare.html#semi-structured-data-size-limitations)

* [For smei-streuctred data, save as Variant] (https://community.snowflake.com/s/article/Performance-of-Semi-Structured-Data-Types-in-Snowflake#:~:text=Snowflake%20provides%20guidelines%20on%20handling,usage%20for%20data%20is%20unsure.)

* snowflake releases are weeekly and transparent to the user.

* Zero copying clone is like LVM snapshots. They are instaneous and don't use up diskspace unless data is changed
in clone.

* Size of warehouse is 1,2,4,8,16, etc to x-small, small, medium, large, x-large etc




