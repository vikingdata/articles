
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

### Create account

First, setup the account. We will use root as the mariadb username and password.
Since we are using VirtualBox, outside connections can't connect to MariaDB, and
root can only login locally. Still, use a different complicated password for root.

Login as root first : mysql -u root -proot
* Change your password for root and the account we will use for DBT. 
```
drop user if exists dbt@localhost;
create user if not exists dbt@localhost identified by 'dbt';
grant all privileges on dbt.* to dbt@localhost;
grant select on data.* to dbt@localhost;

create database if not exists dbt;
create database if not exists data;

show grants for dbt@localhost;
show databases like 'd%';

use data
create table account (account_id int not null auto_increment, name varchar(64), primary key (account_id));
create table sales (account_id int, amount int, index (account_id, amount));

truncate account;
truncate sales;
insert into account (name) values ('mark'),('john');
insert into sales values  (1,1),(1,5),(1,10),(2,3),(2,20),(2,40),(2,50);

```

### Install DBT

Follow just the installation part of
* https://github.com/vikingdata/articles/blob/main/databases/etl_elt/dbt/simple_dbt_postgresql_snowflake.md
* https://docs.getdbt.com/docs/core/installation-overview

### Setup DBT


```
echo "
default:
  target: dev
  outputs:
    dev:
      type: mysql
      server: localhost
      port: 3306
      schema: data
      username: dbt
      password: dbt
      ssl_disabled: True
" > profiles/profiles.yml

wget https://github.com/dbt-labs/dbt-starter-project/archive/refs/heads/main.zip
unzip main.zip

mkdir -p dbt-mariabdb_snowflake
mv dbt-starter-project-main dbt-mariadb_snowflake

cd dbt-mariabd_snowflake
mkdir logs
mkdir dbt_packages
mkdir profiles


```