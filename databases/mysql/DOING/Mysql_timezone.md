 
---
title : MySQL Timezone
author : Mark Nielsen  
copyright : June 2024  
---


MySQL Timezone
==============================

_**by Mark Nielsen
Original Copyright september 2024**_

This is for MySQL 5.7, I believe it works in 8.0, need to test 8.4.
Will test in various versions.

1. [Links](#links)
2. [setup master-slave virtualbox](#install)
3. [test timezones](#test)

<a name=Links></a>Links
-----

* * *
<a name=install></a>setup master-slave virtualbox
-----
It is beyond this article to install Linux and MySQL in VirtualBox. Get Linux and MySQL installed on two Linux installations under VirtualBox where MySQL is setup in Master-Slave.
* https://github.com/vikingdata/articles/blob/main/databases/mysql/Multiple_MySQL_virtualbox.md

* * *
<a name=test></a> test timezones
-----
* on 5.6 in Linux
```
timedatectl status | grep "zone"
```

* on 5.6 and 8.0
```
SET GLOBAL time_zone = 'SYSTEM';
SET @@session.time_zone = "SYSTEM";

create database if not exists TEST_timezone;
use TEST_timezone;

select @t:=timediff(now(),convert_tz(now(),@@session.time_zone,'+00:00'));

drop table if exists t;
create table t (t timestamp, timezone varchar(255), note varchar(255));

drop table if exists t_now;
create table t_now (t_now timestamp, timezone varchar(255), note varchar(255));

select @n:=now();
insert into t values (@n, @t, "5.6 1: before timechange");
insert into t_now values (now(), @t, "5.6 1: before timechange");

SET GLOBAL time_zone = '+00:00';
SET @@session.time_zone = "+00:00";

insert into t values (@n, @@time_zone, "5.6 2: after timechange +00:00");
insert into t_now values (now(), @@time_zone, "5.6 2: after timechange +00:00");
 
SET GLOBAL time_zone = '+01:00';
SET @@session.time_zone = "+01:00";

insert into t values (@n, @@time_zone, "5.6 2: after timechange +01:00");
insert into t_now values (now(), @@time_zone, "5.6 2: after timechange +01:00");


```


Compare timestamps when timezones were changed.

* on 5.6 and 8.0
```
SET GLOBAL time_zone = 'SYSTEM';
SET @@session.time_zone = "SYSTEM";
select *, @@time_zone from t; Select *, @@time_zone from t_now;

SET GLOBAL time_zone = '+00:00';
SET @@session.time_zone = "+00:00";
select *,@@time_zone from t; Select *, @@time_zone from t_now;

SET GLOBAL time_zone = '+01:00';
SET @@session.time_zone = "+01:00";
select *, @@time_zone from t; Select *, @@time_zone from t_now;

select convert_tz(t,@@session.time_zone,'+00:00') from t;
select convert_tz(t_now,@@session.time_zone,'+00:00') from t_now;

```
* 5.6 output

```
mysql> select *, @@time_zone from t; Select *, @@time_zone from t_now;
+---------------------+-----------+--------------------------------+-------------+
| t                   | timezone  | note                           | @@time_zone |
+---------------------+-----------+--------------------------------+-------------+
| 2024-09-17 17:25:12 | -07:00:00 | 5.6 1: before timechange       | SYSTEM      |
| 2024-09-17 10:25:12 | +00:00    | 5.6 2: after timechange +00:00 | SYSTEM      |
| 2024-09-17 09:25:12 | +01:00    | 5.6 2: after timechange +01:00 | SYSTEM      |
+---------------------+-----------+--------------------------------+-------------+
3 rows in set (0.00 sec)

+---------------------+-----------+--------------------------------+-------------+
| t_now               | timezone  | note                           | @@time_zone |
+---------------------+-----------+--------------------------------+-------------+
| 2024-09-17 17:25:12 | -07:00:00 | 5.6 1: before timechange       | SYSTEM      |
| 2024-09-17 17:25:12 | +00:00    | 5.6 2: after timechange +00:00 | SYSTEM      |
| 2024-09-17 17:25:12 | +01:00    | 5.6 2: after timechange +01:00 | SYSTEM      |
+---------------------+-----------+--------------------------------+-------------+
3 rows in set (0.00 sec)


mysql> SET GLOBAL time_zone = '+00:00';
Query OK, 0 rows affected (0.00 sec)

mysql> SET @@session.time_zone = "+00:00";
Query OK, 0 rows affected (0.00 sec)

mysql> select *,@@time_zone from t; Select *, @@time_zone from t_now;
+---------------------+-----------+--------------------------------+-------------+
| t                   | timezone  | note                           | @@time_zone |
+---------------------+-----------+--------------------------------+-------------+
| 2024-09-18 00:25:12 | -07:00:00 | 5.6 1: before timechange       | +00:00      |
| 2024-09-17 17:25:12 | +00:00    | 5.6 2: after timechange +00:00 | +00:00      |
| 2024-09-17 16:25:12 | +01:00    | 5.6 2: after timechange +01:00 | +00:00      |
+---------------------+-----------+--------------------------------+-------------+
3 rows in set (0.00 sec)

+---------------------+-----------+--------------------------------+-------------+
| t_now               | timezone  | note                           | @@time_zone |
+---------------------+-----------+--------------------------------+-------------+
| 2024-09-18 00:25:12 | -07:00:00 | 5.6 1: before timechange       | +00:00      |
| 2024-09-18 00:25:12 | +00:00    | 5.6 2: after timechange +00:00 | +00:00      |
| 2024-09-18 00:25:12 | +01:00    | 5.6 2: after timechange +01:00 | +00:00      |
+---------------------+-----------+--------------------------------+-------------+
3 rows in set (0.00 sec)

mysql> SET GLOBAL time_zone = '+01:00';
Query OK, 0 rows affected (0.00 sec)

mysql> SET @@session.time_zone = "+01:00";
Query OK, 0 rows affected (0.00 sec)

mysql> select *, @@time_zone from t; Select *, @@time_zone from t_now;
+---------------------+-----------+--------------------------------+-------------+
| t                   | timezone  | note                           | @@time_zone |
+---------------------+-----------+--------------------------------+-------------+
| 2024-09-18 01:25:12 | -07:00:00 | 5.6 1: before timechange       | +01:00      |
| 2024-09-17 18:25:12 | +00:00    | 5.6 2: after timechange +00:00 | +01:00      |
| 2024-09-17 17:25:12 | +01:00    | 5.6 2: after timechange +01:00 | +01:00      |
+---------------------+-----------+--------------------------------+-------------+
3 rows in set (0.00 sec)

+---------------------+-----------+--------------------------------+-------------+
| t_now               | timezone  | note                           | @@time_zone |
+---------------------+-----------+--------------------------------+-------------+
| 2024-09-18 01:25:12 | -07:00:00 | 5.6 1: before timechange       | +01:00      |
| 2024-09-18 01:25:12 | +00:00    | 5.6 2: after timechange +00:00 | +01:00      |
| 2024-09-18 01:25:12 | +01:00    | 5.6 2: after timechange +01:00 | +01:00      |
+---------------------+-----------+--------------------------------+-------------+
3 rows in set (0.00 sec)

mysql>
mysql> select convert_tz(t,@@session.time_zone,'+00:00') from t;
+--------------------------------------------+
| convert_tz(t,@@session.time_zone,'+00:00') |
+--------------------------------------------+
| 2024-09-18 00:25:12                        |
| 2024-09-17 17:25:12                        |
| 2024-09-17 16:25:12                        |
+--------------------------------------------+
3 rows in set (0.00 sec)

mysql> select convert_tz(t_now,@@session.time_zone,'+00:00') from t_now;
+------------------------------------------------+
| convert_tz(t_now,@@session.time_zone,'+00:00') |
+------------------------------------------------+
| 2024-09-18 00:25:12                            |
| 2024-09-18 00:25:12                            |
| 2024-09-18 00:25:12                            |
+------------------------------------------------+
3 rows in set (0.01 sec)


```

* 5.6 conclusion



* 8.0 output
```
mysql> SET GLOBAL time_zone = 'SYSTEM';
Query OK, 0 rows affected (0.00 sec)

mysql> SET @@session.time_zone = "SYSTEM";
Query OK, 0 rows affected (0.00 sec)

mysql> select *, @@time_zone from t; Select *, @@time_zone from t_now;
+---------------------+-----------+--------------------------------+-------------+
| t                   | timezone  | note                           | @@time_zone |
+---------------------+-----------+--------------------------------+-------------+
| 2024-09-17 17:29:35 | -07:00:00 | 5.6 1: before timechange       | SYSTEM      |
| 2024-09-17 10:29:35 | +00:00    | 5.6 2: after timechange +00:00 | SYSTEM      |
| 2024-09-17 09:29:35 | +01:00    | 5.6 2: after timechange +01:00 | SYSTEM      |
+---------------------+-----------+--------------------------------+-------------+
3 rows in set (0.00 sec)

+---------------------+-----------+--------------------------------+-------------+
| t_now               | timezone  | note                           | @@time_zone |
+---------------------+-----------+--------------------------------+-------------+
| 2024-09-17 17:29:35 | -07:00:00 | 5.6 1: before timechange       | SYSTEM      |
| 2024-09-17 17:29:35 | +00:00    | 5.6 2: after timechange +00:00 | SYSTEM      |
| 2024-09-17 17:29:35 | +01:00    | 5.6 2: after timechange +01:00 | SYSTEM      |
+---------------------+-----------+--------------------------------+-------------+
3 rows in set (0.01 sec)

mysql> SET GLOBAL time_zone = '+00:00';
Query OK, 0 rows affected (0.00 sec)

mysql> SET @@session.time_zone = "+00:00";
Query OK, 0 rows affected (0.00 sec)

mysql> select *,@@time_zone from t; Select *, @@time_zone from t_now;
+---------------------+-----------+--------------------------------+-------------+
| t                   | timezone  | note                           | @@time_zone |
+---------------------+-----------+--------------------------------+-------------+
| 2024-09-18 00:29:35 | -07:00:00 | 5.6 1: before timechange       | +00:00      |
| 2024-09-17 17:29:35 | +00:00    | 5.6 2: after timechange +00:00 | +00:00      |
| 2024-09-17 16:29:35 | +01:00    | 5.6 2: after timechange +01:00 | +00:00      |
+---------------------+-----------+--------------------------------+-------------+
3 rows in set (0.00 sec)

+---------------------+-----------+--------------------------------+-------------+
| t_now               | timezone  | note                           | @@time_zone |
+---------------------+-----------+--------------------------------+-------------+
| 2024-09-18 00:29:35 | -07:00:00 | 5.6 1: before timechange       | +00:00      |
| 2024-09-18 00:29:35 | +00:00    | 5.6 2: after timechange +00:00 | +00:00      |
| 2024-09-18 00:29:35 | +01:00    | 5.6 2: after timechange +01:00 | +00:00      |
+---------------------+-----------+--------------------------------+-------------+
3 rows in set (0.00 sec)

mysql> SET GLOBAL time_zone = '+01:00';
Query OK, 0 rows affected (0.00 sec)

mysql> SET @@session.time_zone = "+01:00";
Query OK, 0 rows affected (0.00 sec)

mysql> select *, @@time_zone from t; Select *, @@time_zone from t_now;
+---------------------+-----------+--------------------------------+-------------+
| t                   | timezone  | note                           | @@time_zone |
+---------------------+-----------+--------------------------------+-------------+
| 2024-09-18 01:29:35 | -07:00:00 | 5.6 1: before timechange       | +01:00      |
| 2024-09-17 18:29:35 | +00:00    | 5.6 2: after timechange +00:00 | +01:00      |
| 2024-09-17 17:29:35 | +01:00    | 5.6 2: after timechange +01:00 | +01:00      |
+---------------------+-----------+--------------------------------+-------------+
3 rows in set (0.00 sec)

+---------------------+-----------+--------------------------------+-------------+
| t_now               | timezone  | note                           | @@time_zone |
+---------------------+-----------+--------------------------------+-------------+
| 2024-09-18 01:29:35 | -07:00:00 | 5.6 1: before timechange       | +01:00      |
| 2024-09-18 01:29:35 | +00:00    | 5.6 2: after timechange +00:00 | +01:00      |
| 2024-09-18 01:29:35 | +01:00    | 5.6 2: after timechange +01:00 | +01:00      |
+---------------------+-----------+--------------------------------+-------------+
3 rows in set (0.00 sec)

mysql> select convert_tz(t,@@session.time_zone,'+00:00') from t;
+--------------------------------------------+
| convert_tz(t,@@session.time_zone,'+00:00') |
+--------------------------------------------+
| 2024-09-18 00:29:35                        |
| 2024-09-17 17:29:35                        |
| 2024-09-17 16:29:35                        |
+--------------------------------------------+
3 rows in set (0.00 sec)

mysql> select convert_tz(t_now,@@session.time_zone,'+00:00') from t_now;
+------------------------------------------------+
| convert_tz(t_now,@@session.time_zone,'+00:00') |
+------------------------------------------------+
| 2024-09-18 00:29:35                            |
| 2024-09-18 00:29:35                            |
| 2024-09-18 00:29:35                            |
+------------------------------------------------+
3 rows in set (0.00 sec)


```
