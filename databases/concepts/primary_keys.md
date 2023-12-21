---
Title : Primary Keys
Author : Mark Nielsen
Copyright : December 2023
---

Primary Keys
===============

_**by Mark Nielsen  
Copyright December 2023**_

* * *

1. [Links](#links)
2. [General](#general)
3. [MySQL](#mysql)
4. [PostgreSQL](#pg)
5. [snowflake](#sf)
6. [Snowflake example](#sf)
* * *

<a name=links></a>Links
-----
* General
    * [Technopedia](https://www.techopedia.com/definition/5547/primary-key)
    * [techtarget](https://www.techtarget.com/searchdatamanagement/definition/primary-key#:~:text=A%20primary%20key%2C%20also%20called,vehicle%20identification%20number%20(VIN).)
    * [wiki](https://en.wikipedia.org/wiki/Primary_key)
    * [w3schools](https://www.w3schools.com/sql/sql_primarykey.ASP)
* [MySQL](https://dev.mysql.com/doc/refman/8.0/en/primary-key-optimization.html)
* [Postgresql](https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-primary-key/)
* [snowflake](https://docs.snowflake.com/en/sql-reference/constraints-overview)
    * [Data Clsutering](https://docs.snowflake.com/en/user-guide/tables-clustering-micropartitions)


* * *

<a name=general></a>General
-----


## Purpose of Primary Key in a Database

In a relational database, a primary key is a unique identifier for a record in a table. Its main purposes are:

1. **Uniqueness:** Every value in the primary key column must be unique across all rows in the table. This ensures that each record can be uniquely identified by its primary key.

2. **Identification:** The primary key serves as a means to uniquely identify each record in the table. This is crucial for maintaining data integrity and for establishing relationships between tables.

3. **Indexing:** The primary key is often used to create a clustered or non-clustered index, which can improve the speed of data retrieval operations. Indexing allows the database management system to quickly locate and access specific rows based on the primary key value.

4. **Referential Integrity:** In relational databases, primary keys are used to establish relationships between tables. A primary key in one table can be referenced as a foreign key in another table, creating a link between the two tables. This enforces referential integrity, ensuring that relationships between tables are maintained and that a foreign key always points to a valid primary key.

5. **Enforcement of Entity Integrity:** The primary key constraint ensures that each record in the table is uniquely identifiable, preventing the insertion of duplicate records. This helps maintain the entity integrity of the table.

In summary, the primary key is a fundamental concept in relational databases, providing a unique and efficient way to identify and relate records within a table and across tables in a database.


Each database has an "engine" or mutltiple engines that determine the primary keys behaves. 


* * *

<a name=MySQL></a>MySQL
-----
Primary keys depends on the engine.
* If the Engine allow it, a primary key is just a unique index without nulls.
* InnoDB
    * The primary key in is the ONLY [clustered index](https://dev.mysql.com/doc/refman/8.0/en/innodb-index-types.html)
    in the table. The data is ordered by the Primary Key. Little or no additional diskspace is taken up.
* MyISAM or Aria
    * The primary index is in its own file and adds diskspace.
* Archive, blackhole, CSV
    * These engines do not have primayr keys.




* * *

<a name=general></a>General
-----


* * *

<a name=sf></a>Snowflake
-----


* We limit these coments to Snowflake as a datawarehouse.
    * We are not including [Unistore](https://www.snowflake.com/en/data-cloud/workloads/unistore/), see [pdf](https://www.snowflake.com/wp-content/uploads/2022/11/Unistore-Unites-Transactional-and-Analytical-Data-2.pdf#:~:text=Primary%20keys%20are%20unique%20identifiers,are%20provided%20but%20not%20enforced.&text=The%20constraint%20to%20build%20a,must%20provide%20a%20primary%20key.)
    * Unistore has Primary Keys (which has an index) and other indexes. It behaves more like MySQL or PostgreSQL Primary Keys.
* Snoflake warehouse
    * Snowflake does not have indexes.
    * A primary key is JUST a constraint 
         * Unqiue values in column
         * Only one column can have a primay key constraint
         * Column must not contain NULLS
    * For very large tables TB, data can beoptimized with [data clustering](https://docs.snowflake.com/en/user-guide/tables-clustering-micropartitions)