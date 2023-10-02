---
Title : Using simple dbt
Author : Mark Nielsen
CopyRight : spt 2023
---

Using Simple DBT
===============

_**by Mark Nielsen  
Copyright june 2023**_

* * *

1. [Links](#links)
2. [Install DBT](#install)
2. [Install simple dbt](#simple)
3. [Run simple dbt](#run)

* * *

<a name=links></a>Links
-----


* [https://medium.com/@suffyan.asad1/getting-started-with-dbt-data-build-tool-a-beginners-guide-to-building-data-transformations-28e335be5f7e](https://medium.com/@suffyan.asad1/getting-started-with-dbt-data-build-tool-a-beginners-guide-to-building-data-transformations-28e335be5f7e)
* [https://www.startdataengineering.com/post/dbt-data-build-tool-tutorial/](https://www.startdataengineering.com/post/dbt-data-build-tool-tutorial/)
* [https://github.com/daihuynh/dagster_dbt_metabase_simple_solution](https://github.com/daihuynh/dagster_dbt_metabase_simple_solution)

* * *

<a name=install></a>Install DBT
-----

To install, refer to my other document [DBT install : CLI and Adapters](https://github.com/vikingdata/articles/blob/main/databases/snowflake/setup/snowflake_interfaces.md) to setup DBT for PostgreSQL and Snowflake.

We will first do this on PostgreSQL and then Snowflake. 


* * *

<a name=smple></a>Install dbt-simple.zip
-----

We Will first do this on our PostgreSQL system.


* download : https://github.com/dbt-labs/dbt-starter-project
  {https://github.com/dbt-labs/dbt-starter-project/archive/refs/heads/main.zip](https://github.com/dbt-labs/dbt-starter-project/archive/refs/heads/main.zip)
* uncompress ; unzip main.zip
* Modify files:
  * Put everything in one directory
```bash
mkdir dbt-simple
mv dbt-starter-project-main dbt-simple
cd dbt-simple
mkdir logs
mkdir dbt_packages
mkdir profiles
```
  * Create profile.yml to projectrs/profile.yml
    Change credentials if necessary. 
```text

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

```

* * *

<a name=run></a>Run dbt-simple.zip
-----

* cd dbt-simple
* ./dbt run --profiles-dir  profiles --project-dir projects


```
efault: 
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
```      