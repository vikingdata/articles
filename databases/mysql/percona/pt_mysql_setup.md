 
---
title : Percona MySQL Setup
author : Mark Nielsen  
copyright : January 2025  
---


Percona MySQL Setup
==============================

_**by Mark Nielsen
Original Copyright January 2025**

The purpose is to setup 3 servers for pt tools testing. You can wipe MySQL on all servers and
reinitialize. 

1. [Links](#links)
2. [setup master-master-slave](#install)
3. [Setup schema and other data](#data)

<a name=Links></a>Links
-----
* https://dev.mysql.com/doc/refman/8.4/en/create-trigger.html
    * https://stackoverflow.com/questions/13598155/how-to-disable-triggers-in-mysql
* https://dev.mysql.com/doc/refman/9.1/en/create-view.html


* * *
<a name=install></a>setup master-master-slave 
-----
* Install MySQL on three servers with replication capabilities (server-id, binlog, etc).
    * It is beyond this article to install Linux and MySQL and to setup my.cnf for replication.  
    * mysql root password on each these servers is "root" and you can connect as root remotely.
    * Make sure your servers are protected behind a firewall or isolated network.
    * Name the servers db1, db2, and db3. Or name them whatever and change the hostnames in the scripts below.
* Sample my.cnf template for each server.
    * [Sample my.cnf file](files/my.cnf_template1)
        * Change server-id for each server.
* on all 3 servers, make a login file
```
echo "
[client]
username=root
password=root
" > ~/my.cnf
```
* Use the scripts to set replication accounts are to setup replication once you can connect as root
remotely to each server to the MySQL service (not Linux by ssh). 
    * [Download mysql rep account commands](https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main/databases/mysql/percona/files/rep_accounts.sql)
    * [Setup replication](https://github.com/vikingdata/articles/blob/main/databases/mysql/percona/files/setup_mms_rep.bash)
        * Change the hostnames and ip addresses at the top of the script.
```
cd
mkdir -p  mysql_data_setup
cd mysql_data_setup
rm -f rep_accounts.sql setup_mms_rep.bash

echo "Change the ip addresses of the 3 servers.
export DB1='10.0.2.7'
export DB2='10.0.2.8'
export DB3='10.0.2.9'
"

export DB1='10.0.2.7'
export DB2='10.0.2.8'
export DB3='10.0.2.9'

echo "
[client]
username=root
password=root
" > ~/my.cnf

wget https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main/databases/mysql/percona/files/rep_accounts.sql
wget https://github.com/vikingdata/articles/blob/main/databases/mysql/percona/files/setup_mms_rep.bash

mysql -e "rep_accounts.sql"
mysql -h $DB1 -e "rep_accounts.sql"
mysql -h $DB2 -e "rep_accounts.sql"
mysql -h $DB3 -e "rep_accounts.sql"

bash setup_mms_rep.bash

```

* * *
<a name=data></a> Setup schema and other data
-----
* Log into server "db1"
```
cd
mkdir -p  mysql_data_setup
cd mysql_data_setup
rm -f mysqlsampledatabase.sql mysqlsampledatabase.zip

wget https://www.mysqltutorial.org/wp-content/uploads/2023/10/mysqlsampledatabase.zip
unzip mysqlsampledatabase.zip

mysql -u root -proot -e "source mysqlsampledatabase.sql"
mysql -u root -proot -e "show tables" classicmodels

wget https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main/databases/mysql/percona/files/sample_database.sql
mysql -u root -proot -e "source sample_database.sql"


```

* * *
<a name=checks></a> Checks
-----


```
rm -f check_databases.sql check_tables.sql
wget https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main/databases/mysql/percona/files/check_databases.sql
wget https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main/databases/mysql/percona/files/check_tables.sql

echo "change size in sql files to limit the size of databases or tables."

echo "run these commands to check
mysql -e 'source check_databases.sql' > databases.list
mysql -e 'source check_tables.sql' > tables.list
"


```