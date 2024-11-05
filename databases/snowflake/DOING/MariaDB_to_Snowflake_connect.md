
title : MariaDB to Snowflake 
author : Mark Nielsen
copyright : November 2024
---


MariaDB to Snowflake 
==============================

_**by Mark Nielsen
Original Copyright November 2024**_

If this works with MariaDB, some of the techniques besides using Connect will work for MySQL also. 

There are three techniques to get your data warehouse in Snowflake.  

* This is my attempt at using DBT to make data warehouse tables on MariaDB, but MariaDB connects to
  snowflake for the data warehouse tables. This is dont via connect. DBT needs ALL the data on the same
  system in which is creates the data warehouse.
* Or, use DBT to make the data warehouse on MariaDB, and replicate that data to Snowflake. In case MariaDB has issues, I will
use standard MySQL.
* The third way is to copy the entire data to snowflake and use DBT there to make the warehouse. We will skip this as this
is already well documented. By the way, you may the data in Snowflake with the data warehouse for AI/ML.

* [Links](#links)
* [Install Linux via VirtualBox](#linux)
* [Quick install MariaDB](#mariadb)
* [DBT MariaDB](#dbt)
* [Connect](#connect)


* * *
<a name=links></a>Links
-----
* Connect MariaDB
* ODB snowflake
* https://github.com/vikingdata/articles/blob/main/linux/vm/Install_ubunu_windows_virtualbox.md
* https://www.howtoforge.com/how-to-install-latest-mariadb-database-on-ubuntu-22-04/
* https://docs.getdbt.com/docs/core/connect-data-platform/mysql-setup

* * *
<a name=linux></a>Install Linux via VirtualBox
-----
See https://github.com/vikingdata/articles/blob/main/linux/vm/Install_ubunu_windows_virtualbox.md

* * *
<a name=mariadb></a>Quick install MariaDB
-----
Stolen from : https://www.howtoforge.com/how-to-install-latest-mariadb-database-on-ubuntu-22-04/


```
sudo bash

apt-get install software-properties-common gnupg2 -y
apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'

  ### Had to change 10.8 to 10.11, 10.8 doesn't exist anymore.
add-apt-repository 'deb [arch=amd64] http://mariadb.mirror.globo.tech/repo/10.11/ubuntu jammy main'
apt-get update -y

apt-get install mariadb-server mariadb-client -y

systemctl start mariadb
systemctl enable mariadb

mysql_secure_installation
```

* * *
<a name=dbt></a>DBT MariaDB
-----
* https://docs.getdbt.com/docs/core/connect-data-platform/mysql-setup