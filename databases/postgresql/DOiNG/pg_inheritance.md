---
PostgreSQL : Schema Inheritance
---

* [Links](#links)
* [Inheritance](#i)
* [Schema Change](#sh)
* [Primary Key](#pk)
* [Primary Key 2](#pk2)
* [Updates](#u)
* [Deletes](#d)


Schema Inheritance may not work the way you think it works. Let's test it out. 

* * *
<a name=links>Links</a>
-----

* [PostgreSQL Inheritance](https://www.postgresql.org/docs/current/tutorial-inheritance.html)


* * *
<a name=i></a> Inheritance
-----

Schema Inheritance is pretty simple. When you create a new table called "Table 2", it you give it the command to inherit rows from another table  called "Table 1" and few things will happen.

* Table2 will get all the rows (without data) of Table1 and any additional rows you define.
* Any rows inserted into Table 2 will also end up in Table 1.
* You cannot drop table1 before dropping table2
* Changing a field name, changes the name is child tables. 
* Same named fields in the create statements will be "merged". 
* Indexes and other constraints one Table 1 do not apply to Table 2

Here is an example. Start psql client. I assume PostgreSQL is already installed. 

If you already created the tables, drop them. 

``` sql
drop table if exists table3;
drop table if exists table2;
drop table if exists table1;
```

Create tables and put in data.

```sql

  create table if not exists table1 (field1 text, t1_1 text, t1_2 text);
  create table if not exists table2 (field2 text, t2_1 text) inherits (table1);
  create table if not exists table3 (field3 text, t3_1 text) inherits (table2);
  insert into table3 (field1,field2,field3) values (3,3,3);
  insert into table2 (field2, t2_1) values (2,'not replicated');
  insert into table1 (field1, t1_1) values (1,'not replicated');
```


Select the data

```
 select * from table3 order by field3;
  select * from table2 order by field2;
  select * from table1 order by field1;
```

Output
```text
 field1 | t1_1 | t1_2 | field2 | t2_1 | field3 | t3_1
--------+------+------+--------+------+--------+------
 3      |      |      | 3      |      | 3      |
(1 row)

 field1 | t1_1 | t1_2 | field2 |      t2_1
--------+------+------+--------+----------------
        |      |      | 2      | not replicated
 3      |      |      | 3      |
(2 rows)

 field1 |      t1_1      | t1_2
--------+----------------+------
 1      | not replicated |
 3      |                |
        |                |
```

Some things to note:
* Inserting into table3 ONLY inserted data into table2.
* Inserting into table2 ONLY inserted data into table1.
* Field t2_1 is ONLY table2.

* * *
<a name=sc></a> Schema Change
-----

Change the name of "field1" in table1.

``` sql
alter table table1 rename field1 to field1_test;

\d table3
\d table2
\d table1

```

Output

```text

                Table "public.table3"
   Column    | Type | Collation | Nullable | Default
-------------+------+-----------+----------+---------
 field1_test | text |           |          |
 t1_1        | text |           |          |
 t1_2        | text |           |          |
 field2      | text |           |          |
 t2_1        | text |           |          |
 field3      | text |           |          |
 t3_1        | text |           |          |
Inherits: table2

                Table "public.table2"
   Column    | Type | Collation | Nullable | Default
-------------+------+-----------+----------+---------
 field1_test | text |           |          |
 t1_1        | text |           |          |
 t1_2        | text |           |          |
 field2      | text |           |          |
 t2_1        | text |           |          |
Inherits: table1
Number of child tables: 1 (Use \d+ to list them.)

                Table "public.table1"
   Column    | Type | Collation | Nullable | Default
-------------+------+-----------+----------+---------
 field1_test | text |           |          |
 t1_1        | text |           |          |
 t1_2        | text |           |          |
Number of child tables: 1 (Use \d+ to list them.)

```

We can see "field1" got changed in the child tables.

* * *
<a name=pk></a> Primary Key
-----


Now we add a primary key to table1.

```sql
ALTER TABLE table1 ADD PRIMARY KEY (field1);
```

Output

```text
mark=> ALTER TABLE table1 ADD PRIMARY KEY (field1);
ERROR:  column "field1" of relation "table2" contains null values
```

Notice table2 does not have the same constraint, and so it warns you. Table2 has a row that was not inserted into table1
which has a NULL value. 

```sql
  select * from table2 order by field2;
  select * from table1 order by field1;
```

Output
```text
 field1 | t1_1 | t1_2 | field2 |      t2_1
--------+------+------+--------+----------------
        |      |      | 2      | not replicated
 3      |      |      | 3      |
(2 rows)

 field1 |      t1_1      | t1_2
--------+----------------+------
 1      | not replicated |
 3      |                |
        |                |
```

* * *
<a name=pk2></a> Primary Key Part 2
-----

Let's reset the tables and add a primary key on table1 and then insert the same row into table2 twice.
The Primary Key doesn't appear to work when Inheritance is used, but does not when not. 


```sql
drop table if exists table3;
drop table if exists table2;
drop table if exists table1;

create table if not exists table1 (field1 text, t1_1 text, t1_2 text);
create table if not exists table2 (field2 text, t2_1 text) inherits (table1);

ALTER TABLE table1 ADD PRIMARY KEY (field1);

insert into table2 (field1,field2) values ('2-1','2-1');
insert into table2 (field1,field2) values ('2-1','2-1');
```

Output
```text
DROP TABLE
DROP TABLE
DROP TABLE
CREATE TABLE
CREATE TABLE
ALTER TABLE
INSERT 0 1
INSERT 0 1
```

But if you select the data.

```sql
select * from table2;
select * from table1;
```

Output
```text

 field1 | t1_1 | t1_2 | field2 | t2_1
--------+------+------+--------+------
 2-1    |      |      | 2-1    |
 2-1    |      |      | 2-1    |
(2 rows)

 field1 | t1_1 | t1_2
--------+------+------
 2-1    |      |
 2-1    |      |
```

We see table1 has two identical rows in field1 named "2-1". This is not suppose to happen. Let's test primary key
without inheritance.

```sql
drop table if exists table3;
drop table if exists table2;
drop table if exists table1;

create table if not exists table1 (field1 text, t1_1 text, t1_2 text);
ALTER TABLE table1 ADD PRIMARY KEY (field1);

insert into table1 (field1) values ('test');
insert into table1 (field1) values ('test');

select * from table1;

```

Output
```text
DROP TABLE
CREATE TABLE
ALTER TABLE
INSERT 0 1
ERROR:  duplicate key value violates unique constraint "table1_pkey"
DETAIL:  Key (field1)=(test) already exists.

mark=> select * from table1;
 field1 | t1_1 | t1_2
--------+------+------
 test   |      |


```

Now we see the primary key works to prevent duplicates when you do NOT use inheritance.
My version of PostgreSQL is

```text
PostgreSQL 15.4 (Ubuntu 15.4-1.pgdg22.04+1) on x86_64-pc-linux-gnu, compiled by gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0, 64-bit
```

* * *
<a name=u></a> Updates
-----

Let's reset the tables

```sql
drop table if exists table3;
drop table if exists table2;
drop table if exists table1;

create table if not exists table1 (field1 text, t1_1 text, t1_2 text);
create table if not exists table2 (field2 text, t2_1 text) inherits (table1);

insert into table2 (field1,field2) values ('test1','test1');
insert into table2 (field1,field2) values ('test2','test2');

```

* * *
<a name=u></a> Updates
-----


Let's do an update on table2 and table1

```sql
update table2 set field2 = 'test2_2', field1 = 'test2_1' where field2 = 'test2';
update table1 set field1 = 'test1_1', field1 = 'test1';

select * from table2;
select * from table1;
```

Output
``` text
mark=> select * from table2; select * from table1;
 field1  | t1_1 | t1_2 | field2  | t2_1
---------+------+------+---------+------
 test2_1 |      |      | test2_2 |
 test1_1 |      |      | test1   |
(2 rows)

 field1  | t1_1 | t1_2
---------+------+------
 test2_1 |      |
 test1_1 |      |


```


* The data changed in table1 appeared in table2;
* The data changed in table2 appeared in table1;

* * *
<a name=d></a> Deletes
-----

Now let's delete data from the existing tables.

```sql

delete from table2 where field2 = 'test2_2';
delete from table1 where field1 = 'test1_1';

select * from table2;
select * from table1;

```

Output

```text

DELETE 1
DELETE 1
 field1 | t1_1 | t1_2 | field2 | t2_1
--------+------+------+--------+------
(0 rows)

 field1 | t1_1 | t1_2
--------+------+------
(0 rows)

```

* The data deleted in table1 was deleted in table2;
* The data deleted in table2 was deleted in table1;
