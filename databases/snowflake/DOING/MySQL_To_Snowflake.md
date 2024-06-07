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

This doc requires
* A snowflake account
* snowsql is installed
* Python and modules installed
  
1.  [Links](#links)
2.  [Create data in MySQL](#c)
3.  [Issues](#i)
4.  [Export data to json file and upload Snowsight (web) or cli SnowSql](#u)
5.  [Convert data on the fly with Python](#o)

* * *

<a name=links></a>Links
-----
* https://www.chaosgenius.io/blog/snowflake-insert-into/
* https://thinketl.com/how-to-load-and-query-json-data-in-snowflake/
* https://www.projectpro.io/recipes/load-json-data-from-local-internal-stage-snowflake

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
<a name=u></a>Export data to json file and upload Snowsight (web) or cli SnowSql
----------

NOTE: "staging table" is not really a staging table. It is a real table. I call it staging because you may use this table over once day to load data
into a final table. In effect, it is a staging table for my purposes. 

Summary of steps
* with Mysql
    * Create a query which generate a creates table format for snowflake.
    * Make the crate table sql.
    * Create a data file in json format.
* In snowflake
    * Create database
    * Create final table
    * For the json file
       * Create a internal stage (a location of where the json file will be).
       * Load the arbitrary json file to the stagng location.
       * Create a file format which explains how to interpret the json file into a tabular table.
       * Create a staging table to view the data. The table will only have one column, a variant column.
       * Load json from stage into the staging table.
    * Select data from staging table into final table. 

## Make the create table file. 

```
echo "

# Change the authetication for your mysql account
export auth=" -u root -proot -h 127.0.0.1 -P 3306 "

select
   ' create table t1 ('
   UNION
select   GROUP_CONCAT(
     concat(
       COLUMN_NAME, ' ',
       DATA_TYPE,  
       IF(CHARACTER_MAXIMUM_LENGTH IS NULL,'',concat('(' , convert(CHARACTER_MAXIMUM_LENGTH, char) , ')') ),
       if (IS_NULLABLE = 'NO', ' NOT NULL', '')
     )
   SEPARATOR ',')  
from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME='t1'
   UNION
select ');'
" > make_create_table.sql


mysql $auth -N -e "source make_create_table.sql" > create_table.sql

# You may need to supply  username and password
# When it prompts for the password, enter the password. 
# mysql -u <USER> -p -e "source make_create_table.sql" mark1 > create_table.sql
# ex: mysql -u root -p -e "source make_create_table.sql" mark1 > create_table.sql


## Export the data as json. 

echo "
select ' select JSON_ARRAYAGG( JSON_OBJECT ('
  union 
select
  GROUP_CONCAT(
    concat (\"'\", COLUMN_NAME, \"'\", ',' , COLUMN_NAME )
    SEPARATOR ',')
  from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME='t1'
  union
select ')) from mark1.t1';
" > make_get_data.sql

mysql $auth -N -e "source make_get_data.sql" > get_data.sql

# You may need to supply  username and password
# When it prompts for the password, enter the password.
# mysql -N  -u <USER> -p -e "source make_get_data.sql" mark1 > get_data.sql
# ex: mysql -N -u root -p -e "source make_get_data_table.sql" mark1 > get_data.sql

# and lastly, get the data


mysql $auth -N -e "source get_data.sql" | python -m json.tool >  data.json

```

## Connect to snowflake via the Snowsight (web)
* CLick on "data"
    * Create database "sampledb" if it doesn't exist. 
    * Select database "sampledb"
    * Create schema "public" if it doesn't exist


## SETUP STAGE AND STAGE TABLE
* In SnowSQL
    * ConNECT "sampledb" database and "public" schema.
* In the Snowsight (web)
    * Select Projects
        * Select worksheets
	    * Select "+" and then "SQL Workssheet"
            * Make sure you are using "accountadmin" and warehouse "compute_wh". 

* Execute the commands by copy and paste. For the Snowsight (web) interface you must run all or press the arrow to run it.

```
create or replace database sampledb;
use sampledb.public;


-- source the create_table.sql or do this

create or replace table t1 (
a int NOT NULL, ni int, i int, d datetime, t timestamp, v varchar(255), nc char(8) NOT NULL
);

-- create the stage or location we will upload the file
CREATE OR REPLACE STAGE stage_t1;
list stage_t1;

-- Create a file format which tells you how to interpret data in the stage table
create or replace file format json_format type = 'json' strip_outer_array = true;

-- Create stage table.
create or replace table stage_table_t1 (t1_data  variant );

```

### upload data into staging
* For snowsql : "   put file://data.json @stage_t1; "
* for Snowsight (web) : https://docs.snowflake.com/en/user-guide/data-load-local-file-system-stage-ui#uploading-files-onto-a-stage
    * Select data
    * Select load files into a stage
    * Select "Add data"
    * Select "data.json", Select sampledb, Select stage_t1
    * Upload file

### Copy the file from stage into the table stage_table_t1
```
-- Copy data from staging into staging table
copy into stage_table_t1
    from  @stage_t1/data.json
    FILE_FORMAT = JSON_FORMAT
    on_error = 'skip_file';

-- Verify data in staging table
select count(1) from stage_table_t1;

-- See how to select raw rows and then separate values into columns per row. 
select * from stage_table_t1 limit 5;
SELECT 
    t1_data:a,
    t1_data:d:Category
FROM stage_table_1 limit 5;

-- Insert the data into final row and then verify

delete from t1;
insert into t1 (a, ni, i, d, t, v, nc )
SELECT
    t1_data:a,
    t1_data:ni,
    t1_data:i,
    t1_data:d,
    t1_data:t,
    t1_data:v,
    t1_data:nc
FROM stage_table_t1;

select count(1) from t1;
select * from t1 limit;

```

* * *
<a name=o></a>Convert data on the fly with Python
----------


