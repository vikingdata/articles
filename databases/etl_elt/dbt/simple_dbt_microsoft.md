---
Title : Using simple dbt : MicroSoft
Author : Mark Nielsen
Copyright : Nov 2023
---

Using Simple DBT : MiciroSoft
===============

_**by Mark Nielsen  
Copyright November 2023**_

* * *

1. [Links](#links)
2. [Install DBT](#dbt)
3. [Install MicroSoft SQL for Linux](#ms)
4. [Setup DBT for Microsoft SQL](msbdt)
5. [Run simple dbt](#run)
* * *

<a name=links></a>Links
-----

* (Quickstart: Install SQL Server and create a database on Ubuntu)[https://learn.microsoft.com/en-us/sql/linux/quickstart-install-connect-ubuntu?view=sql-server-ver16&tabs=ubuntu2004]
* (DBT: Microsoft SQL Server setup)[https://docs.getdbt.com/docs/core/connect-data-platform/mssql-setup]
* [What is DBT?](https://www.getdbt.com/blog/what-exactly-is-dbt)
* [https://medium.com/@suffyan.asad1/getting-started-with-dbt-data-build-tool-a-beginners-guide-to-building-data-transformations-28e335be5f7e](https://medium.com/@suffyan.asad1/getting-started-with-dbt-data-build-tool-a-beginners-guide-to-building-data-transformations-28e335be5f7e)
* [https://www.startdataengineering.com/post/dbt-data-build-tool-tutorial/](https://www.startdataengineering.com/post/dbt-data-build-tool-tutorial/)
* [https://github.com/daihuynh/dagster_dbt_metabase_simple_solution](https://github.com/daihuynh/dagster_dbt_metabase_simple_solution)

* * *
<a name=ms></a>Install MicroSoft SQL for Linux
-----
Refer to 
[Install MicroSoft SQL for Linux](https://github.com/vikingdata/articles/blob/main/databases/microsoft/linux/Install_microsoft_sql_linux.md)

* * *
<a name=dbt></a>Install DBT
-----

Refer to  [DBT with PostgreSQL and Snowflake](dbt1-1.md)

* * *
<a name=msdbt></a>Setup DBT for Microsoft SQL
-----
Make sure module in installed, odbc installed, and setup account. 
```
pip install dbt-sqlserver
sudo apt install unixodbc-dev

export MSPASS=Password1234 # Put in your .bashrc file and change it to another password.
sqlcmd -S localhost -U sa -P $MSPASS -No -Q "create  database DBT"
sqlcmd -S localhost -U sa -P $MSPASS -No -Q  "CREATE LOGIN DBT WITH PASSWORD = 'Password1234';"
sqlcmd -S localhost -U sa -P $MSPASS -No -Q  "CREATE USER DBT FOR LOGIN DBT;"
sqlcmd -S localhost -U sa -P $MSPASS -No -Q "create  database DBT_DB"
sqlcmd -S localhost -U sa -P $MSPASS -No -Q "ALTER AUTHORIZATION ON DATABASE::DBT_DB TO DBT;"
```

Install DBT for microsoft.

```bash
cd ~/
wget https://github.com/dbt-labs/dbt-starter-project/archive/refs/heads/main.zip
unzip main.zip

mkdir -p dbt-simple-ms
mv dbt-starter-project-main dbt-simple-ms/projects
cd dbt-simple-ms
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
      type: sqlserver
      driver: 'ODBC Driver 18 for SQL Server' # (The ODBC Driver installed on your system)
      server: 127.0.0.1
      port: 1433
      database: DBT_DB
      schema: dbo
      user: DBT
      password: Password1234
      encrypt: false
" > profiles/profiles.yml

sed -i "s/version: '1.0.0'/config-version: 2\nversion: '2.0.0'/g"  projects/dbt_project.yml

```

* * *
<a name=run></a>Run dbt-simple.zip
-----


* dbt run --profiles-dir profiles --project-dir projects

Output should be similar to

```
21:23:54  [WARNING]: Deprecated functionality
The `source-paths` config has been renamed to `model-paths`.Please update your
`dbt_project.yml` configuration to reflect this change.
21:23:54  [WARNING]: Deprecated functionality
The `data-paths` config has been renamed to `seed-paths`.Please update your
`dbt_project.yml` configuration to reflect this change.
21:23:54  Running with dbt=1.4.9
21:23:54  Unable to do partial parsing because profile has changed
21:23:55  Found 2 models, 4 tests, 0 snapshots, 0 analyses, 323 macros, 0 operations, 0 seed files, 0 sources, 0 exposures, 0 metrics
21:23:55
21:23:55  Concurrency: 1 threads (target='dev')
21:23:55
21:23:55  1 of 2 START sql table model dbo.my_first_dbt_model ............................ [RUN]
21:23:55  1 of 2 OK created sql table model dbo.my_first_dbt_model ....................... [OK in 0.54s]
21:23:55  2 of 2 START sql table model dbo.my_second_dbt_model ........................... [RUN]
21:23:56  2 of 2 OK created sql table model dbo.my_second_dbt_model ...................... [OK in 0.48s]
21:23:56
21:23:56  Finished running 2 table models in 0 hours 0 minutes and 1.08 seconds (1.08s).
21:23:56
21:23:56  Completed successfully
21:23:56
21:23:56  Done. PASS=2 WARN=0 ERROR=0 SKIP=0 TOTAL=2
```