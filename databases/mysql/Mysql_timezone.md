 
---
title : MySQL Timezone : now() and hard date

author : Mark Nielsen  

copyright : June 2024  
---


MySQL Timezone : now() and hard date
==============================

_**by Mark Nielsen
Original Copyright September 2024**_

This is for MySQL 5.7 and 8.0. Probably the same in other versions.

1. [Links](#links)
2. [setup master-slave virtualbox](#install)
3. [test timezones](#test)
4. [Test with one table](#one)

<a name=Links></a>Links
-----
* https://dev.mysql.com/doc/refman/8.4/en/time-zone-support.html


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

select UNIX_TIMESTAMP(STR_TO_DATE(t, '%Y-%m-%d %H:%i:%s')) as UT_t  from t;
select UNIX_TIMESTAMP(STR_TO_DATE(t_now, '%Y-%m-%d %H:%i:%s')) as UT_t_now  from t_now;

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

mysql> select UNIX_TIMESTAMP(STR_TO_DATE(t, '%Y-%m-%d %H:%i:%s')) as UT_t  from t;
+------------+
| UT_t       |
+------------+
| 1726619112 |
| 1726593912 |
| 1726590312 |
+------------+
3 rows in set (0.00 sec)

mysql> select UNIX_TIMESTAMP(STR_TO_DATE(t_now, '%Y-%m-%d %H:%i:%s')) as UT_t_now  from t_now;
+------------+
| UT_t_now   |
+------------+
| 1726619112 |
| 1726619112 |
| 1726619112 |
+------------+
3 rows in set (0.00 sec)


```

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

mysql> select UNIX_TIMESTAMP(STR_TO_DATE(t, '%Y-%m-%d %H:%i:%s')) as UT_t  from t;
+------------+
| UT_t       |
+------------+
| 1726619375 |
| 1726594175 |
| 1726590575 |
+------------+
3 rows in set (0.00 sec)

mysql> select UNIX_TIMESTAMP(STR_TO_DATE(t_now, '%Y-%m-%d %H:%i:%s')) as UT_t_now  from t_now;
+------------+
| UT_t_now   |
+------------+
| 1726619375 |
| 1726619375 |
| 1726619375 |
+------------+


```


Conclusion : Something is going on when you insert now() compared to @t which should be equal to now() but might be considered a datetime value. 

* * *
<a name=one></a>Test with one table
-----


* When you insert a date into a timezone field, 

```
SET @@session.time_zone = "+01:00";
SET GLOBAL time_zone = '+01:00';
select @t:=now();

drop table if exists t1;
create table t1 (t timestamp, note varchar(255) , primary key (note));

select @t:=now();
insert into t1 values (now(), 'now() 1'), (@t, '@t 1'), ('2000-01-01', 'date 1');
select UNIX_TIMESTAMP(STR_TO_DATE(t, '%Y-%m-%d %H:%i:%s')) UT, note, t
  from t1;

SET @@session.time_zone = "+02:00";
SET GLOBAL time_zone = '+02:00';
insert into t1 values (now(), 'now() 3'), (@t, '@t 3'), ('2000-01-01', 'date 3');
select UNIX_TIMESTAMP(STR_TO_DATE(t, '%Y-%m-%d %H:%i:%s')) UT, note, t
  from t1;


SET @@session.time_zone = "+03:00";
SET GLOBAL time_zone = '+03:00';
insert into t1 values (now(), 'now() 3'), (@t, '@t 3'), ('2000-01-01', 'date 3');

select UNIX_TIMESTAMP(STR_TO_DATE(t, '%Y-%m-%d %H:%i:%s')) UT, note, t
  from t1;

```
* Output of of select queries. 
```
+------------+---------+---------------------+
| UT         | note    | t                   |
+------------+---------+---------------------+
| 1726623490 | @t 1    | 2024-09-18 02:38:10 |
|  946681200 | date 1  | 2000-01-01 00:00:00 |
| 1726623490 | now() 1 | 2024-09-18 02:38:10 |
+------------+---------+---------------------+

+------------+---------+---------------------+
| UT         | note    | t                   |
+------------+---------+---------------------+
| 1726623490 | @t 1    | 2024-09-18 03:38:10 |
| 1726619890 | @t 2    | 2024-09-18 02:38:10 |
|  946681200 | date 1  | 2000-01-01 01:00:00 |
|  946677600 | date 2  | 2000-01-01 00:00:00 |
| 1726623490 | now() 1 | 2024-09-18 03:38:10 |
| 1726623490 | now() 2 | 2024-09-18 03:38:10 |
+------------+---------+---------------------+

+------------+---------+---------------------+
| UT         | note    | t                   |
+------------+---------+---------------------+
| 1726623490 | @t 1    | 2024-09-18 04:38:10 |
| 1726619890 | @t 2    | 2024-09-18 03:38:10 |
| 1726616290 | @t 3    | 2024-09-18 02:38:10 |
|  946681200 | date 1  | 2000-01-01 02:00:00 |
|  946677600 | date 2  | 2000-01-01 01:00:00 |
|  946674000 | date 3  | 2000-01-01 00:00:00 |
| 1726623490 | now() 1 | 2024-09-18 04:38:10 |
| 1726623490 | now() 2 | 2024-09-18 04:38:10 |
| 1726623490 | now() 3 | 2024-09-18 04:38:10 |
+------------+---------+---------------------+

```
* Explanation : This happens because now() uses UTC time, but a hard date in a timezone field
    uses the UTC time converted from its time zone.
    * When you use now()
        * inserts insert the same UTC time (the inserts happen within the same second).
        * The select value changes with the time zone, but they are all the same value. 
    * When you insert a hard date, it follows the time zone for inserts and selects. 
        * The hard date gets converted to UTC for its timezone. When the time zone increases,
	its UTC time becomes less for the same date. This is why earlier inserted dates have higher
	value.
        * For selects, when the time zone changes, the date follows the time zone change, because
        its uses its UTC time and gets converted to local time. 
        * @t apparently gets converted to a hard date. 
    * It is good to be aware inserting now() behaves differently
    than inserting a hard date into a timezone
    field. In general, never set a hard date for a timestamp. 

* also
```
SET @@session.time_zone = "+00:00";
SET GLOBAL time_zone = '+00:00';
select @t:=now();

select now(), @t;

SET @@session.time_zone = "+01:00";
SET GLOBAL time_zone = '+01:00';
select now(), @t;

SET @@session.time_zone = "+02:00";
SET GLOBAL time_zone = '+02:00';
select now(), @t;

```

* Output

```
mysql> SET @@session.time_zone = "+00:00";
Query OK, 0 rows affected (0.00 sec)

mysql> SET GLOBAL time_zone = '+00:00';
Query OK, 0 rows affected (0.00 sec)

mysql> select @t:=now();
+---------------------+

| @t:=now()           |
+---------------------+
| 2024-09-18 03:12:15 |
+---------------------+
1 row in set (0.00 sec)

mysql>
mysql> select now(), @t;
+---------------------+---------------------+
| now()               | @t                  |
+---------------------+---------------------+
| 2024-09-18 03:12:15 | 2024-09-18 03:12:15 |
+---------------------+---------------------+
1 row in set (0.00 sec)

mysql>
mysql> SET @@session.time_zone = "+01:00";
Query OK, 0 rows affected (0.00 sec)

mysql> SET GLOBAL time_zone = '+01:00';
Query OK, 0 rows affected (0.00 sec)

mysql> select now(), @t;
+---------------------+---------------------+
| now()               | @t                  |
+---------------------+---------------------+
| 2024-09-18 04:12:15 | 2024-09-18 03:12:15 |
+---------------------+---------------------+
1 row in set (0.00 sec)

mysql>
mysql> SET @@session.time_zone = "+02:00";
Query OK, 0 rows affected (0.00 sec)

mysql> SET GLOBAL time_zone = '+02:00';
Query OK, 0 rows affected (0.00 sec)

mysql> select now(), @t;
+---------------------+---------------------+
| now()               | @t                  |
+---------------------+---------------------+
| 2024-09-18 05:12:15 | 2024-09-18 03:12:15 |
+---------------------+---------------------+
1 row in set (0.00 sec)

```
* We see @t stays the same value because it is a hard date, but now() changes when time zone changes. 