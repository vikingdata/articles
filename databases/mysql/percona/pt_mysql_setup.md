 
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
* Use the scripts to set replication accounts are to setup replication once you can connect as root
remotely to each server to the MySQL service (not Linux by ssh). 
    * [Download mysql rep account commands](files/rep_accounts.sql)
    * [Setup replication](files/setup_mms_rep.bash)
        * Change the hostnames and ip addresses at the top of the script. 
* * *
<a name=data></a> Setup schema and other data
-----
* Log into server "db1"
```
mkdir mysql_data_setup
cd mysql_data_setup


wget https://www.mysqltutorial.org/wp-content/uploads/2023/10/mysqlsampledatabase.zip
unzip mysqlsampledatabase.zip

mysql -u root -proot -e "source mysqlsampledatabase.sql"
mysql -u root -proot -e "show tables" classicmodels

wget FILE
mysql -u root -proot -e "source FILE.sql"


```