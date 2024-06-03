---
title : MySQL to Snowflake
author : Mark Nielsen
copyright : June 2024
---


MySQL to Snowflake
==============================

_**by Mark Nielsen  
Original Copyright June 2024**_

To convert MySQL data to Snowflake reliably.   
  
1.  [Links](#links)
2.  [Create data in MySQL](#c)
3.  [Issues](#i)
4.  [Export data to file and upload to Snowflake JSON](#d)
6.  [Convert data on the fly with Python](#o)
  

* * *

<a name=links></a>Links
-----

* * *

<a name=c></a>Create data in MySQL
----------

```

echo "
create database if not exists mark1;
drop table if exists t1;
create table t1 (a int NOT NULL AUTO_INCREMENT, ni int, i int, d datetime, t timestamp, v varchar(255), nc char(8) NOT NULL, PRIMARY KEY (a));
" > insert_data.sql


for i in {0..1000}; do
  n1=`echo ${RANDOM:0:6}`
  n2=`echo ${RANDOM:0:6}`

  l1=`echo ${RANDOM:0:2}`
  l2=`echo ${RANDOM:0:1}`

  c1="'"`openssl rand -base64 $l1 | head -c 50`"'"
  c2="'"`openssl rand -base64 $l2 | head -c 8`"'"

  l2=`echo ${RANDOM:0:1}`
  if [ $l2 -gt 5 ]; then
     c1='Null'
     n2='Null'
  fi

  echo "insert into mark1.t1 (ni, i, d, t, v, nc ) values ($n1, $n2, now(), now(), $c1, $c2 );"
done >> insert_data.sql


```

Log into MySQL and then
```
mysql > source insert_data.sql

```


* * *
<a name=i></a>Issues
----------

The data in MySQL must converted to Snowflake. Issues involve data types.
* There must be tables in Snowflake with correct datatypes for the data. Snowflake can guess
what the datatypes should be, but you can create the tables ahead of time.
* The data in MySQL must correctly be inserted into Snowflake. Problems can arise with Nulls or if there is not a direct data type equivalent. 

Solutions for data types.
* Export to Json and upload
    * Create the tables on Snowflake first. Look at the data types for the fields in MySQL and
    see if Snowflake has an equivalent.
    * Be aware of Nulls. Make sure Json has null fields.
* Use Python or other language to automatically take care of data type conversion. Tables on Snowflake should be created ahead of time. 


* * *
<a name=d></a>Export data to file and upload to Snowflake
----------

#### Make the create table file. 

```
echo "
select
   ' create table t1 ('
   UNION
select   GROUP_CONCAT(
     concat(
       COLUMN_NAME, ' ',
       DATA_TYPE,  
       IF(NUMERIC_PRECISION IS NULL,'', concat('(', convert(NUMERIC_PRECISION, char), ')' ) ),
       IF(CHARACTER_MAXIMUM_LENGTH IS NULL,'',concat('(' , convert(CHARACTER_MAXIMUM_LENGTH, char) , ')') ),
       if (IS_NULLABLE = 'NO', ' NOT NULL', '')
     )
   SEPARATOR ',')  
from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME='t1'
   UNION
select ');'
" > make_create_table.sql


mysql -e "source make_create_table.sql" > create_table.sql

# You may need to supply  username and password
# When it prompts for the password, enter the password. 
# mysql -u <USER> -p -e "source make_create_table.sql" mark1 > create_table.sql
# ex: mysql -u root -p -e "source make_create_table.sql" mark1 > create_table.sql


#### Export the data as json. 

```


* * *
<a name=o></a>Convert data on the fly
----------


