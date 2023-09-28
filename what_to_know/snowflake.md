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

* Shared data is read-only and can't be shared with other people.

* For hsaring, you pay for storage, they pay  computing. 53

* Data cahe is 24 hours on a compute node

* If a role is dropped, objects and tables become the property of the role that dropped them.
  https://docs.snowflake.com/en/sql-reference/sql/drop-role.html

* For connestors: https://docs.snowflake.com/en/user-guide/connecting.html

* Snowflake doesn't have upset, just insert, update, delete, merge, and truncate table.

* Query history is kept for one year 60

* Multi-Cluster Warehouse in auto-scale mode needs a mninimum and maxiumum for warehouses.
  https://docs.snowflake.com/en/user-guide/warehouses-multicluster

* snowflake is best described as a shared multi-cluster
  https://docs.snowflake.com/en/user-guide/intro-key-concepts.html
 https://www.snowflake.com/product/architecture/  

* warehouses can have auto resume and suspend, https://help.pentaho.com/Documentation/9.1/Products/Create_Snowflake_warehouse

* temporary and transient tables don't have fail safe, provisional tables do not exit, only permenent has fail-safe.

* some data is cashed that don't need a warehouse to execute
  https://blog.ippon.tech/innovative-snowflake-features-caching/


* snowpipe uses it own internal warehouses, keep tracks of files,
  https://docs.snowflake.com/en/user-guide/data-load-snowpipe-intro

* At minimum ACCOUNTADMIN should have MFA enabled.

* Users cannot see the output of queries of other users
  https://docs.snowflake.com/en/user-guide/security-access-control-considerations.html

* Pipes can be suspended and resumed
  https://docs.snowflake.com/en/user-guide/data-load-snowpipe-intro.html

* UDF are sql, python, java, or javascript
  https://docs.snowflake.com/en/sql-reference/user-defined-functions.html

* warehouse should have auto suspend turned off when you need a steady workload or no delay or lag time is needed
  https://docs.snowflake.com/en/user-guide/warehouses-considerations.html

* loading : Builk from internal or external stages, snowpipe, or the web gui, or a connector
  https://docs.snowflake.com/en/user-guide/data-load-overview.html

* auto suspend for a warehouse is after a certain time of inactivity

* Number of queries a warehouse can do is determined bvy size and no of queries.
  https://docs.snowflake.com/en/user-guide/warehouses-overview.html

* VALIDATION is an option of the COPY command, it validates and does not load data. 81

* tasks must have access to schema and Create Task privileges
   https://docs.snowflake.com/en/sql-reference/sql/create-task.html

* Scaling out if for concurency rather than performance,
  https://docs.snowflake.com/en/user-guide/warehouses-considerations#scaling-up-vs-scaling-out  
  But improvig concurrency does improve performance.

* Sharing is available on all tiers, standard, premeir, enterprise, business critical

* Exteral tables exist as reference in snowflake, and snowflake can query those tables.
https://docs.snowflake.com/en/user-guide/tables-external-intro.html

* Flatten converts a json formatted files to a dictionary.
  https://docs.snowflake.com/en/user-guide/querying-semistructured.html
  It makes pulling out fields easily. Can work on nested data.

* AWS Private Link does allow you to connect to snowflake securely
  https://docs.snowflake.com/en/user-guide/admin-security-privatelink.html

* Where is table statistics stored? SOme, min, max are in Global Services Layer. It does not store all column stats in services layer

* 90 day time travel , minimum is enterprise
  https://docs.snowflake.com/en/user-guide/intro-editions

* resizing a warehouse has no effect on running queries
  https://docs.snowflake.com/en/user-guide/warehouses-tasks.html


* The smalletst object in time travel is table 100
https://docs.snowflake.com/en/user-guide/data-time-travel.html#data-retention-period

* Virutal warehouse are billed by each second, with a minimum of 60 second startup
  https://docs.snowflake.com/en/user-guide/credits.html

* Clustering keys should be defined on multi terabyte rnage -- need reference for this.

* Snowpipe calucates costs based on per-second/per-core
  https://docs.snowflake.com/en/user-guide/data-load-snowpipe-billing

* Federated Authentication, or single sign on, is available on all editions. 

* Objects are owneed by role that created it, not user.

* Loading data can use the file formats: CSV | JSON | AVRO | ORC | PARQUET | XML
  Unloading can only be csv, json, or parquet
  https://docs.snowflake.com/en/sql-reference/sql/create-file-format

* For data sharing, it seems like the provider can only share data with consumers
  https://docs.snowflake.com/en/user-guide/data-sharing-intro

* failsafe is 7 days, not configurable, time travel is 90 days. Timetravel is 1 day, except for Enterprise. 
  https://docs.snowflake.com/en/user-guide/data-failsafe.html

* Once micro partitions are made, they are immutable
https://docs.snowflake.com/en/user-guide/tables-clustering-micropartitions

* COPY INTO STAGE in the only command to import/export data
https://docs.snowflake.com/en/user-guide/data-unload-overview

* larger warehouse might take longer to provision
https://docs.snowflake.com/en/user-guide/warehouses-considerations

* dtermning size of warehouse
  https://www.chaosgenius.io/blog/snowflake-warehouse-sizes/#:~:text=1)%20Start%20Small%20and%20Scale,SMALL%20warehouse%20and%20run%20workloads.
  https://www.analytics.today/blog/top-3-snowflake-performance-tuning-tactics

* For storage, look at tables, databases, internal stages 121

* Out of contraints, unique, primary key, foriegn key, not null ONLY not null is enforced
  https://docs.snowflake.com/en/sql-reference/constraints-overview

* File size load on web interface is 50 MB, but with python connector there is no limitation.

* Data heirarchy : account, database, schema, table

* only permanent table have fail safe, 1 day at least for all accounts

* shares are made by sql or through web gui, which uses sql behind the scene

* fail safe is automatic and can't be turned off

* For uploads, 100 MB to 250 MB compressed, split large files into smaller files, use delimiters with single or duble quotes

* INITIALLY_SUSPENDED, default false, controls if warehouse starts after created

* Cloned objects inherit children and all privs to the children. The cloned object itself does not inherit grants.

* Transient and temprary table have max 1 day for charges, drop temporary tables after a day

* A pipe can reorder columns or imit thme based on select statement.

* https://docs.snowflake.com/en/user-guide/security-column-ext-token-use 149
   data tokenization integration partner



