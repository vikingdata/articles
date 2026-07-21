

* Links
    * https://docs.yugabyte.com/preview/sample-data/northwind/
    * https://www.yugabyte.com/blog/how-to-the-northwind-postgresql-sample-database-running-on-a-distributed-sql-database/
    * https://university.yugabyte.com/courses/take/yugabytedb-dba-fundamentals/lessons/42592266-on-demand-video
    * docs.google.com/presentation/d/1xxi6p8GhiJOgZcWqNhabuqwaz6FXCFQJ/edit#slide=id.p25
        * Request access


* Download and start yugabyte with instructions
    * https://download.yugabyte.com/#linux
```
wget https://software.yugabyte.com/releases/2024.2.2.2/yugabyte-2024.2.2.2-b2-linux-x86_64.tar.gz
tar xvfz yugabyte-2024.2.2.2-b2-linux-x86_64.tar.gz && cd yugabyte-2024.2.2.2/
./bin/post_install.sh
./bin/yugabyted start
```

* Download Northwind data, create database, start client program

```
wget https://raw.githubusercontent.com/yugabyte/yugabyte-db/master/sample/northwind_ddl.sql
wget https://raw.githubusercontent.com/yugabyte/yugabyte-db/master/sample/northwind_data.sql
ysqlsh  -c "CREATE DATABASE northwind;"
./bin/ysqlsh
```
* Now execute inside ysqlsh and load data northwind database
```
\c northwind
\i northwind_ddl.sql
\i northwind_data.sql

```

* Checkout Master Web UI interface : http://127.0.0.1:7000

* Yugabyte DB Anywhere
    * https://docs.yugabyte.com/preview/yugabyte-platform/install-yugabyte-platform/install-software/installer/