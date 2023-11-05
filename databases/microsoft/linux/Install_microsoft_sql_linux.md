
---
title : MicroSoft SQL Install for Linux
author : Mark Nielsen
copyright : November 2023
---


MicroSoft SQL Install for Linux
==============================

_**by Mark Nielsen
Original Copyright November 2023**_

1. [Links](#links)
2. [MicroSoft SQL Install for Linux](#ms)

* * *
<a name=links></a>Linux
-----
* (DBT : Microsoft SQL Server setup)[https://docs.getdbt.com/docs/core/connect-data-platform/mssql-setup]
* (Quickstart: Install SQL Server and create a database on Ubuntu)[https://learn.microsoft.com/en-us/sql/linux/quickstart-install-connect-ubuntu?view=sql-server-ver16&tabs=ubuntu2004]
* (How to Install SQL Server on Linux Ubuntu)[https://blog.devart.com/how-to-install-sql-server-on-linux-ubuntu.html]
* (Working with the SQL Server command line sqlcmd)[https://www.sqlshack.com/working-sql-server-command-line-sqlcmd/]

* * *
<a name=ms></a>MicroSoft SQL Install for Linux
-----

* Install server and tools

```
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg
curl -fsSL https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-preview.list | sudo tee /etc/apt/sources.list.d/mssql-server-preview.list

sudo apt-get update
sudo apt-get install -y mssql-server

sudo /opt/mssql/bin/mssql-conf setup

systemctl status mssql-server --no-pager
curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list

sudo apt-get update
sudo apt-get install mssql-tools18 unixodbc-dev

sudo apt-get update
sudo apt-get install mssql-tools

```

* Post install steps
```

echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc
source ~/.bashrc

export MSPASS=Password1234 # Put in your .bashrc file and change it to another password. 

sqlcmd -S localhost -U sa -P $MSPASS -No -Q "select name from sys.databases"

sqlcmd -S localhost -U sa -P $MSPASS -No -Q "create  database DBT"

sqlcmd -S localhost -U sa -P $MSPASS -No -Q  "CREATE LOGIN DBT WITH PASSWORD = 'Password1234';"
sqlcmd -S localhost -U sa -P $MSPASS -No -Q  "CREATE USER DBT FOR LOGIN DBT;"

sqlcmd -S localhost -U sa -P $MSPASS -No -Q "create  database DBT_DB"
sqlcmd -S localhost -U sa -P $MSPASS -No -Q "ALTER AUTHORIZATION ON DATABASE::DBT_DB TO DBT;"


sqlcmd -S localhost -U DBT -P $MSPASS -No -Q "create table test1 i (i int);" -d DBT_DB

sqlcmd -S localhost -U DBT -P $MSPASS -No -Q "create table test1 (i int);" -d DBT_DB
sqlcmd -S localhost -U DBT -P $MSPASS -No -Q "SELECT * FROM INFORMATION_SCHEMA.TABLES;" -d DBT_DB
sqlcmd -S localhost -U DBT -P $MSPASS -No -Q "insert into test1 values (1)" -d DBT_DB
sqlcmd -S localhost -U DBT -P $MSPASS -No -Q "select * from test1" -d DBT_DB
sqlcmd -S localhost -U DBT -P $MSPASS -No -Q "select * from dbo.test1" -d DBT_DB
sqlcmd -S localhost -U DBT -P $MSPASS -No -Q "select * from DBT_DB.dbo.test1" 


sqlcmd -S localhost -U DBT -P $MSPASS -No -Q "select name from sys.databases;" -d DBT_DB
sqlcmd -S localhost -U DBT -P $MSPASS -No -Q "SELECT SCHEMA_NAME(1);" -d DBT_DB


echo "
insert into test1 values(2);
select * from test1



" > test.sql
sqlcmd -S localhost -U DBT -P $MSPASS -No  -d DBT_DB -i test.sql


```