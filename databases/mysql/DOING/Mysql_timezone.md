 
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
* on master in Linux
```
timedatectl status | grep "zone"
```
* on slave
```
SET GLOBAL pxc_strict_mode=PERMISSIVE;
SET GLOBAL time_zone = 'SYSTEM';
SET @@session.time_zone = "SYSTEM";
```


* on master
```
SET GLOBAL pxc_strict_mode=PERMISSIVE;
SET GLOBAL time_zone = 'SYSTEM';
SET @@session.time_zone = "SYSTEM";

create database if not exists TEST_timezone;
use TEST_timezone;

select @t:=timediff(now(),convert_tz(now(),@@session.time_zone,'+00:00'));

drop table if exists t;
create table t (t timestamp, timezone varchar(255), note varchar(255));

drop table if exists t_now;
create table t_now (t timestamp, timezone varchar(255), note varchar(255));

insert into t values ('2024-01-01', @t, "master 1: before timechange");
insert into t_now values (now(), @t, "master 1: before timechange");

SET GLOBAL time_zone = '+00:00';
SET @@session.time_zone = "+00:00";

insert into t values ('2024-01-01', @@time_zone, "master 2: after timechange +00:00");
insert into t_now values (now(), @@time_zone, "master 2: after timechange +00:00");
 
SET GLOBAL time_zone = '+01:00';
SET @@session.time_zone = "+01:00";

insert into t values ('2024-01-01', @@time_zone, "master 2: after timechange +01:00");
insert into t_now values (now(), @@time_zone, "master 2: after timechange +01:00");


```

* on slave
```
use TEST_timezone;
select @t:=timediff(now(),convert_tz(now(),@@session.time_zone,'+00:00'));

insert into t values  ('2024-01-01', @t, "slave 1: before timechange");
insert into t_now values  (now(), @t, "slave 1: before timechange");

SET GLOBAL time_zone = '+00:00';
SET @@session.time_zone = "+00:00";

insert into t values  ('2024-01-01', @@time_zone, "slave 2: after timechange 1 +01:00");
insert into t_now values  (now(), @@time_zone, "slave 2: after timechange 1 +01:00");

SET GLOBAL time_zone = '+01:00';
SET @@session.time_zone = "+01:00";

insert into t values  ('2024-01-01', @@time_zone, "slave 3: after timechange 1 +00:00");
insert into t_now values  (now(), @@time_zone, "slave 3: after timechange 1 +00:00");

stop slave;
start slave;
show slave status\G
```

* on master
```
insert into t values  ('2024-01-01', @@time_zone, "master 4: same timestamp");
insert into t_now values  (now(), @@time_zone, "master 4: before same timestamp");

```

Compare timestamps when timezones were changed.

* on master
```
SET GLOBAL time_zone = '+00:00';
SET @@session.time_zone = "+00:00";

select *,@@time_zone from t; Select *, @@time_zone from t_now;

SET GLOBAL time_zone = '+01:00';
SET @@session.time_zone = "+01:00";

select *, @@time_zone from t; Select *, @@time_zone from t_now;
```
* master output

```
+---------------------+-----------+-----------------------------------+-------------+
| t                   | timezone  | note                              | @@time_zone |
+---------------------+-----------+-----------------------------------+-------------+
| 2024-01-01 08:00:00 | -07:00:00 | master 1: before timechange       | +00:00      |
| 2024-01-01 00:00:00 | +00:00    | master 2: after timechange +00:00 | +00:00      |
| 2023-12-31 23:00:00 | +01:00    | master 2: after timechange +01:00 | +00:00      |
| 2023-12-31 23:00:00 | +01:00    | master 4: same timestamp          | +00:00      |
+---------------------+-----------+-----------------------------------+-------------+
4 rows in set (0.00 sec)

+---------------------+-----------+-----------------------------------+-------------+
| t                   | timezone  | note                              | @@time_zone |
+---------------------+-----------+-----------------------------------+-------------+
| 2024-09-17 18:28:50 | -07:00:00 | master 1: before timechange       | +00:00      |
| 2024-09-17 18:28:50 | +00:00    | master 2: after timechange +00:00 | +00:00      |
| 2024-09-17 18:28:50 | +01:00    | master 2: after timechange +01:00 | +00:00      |
| 2024-09-17 18:31:14 | +01:00    | master 4: before same timestamp   | +00:00      |
+---------------------+-----------+-----------------------------------+-------------+

After timezone change

+---------------------+-----------+-----------------------------------+-------------+
| t                   | timezone  | note                              | @@time_zone |
+---------------------+-----------+-----------------------------------+-------------+
| 2024-01-01 09:00:00 | -07:00:00 | master 1: before timechange       | +01:00      |
| 2024-01-01 01:00:00 | +00:00    | master 2: after timechange +00:00 | +01:00      |
| 2024-01-01 00:00:00 | +01:00    | master 2: after timechange +01:00 | +01:00      |
| 2024-01-01 00:00:00 | +01:00    | master 4: same timestamp          | +01:00      |
+---------------------+-----------+-----------------------------------+-------------+
4 rows in set (0.00 sec)

+---------------------+-----------+-----------------------------------+-------------+
| t                   | timezone  | note                              | @@time_zone |
+---------------------+-----------+-----------------------------------+-------------+
| 2024-09-17 19:28:50 | -07:00:00 | master 1: before timechange       | +01:00      |
| 2024-09-17 19:28:50 | +00:00    | master 2: after timechange +00:00 | +01:00      |
| 2024-09-17 19:28:50 | +01:00    | master 2: after timechange +01:00 | +01:00      |
| 2024-09-17 19:31:14 | +01:00    | master 4: before same timestamp   | +01:00      |
+---------------------+-----------+-----------------------------------+-------------+



```

* Master conclusion
   * Timezones using now() change according to that timezone is defined. The data for now() is inserted in the the same default timezone (probably UTC) so that it is interpreted correctly when the
   timezone changes.
   * When timezone is inserted with a value, its value is using localtime of the timezone it is
   defined in. 


```
* on slave
```
SET GLOBAL time_zone = '+00:00';
SET @@session.time_zone = "+00:00";

select * from t; Select * from t_now;

SET GLOBAL time_zone = '+01:00';
SET @@session.time_zone = "+01:00";

select * from t; Select * from t_now;
```



* slave output
```

```

Conclusion: The timezone data does not change when you change the time_zone in MySQL. The
interpretation changes when the timezone changes. If you 