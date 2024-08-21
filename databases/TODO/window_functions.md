
---
title : Window Functions
author : Mark Nielsen
copyright : August 2024
---


MySQL Info queries
==============================

_**by Mark Nielsen
Original Copyright August 2024**_

0. [Links](#links)
1. [Window Functions](#win)
2. [Mysql](#m)
3. [Postresql](#p)
4. [Snowflake](#sn)
5. [CoudchDB](#c)

* * *
<a name=links></a>Links
-----

* * *
<a name=win></a>Window Functions
-----
This is going to be a rough description of Window Functions.

* Efficient queries do a one pass against the data and return results.
    * Efficient queries minimize temporary tables or calculations AFTER
    getting the data.
    * This means GROUP BY or HAVING clauses are going to be inefficient to some
    degree. All the data returned has to be saved and reanalyzed with WHERE
    and HAVING clauses.
* Window Functions are similar to GROUP BY clauses.
    * Calucations from Window Functions are made AFTER the data has been scanned.
    * But, window functions save a lot of time programming, and thus may  be more
    efficient in the long run.
        * The key window functions are indexes. 