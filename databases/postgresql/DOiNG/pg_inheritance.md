---
PostgreSQL : Schema Inheritance
---

* [Links](#links)
* [Inheritance](#i)
* [Domain](#domain)


* * *
<a name=links>Links</a>
-----

* [PostgreSQL Inheritance](https://www.postgresql.org/docs/current/tutorial-inheritance.html)


* * *
<a name=i></a> Inheritance
-----

Schema Inheritance is pretty simple. When you create a new table called "Table 2", it you give it the command to inherit rows from another table  called "Table 1" and 2 things will happen.

* Table2 will get all the rows (without data) of Table1 and any additional rows you define.
* Any rows inserted into Table 2 will also end up in Table 1.

Here is an example:
