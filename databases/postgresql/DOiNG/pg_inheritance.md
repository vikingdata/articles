---
PostgreSQL : Schema Inheritance
---

* [Links](#links)
* [Inheritance](#i)
* [Schema Change](#sh)
* [Primary Key](#pk)
* [Errors](e)

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

Here is an example. Start pgsql client. I assume PostgreSQL is already installed. 

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
* In Inserting into table3 ONLY inserted data into table2.
* Inserting into table2 ONLY inserted into table1.

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

