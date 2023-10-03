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
  {https://github.com/dbt-labs/dbt-starter-project/archive/refs/heads/main.zip](https://github.com/dbt-labs/dbt-starter-project/archive/refs/heads/main.zip)
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
  * Create profile.yml to profiles/profile.yml
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

The whole point of DBT is to make complicated warehouse tables.  DBT will run any query you give it and make a table with the output. You select data from source tables to create other tables.
And you may make more tables that depend on the source tables and tables you just made.
Normally, the "source" table will have been created with data in it. In this case, we create
a table with one row.

The steps are : 
* Figure out the dependencies. The second table depends on the first. Do the first table first. 
* The first thing we do is make a table with a single entry.
   * Compile : projects/models/example/my_first_dbt_model.sql
   * Run SQL, It creates a table with a single entry. 
* The second table depends on the first. Run the query and create the 2nd table based on output of the query on the first table.
   * Compile : projects/models/example/my_second_dbt_model.sql
       * There is a "ref" that the first table needs to exist.
   * Run the query and create a second table.     

DBT simply runs select statements from source tables and create tables based on the output. But it is more complicated than that. Say you  have 500 tables
to create based on 1000 source tables. There might be lots of dependencies on which tables to create first because other tables depend on them.
DBT takes care of all the dependencies. There are also incremental updates you can do to tables instead of recreating them. 


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
