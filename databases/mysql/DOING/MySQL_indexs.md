
---
title : MySQL Indexes
author : Mark Nielsen
copyright : July 2026
---


MySQL Indexes
==============================

_**by Mark Nielsen
Original Copyright September 2024**_

* [links](#links)
* Types if Indexes
* Left most rule for indexes
* What fields are most important for indexes with no joins.
* With joins, the first field in an index must be for the join.
    * Standard joins
    * [derived] Standard joins with derived tables. 

* * *
<a name=links></a>Links
-----

* * *
<a name=t></a>Types of Indexes
-----

* * *
<a name=left></a>Left most rule for indexes
-----
In general, an index in the "where" condition must go from left to right.

* * *
<a name=without_joins></a>Indexes without joins
-----
I

TODO: equality, range in where condition

TODO: Where, group by, order by


* * *
<a name=with_joins></a>Indexes with joins
-----
Usually, the most important field in an index is with the join. After the join, the other fields
in the index can be used for anything in the where condition or a derived table.

* * *
<a name=standard_joins></a>Standard joins
-----

* * *
<a name=derived></a>Standard joins with derived tables
-----

* Execute the following in the your linux or cygwin shell.
```
mkdir -d  join_test
cd join_test

GET_DIR_URL=https://raw.githubusercontent.com/vikingdata/articles/main/databases/mysql/DOING/join_test_files

for f in analyze_logs.sh create_table_join.sql join_test.sql make_data.sh; do
  echo "downloading $f"
  wget -O $f $GET_DIR_URL/$f
done
```