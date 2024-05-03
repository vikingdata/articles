 
---
title :  MySQL Window Functions
author : Mark Nielsen  
copyright : March 2022  
---


MySQL Window Functions
==============================

_**by Mark Nielsen
Original Copyright March 2022**_

The purpose of this document is to show how to do window functions. It is also to stop people
from asking this in interviews as it is very lame and really just
a set of functions in MySQL.
Are we expected to remember all functions?
Yes according to lame people who make lame tests. And yes because some interviews
will always have those people.
There is so much with MySQL this is only small part. The reason why it is lame is non-DBAs
love to ask about these functions because they don't understand its lame
and they want to make themselves feel superior. People look at things to ask about MySQL
on the internet because they know nothing usually and want to feel superior. So I hope
someone can get use of this.



1. [Links](#links)

* * *
<a name=Links></a>Links
-----

* https://dev.mysql.com/doc/refman/8.0/en/window-functions.html
* https://dev.mysql.com/doc/refman/8.0/en/window-functions-usage.html
* https://www.mysqltutorial.org/mysql-window-functions/
* https://www.sqlshack.com/overview-of-mysql-window-functions/
* https://www.section.io/engineering-education/mysql-window-functions/
* https://mode.com/sql-tutorial/sql-window-functions/

* * *
<a name=s>Setup</a>
-----

```

  create database if not exists temp;
  use temp;
  drop database if exists MY_STUPID_DATABASE;

  create database if not exists MY_STUPID_DATABASE;
  use MY_STUPID_DATABASE;

  create table income (person varchar(64), state varchar(64), amount int);
  insert into income values ('mark', 'CA', 10), ('john', 'CA', 20), ('heidi','CA', 30),
  ('Melisa', 'MA', 100), ('Faith', 'MA', 200),('Queen', 'MA', 300),
  ('Collin', 'IN', 51), ('Tristan', 'OH', 61),('John', 'MA', 71);

```

* * *
<a name=a>Group</a>
-----

Window Functioning made with normal (any) group command
* https://dev.mysql.com/doc/refman/8.0/en/aggregate-functions.html

Any group command can be made into function like window functions. You have to use partitions.

* For example:
```
        SELECT person, state, SUM(amount) OVER (PARTITION BY state) as state_income
        FROM income;

        SELECT person, state, count(amount) OVER (PARTITION BY state) as state_no_of_entries
        FROM income;
```


* * *
<a name=q>Queries</a>
-----

https://dev.mysql.com/doc/refman/8.0/en/window-function-descriptions.html

```

 SELECT person, state, amount,
  CUME_DIST()   OVER w AS 'CUME_DIST',
  DENSE_RANK()   OVER w AS 'DENSE_RANK',
  PERCENT_RANK()   OVER w AS 'PERCENT_RANK',
  RANK()   OVER w AS 'RANK',
  ROW_NUMBER()   OVER w AS 'ROW_NUMBER'
  from income
WINDOW w AS (ORDER BY amount)
;

  SELECT person, state, amount,
  FIRST_VALUE(amount)   OVER w AS 'FIRST_VALUE',
  LAST_VALUE(amount)   OVER w AS 'LAST_VALUE',
  LAG(amount)        OVER w AS 'lag',
  LEAD(amount)       OVER w AS 'lead',
  NTH_VALUE(amount, 2)   OVER w AS 'NTH_VALUE',
  NTILE(4)   OVER w AS 'NTILE'

  from income
  WINDOW w AS (PARTITION BY state ORDER BY amount)
  ;

  SELECT person, state, amount,
  CUME_DIST()   OVER  (w ORDER BY amount) AS 'CUME_DIST',
  FIRST_VALUE(amount)   OVER w AS 'FIRST_VALUE'
  from income
  WINDOW w AS (PARTITION BY state)
  ;

  SELECT person, state, amount,
  CUME_DIST()   OVER  w AS 'CUME_DIST',
  FIRST_VALUE(amount)   OVER w2 AS 'FIRST_VALUE'
  from income
  WINDOW w AS (order BY state),
         w2 AS (PARTITION BY state);

```

* * *
<a name=o>Other Queries</a>
-----

```
SELECT person, state, amount,
    lag(amount)          OVER  w AS 'LAG',
    FIRST_VALUE(amount)  OVER w AS 'FIRST_VALUE',
    LAST_VALUE(amount)   OVER w AS 'LAST_VALUE',
    LEAD(amount)         OVER w AS 'LEAD',
    NTH_VALUE(amount, 5) over w as 'NTH_VALUE',
    NTILE(4)             over W as "NTILE"
from income
  WINDOW w AS (order BY amount);

```