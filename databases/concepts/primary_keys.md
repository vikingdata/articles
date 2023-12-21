---
Title : Primary Key Summary
Author : Mark Nielsen
Copyright : December 2023
---

Primary Key Summary
===============

_**by Mark Nielsen  
Copyright December 2023**_

* * *

1. [Links](#links)
2. [General](#general)
3. [LAP, OLTP, and document based](#o)
4. [MySQL](#mysql)
5. [PostgreSQL](#pg)
6. [snowflake](#sf)
7. [MongoDB](#mongo)
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
    * [another link](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-PRIMARY-KEYS)
* [snowflake](https://docs.snowflake.com/en/sql-reference/constraints-overview)
    * [Data Clustering](https://docs.snowflake.com/en/user-guide/tables-clustering-micropartitions)
* [MongoDB](https://www.mongodb.com/docs/manual/indexes/)

* * *

<a name=general></a>General : Purpose of Primary Key in a Database
-----

In a relational database, a primary key is a unique identifier for a record in a table. Its main purposes are:

1. **Uniqueness:** Every value in the primary key column must be unique across all rows in the table. This ensures that each record can be uniquely identified by its primary key.

2. **Identification:** The primary key serves as a means to uniquely identify each record in the table. This is crucial for maintaining data integrity and for establishing relationships between tables.

3. **Indexing:** The primary key is often used to create a clustered or non-clustered index, which can improve the speed of data retrieval operations. Indexing allows the database management system to quickly locate and access specific rows based on the primary key value.

4. **Referential Integrity:** In relational databases, primary keys are used to establish relationships between tables. A primary key in one table can be referenced as a foreign key in another table, creating a link between the two tables. This enforces referential integrity, ensuring that relationships between tables are maintained and that a foreign key always points to a valid primary key.

5. **Enforcement of Entity Integrity:** The primary key constraint ensures that each record in the table is uniquely identifiable, preventing the insertion of duplicate records. This helps maintain the entity integrity of the table.

In summary, the primary key is a fundamental concept in relational databases, providing a unique and efficient way to identify and relate records within a table and across tables in a database.


Each database has an "engine" or multiple engines that determine the primary keys behaves. 

If a database "engine" allows primary key, it is generally just a unique index or key which doesn't allow nulls. 

* * *
<a name=o></a>OLAP, OLTP, and document based
-----
* OLTP : MySQL, PostgreSQL
* OLAP: Snowflake warehouse
* Document : MongoDB




### 1. OLTP (Online Transaction Processing):

- **Role:** In OLTP databases, the primary key is primarily used for transactional operations, supporting the efficient and reliable management of day-to-day transactions.
- **Properties:**
  - The primary key is typically a simple, minimal set of columns that uniquely identifies each row in a table.
    - It enforces entity integrity, ensuring that each record is unique and can be reliably identified.
      - The primary key is often used in indexing to speed up data retrieval for transactional processing.
      - **Example:** In a banking OLTP database, the account number could serve as the primary key for the "Accounts" table.

### 2. OLAP (Online Analytical Processing):

- **Role:** In OLAP databases, the primary key's role is less emphasized as compared to OLTP. OLAP databases are optimized for complex queries and analytical processing rather than transactional operations.
- **Properties:**
  - The emphasis is more on the data model and multidimensional structures for analytical reporting and decision support.
    - While OLAP databases may have primary keys, they might not be as rigorously enforced as in OLTP databases.
      - OLAP databases often use surrogate keys or composite keys for dimension tables, optimizing them for analytical queries.
      - **Example:** In a data warehousing OLAP database, a "Time" dimension may have a composite primary key consisting of date and time components.

### 3. Document Databases:

- **Role:** Document databases are NoSQL databases that store and retrieve data in a flexible, schema-less, and JSON-like format. In these databases, the concept of a primary key is adapted to the document model.
- **Properties:**
  - Each document typically has a unique identifier, serving as its primary key within a collection.
    - The primary key can be a field within the document or generated by the database system.
      - Document databases often allow for nested structures, and the primary key may apply to a subdocument or nested element.
      - **Example:** In a MongoDB document database, each document in a collection has a unique identifier called "_id," which serves as its primary key.

In summary, the role and implementation of primary keys vary based on the database type and its intended use. OLTP databases emphasize transactional integrity, OLAP databases focus on analytical processing, and document databases offer flexibility in data modeling.


* * *

<a name=MySQL></a>MySQL
-----
Primary keys depends on the engine.
* If the engines allows Auto increments
    * [Auto increments](https://dev.mysql.com/doc/refman/8.0/en/example-auto-increment.html)
    * Changing the auto increment has constraints to it and can be done with Alter Table. Engines will behave slightly different.
* InnoDB engine
    * The primary key  is the ONLY [clustered index](https://dev.mysql.com/doc/refman/8.0/en/innodb-index-types.html) in the table. The data is ordered by the Primary Key. Little or no additional diskspace is taken up.
    * The primary key is a constraint and an index. 
    * If you do not define one, an internal primary key is made. 
* MyISAM or Aria engine
    * The primary index is in its own file and adds diskspace.
    * the primary keys is a constraint and an index. 
* Archive, blackhole, CSV engines 
    * These engines do not have primary keys.




* * *

<a name=pg></a>PostgreSQL
-----
* PostgreSQL only has one engine.
* If a primary key is not made, the first unique key without nulls is used, and then an internal one is made.
* Both a constraint and an index.
* Stored as a b-tree index.
* Auto increment uses [Sequences](https://www.postgresql.org/docs/current/sql-createsequence.html) which [Serials](https://www.postgresql.org/docs/16/datatype-numeric.html#DATATYPE-SERIAL) are equivalent. 
* The value of the sequence can be changed [through functions](https://www.postgresql.org/docs/current/functions-sequence.html). 

* * *

<a name=sf></a>Snowflake
-----

* We limit these comments to Snowflake as a data warehouse.
    * We are not including [Unistore](https://www.snowflake.com/en/data-cloud/workloads/unistore/), see [pdf](https://www.snowflake.com/wp-content/uploads/2022/11/Unistore-Unites-Transactional-and-Analytical-Data-2.pdf#:~:text=Primary%20keys%20are%20unique%20identifiers,are%20provided%20but%20not%20enforced.&text=The%20constraint%20to%20build%20a,must%20provide%20a%20primary%20key.)
    * Unistore has Primary Keys (which has an index) and other indexes. It behaves more like MySQL or PostgreSQL Primary Keys.
* Snowflake warehouse
    * Does not have indexes.
    * A primary key is JUST a constraint 
         * Unique values in column
         * Only one column can have a primacy key constraint
         * Column must not contain NULLS
    * For very large tables TB, data can be optimized with [data clustering](https://docs.snowflake.com/en/user-guide/tables-clustering-micropartitions)


* * *
<a name=mongo></a>MongoDB
-----
* Does not have primary keys.
    * But you can create unique indexes. A Null can be included though. 
    * An "_id"" field is created automatically. By default it is unique.
* Index takes up additional space.
* Mongo has 2 engines
    * WiredTiger
    * memory



* * *
<a name=todo></a>To Do
-----
* Someday, add oracle, microsoft SQL, cassandra, etc