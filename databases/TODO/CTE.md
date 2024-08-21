
---
title : CTE queries
author : Mark Nielsen
copyright : August 2024
---


CTE queries
==============================

_**by Mark Nielsen
Original Copyright August 2024**_

1. [links](#links)
2. [Purpose of CTE](#purpose)
3. [Simple conversion](#convert)
3. [Convert normal query to CTE](#convert)
4. [Efficient CTE](#efficient)
5. [Examine exection plan](#explain)
6. [MySQL](#mysql)
7. [PostgreSQL](#list1)
8. [Snowflake](#sf)

* * *
<a name=links></a>Links
-----
* https://learnsql.com/blog/what-is-common-table-expression/
* https://hightouch.com/sql-dictionary/sql-with
* https://modern-sql.com/feature/with
* https://www.geeksforgeeks.org/sql-with-clause/
* Convert to CTE
   * https://teamtreehouse.com/library/common-table-expressions-using-with/convert-a-subquery-to-a-cte
   * https://www.atlassian.com/data/sql/using-common-table-expressions

* * *
<a name=purpose></a>Purpose of CTE
* Makes code easy to read.
* Other people can understand your code better.
* When you go back to edit your code, it can be quickly done. 

NOTE: Always run an explain command against query to make sure indexes are used.
