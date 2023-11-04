---
Title : Using simple dbt
Author : Mark Nielsen
Copyright : sept 2023
---

Using Simple DBT
===============

_**by Mark Nielsen  
Copyright September 2023**_

* * *

1. [Links](#links)
2. [Install DBT](#install)
2. [Setup DBT project for PostgreSQL](#simple)
3. [Run simple dbt](#run)
4. [Explain the process](#explain)
5. [Snowflake example](#sf)
* * *

<a name=links></a>Links
-----

* [What is DBT?](https://www.getdbt.com/blog/what-exactly-is-dbt)
* [https://medium.com/@suffyan.asad1/getting-started-with-dbt-data-build-tool-a-beginners-guide-to-building-data-transformations-28e335be5f7e](https://medium.com/@suffyan.asad1/getting-started-with-dbt-data-build-tool-a-beginners-guide-to-building-data-transformations-28e335be5f7e)
* [https://www.startdataengineering.com/post/dbt-data-build-tool-tutorial/](https://www.startdataengineering.com/post/dbt-data-build-tool-tutorial/)
* [https://github.com/daihuynh/dagster_dbt_metabase_simple_solution](https://github.com/daihuynh/dagster_dbt_metabase_simple_solution)

* * *

<a name=install></a>Install DBT
-----

To install, refer to my other document [DBT install : CLI and Adapters](https://github.com/vikingdata/articles/blob/main/databases/snowflake/setup/snowflake_interfaces.md) to setup DBT for PostgreSQL and Snowflake.

We will first do this on PostgreSQL and then Snowflake. 


* * *

<a name=smple></a>Setup DBT project for PostgreSQL
-----

We Will first do this on our PostgreSQL system.


* download : https://github.com/dbt-labs/dbt-starter-project      

  [https://github.com/dbt-labs/dbt-starter-project/archive/refs/heads/main.zip](https://github.com/dbt-labs/dbt-starter-project/archive/refs/heads/main.zip)      

  wget https://github.com/dbt-labs/dbt-starter-project/archive/refs/heads/main.zip
* uncompress ; unzip main.zip
* Modify files:
  * Put everything in one directory
```bash
mkdir -p dbt-simple
mv dbt-starter-project-main dbt-simple/projects
cd dbt-simple
mkdir logs
mkdir dbt_packages
mkdir profiles
```

* Install PostgreSQL, make accounts, and make database described in [DBT install : CLI and Adapters](https://github.com/vikingdata/articles/blob/main/databases/snowflake/setup/snowflake_interfaces.md),  but just for Postgresql. 

* Create  profiles/profile.yml
    Change credentials if necessary. 
```bash
echo "
default: 
  target: dev 
  outputs:
    dev:
      client_session_keep_alive: False 
      query_tag: dbt
      type: postgres
      threads: 1
      host: 127.0.0.1
      port: 5432
      user: mark
      pass: mark
      dbname: mark_dev
      schema: public
" > profiles/profiles.yml
```

* * *

<a name=run></a>Run dbt-simple.zip
-----

* dbt run --profiles-dir  profiles --project-dir projects


The output should look like
```
01:13:25  [WARNING]: Deprecated functionality
The `source-paths` config has been renamed to `model-paths`. Please update your
`dbt_project.yml` configuration to reflect this change.
01:13:25  [WARNING]: Deprecated functionality
The `data-paths` config has been renamed to `seed-paths`. Please update your
`dbt_project.yml` configuration to reflect this change.
01:13:25  Registered adapter: postgres=1.6.2
01:13:25  Found 2 models, 4 tests, 0 sources, 0 exposures, 0 metrics, 349 macros, 0 groups, 0 semantic models
01:13:25
01:13:25  Concurrency: 1 threads (target='dev')
01:13:25
01:13:25  1 of 2 START sql table model public.my_first_dbt_model ......................... [RUN]
01:13:26  1 of 2 OK created sql table model public.my_first_dbt_model .................... [SELECT 2 in 0.13s]
01:13:26  2 of 2 START sql table model public.my_second_dbt_model ........................ [RUN]
01:13:26  2 of 2 OK created sql table model public.my_second_dbt_model ................... [SELECT 1 in 0.08s]
01:13:26
01:13:26  Finished running 2 table models in 0 hours 0 minutes and 0.28 seconds (0.28s).
01:13:26
01:13:26  Completed successfully
01:13:26
01:13:26  Done. PASS=2 WARN=0 ERROR=0 SKIP=0 TOTAL=2
```

Two tables will have been created in mark_dev.
The first one is "my_first_dbt_model" which has one row.
The second one is "my_second_dbt_model" which has one row and was dependent on the first table. 


* * *

<a name=explain></a>Explain the process
-----

The primary objective of DBT is to simplify the creation of complex warehouse tables. DBT is capable of executing any query provided to it and generating a table based on the query results. You can select data from source tables to build new tables, and these newly created tables can serve as dependencies for other tables. Typically, the "source" table already contains data, but in some cases, you may create one more more tables with
select statements that are create comments.
 * example : select 'comment1', 245, 'comment 2 this is a long sentence.";

Here's a breakdown of the steps involved:

* Identify Dependencies: Determine the dependencies between tables. In this case the second table relies on the first one. Create the sql models for the tables. In our case, they are already created under "projects/models". 

* Run dbt
   * DBT initially creates a table with a single entry. This involves compiling the SQL script found in "projects/models/example/my_first_dbt_model.sql".
   * Then, it creates the 2nd table from the first.  The SQL script found in "projects/models/example/my_second_dbt_model.sql".It selects the single row from the first table to create the second. A ref function is used to refer to the first table. DBT handle all the dependencies if you have more tables or views. 


DBT operates by executing select statements from source tables and automatically generating tables based on the query results. However, it becomes more intricate when you have to create 500 tables based on 1000 source tables. In such scenarios, numerous dependencies may determine the order in which tables should be created because other tables rely on them. DBT manages these dependencies efficiently. Additionally, DBT offers the option of incremental updates to tables instead of recreating them from scratch.


* * *

<a name=sf></a>Snowflake Example
-----

```bash
cd ~/
wget https://github.com/dbt-labs/dbt-starter-project/archive/refs/heads/main.zip
unzip main.zip

mkdir -p dbt-simple-sf
mv dbt-starter-project-main dbt-simple-sf/projects
cd dbt-simple-sf
mkdir logs
mkdir dbt_packages
mkdir profiles

   ##  Create profile.yml to profiles/profile.yml
   ## NOTE: Change credentials. Change account, user, passsword. The database "tutorial" should exist and the schema "test". 
   ## You can edit the file last and change the credentials before you run it. 
echo "
default: 
  target: dev 
  outputs:
    dev:
      type: snowflake 
      account: gqssgkg-il60579
      user: theloginxxxxx
      password: thepaswordxxxxx
      role: accountadmin  
      database: tutorial  
      warehouse: compute_wh 
      schema: test 
      threads: 4 
      client_session_keep_alive: False 
      query_tag: dbt
" > profiles/profiles.yml
```

Now run dbt, same commands
* dbt run --profiles-dir  profiles --project-dir projects

