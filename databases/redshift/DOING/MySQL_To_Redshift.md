---
title : MySQL to RedShift
author : Mark Nielsen
copyright : June 2024
---


MySQL to RedShift
==============================

_**by Mark Nielsen  
Original Copyright June 2024**_

To convert MySQL data to RedShift reliably.
First we will should how to upload a document. Then we will upload data with Python.


* * *

<a name=links></a>Links
-----
 
Connect
* https://docs.aws.amazon.com/redshift/latest/mgmt/configure-odbc-connection.html#install-odbc-driver-linux	
    * https://pypi.org/project/pyodbc/
    * UnixODBC
        * See what version Ubuntu installs: sudo apt-get install unixodbc unixodbc-dev
        * Mine was the newset version 2.3.10
        * If if its older than https://www.unixodbc.org/unixODBC.html then you might want to install manually. 
* https://docs.aws.amazon.com/redshift/latest/mgmt/data-api.html
    * https://docs.aws.amazon.com/redshift/latest/mgmt/data-api-access.html
* https://docs.aws.amazon.com/cli/latest/reference/redshift/
    * https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
* Web interface : https://aws.amazon.com/redshift/query-editor-v2/
    * https://docs.aws.amazon.com/redshift/latest/dg/t_loading-tables-from-s3.html
    * https://docs.informatica.com/integration-cloud/data-integration-connectors/h2l/0972-configuring-aws-iam-authentication-for-amazon-redshift-and-/configuring-aws-iam-authentication-for-amazon-redshift-and-amazo/create-the-amazon-redshift-role.html


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
mysql -e  "source insert_data.sql"

```

Data should look like
```
mysql> select * from t1 limit 5;
+---+-------+-------+---------------------+---------------------+------------------------------------------+------+
| a | ni    | i     | d                   | t                   | v                                        | nc   |
+---+-------+-------+---------------------+---------------------+------------------------------------------+------+
| 1 | 16336 | 22336 | 2024-06-07 11:23:37 | 2024-06-07 11:23:37 | DiibBvQGUrknkw==                         | Ug== |
| 2 |  5772 | 31505 | 2024-06-07 11:23:38 | 2024-06-07 11:23:38 | RN3cntZ7kDeYtCFTMeiqJGR2                 | Tw== |
| 3 | 13587 | 20559 | 2024-06-07 11:23:39 | 2024-06-07 11:23:39 | 3i4G6EAQn6p2fxvjHe7zi2TnZw==             | gg== |
| 4 | 22644 | 29907 | 2024-06-07 11:23:39 | 2024-06-07 11:23:39 | riWzFW8+lniPng==                         | 0+sU |
| 5 | 21983 | 29951 | 2024-06-07 11:23:40 | 2024-06-07 11:23:40 | qUla5Szc0bx95KIh0OySxCKDBO7syqyJE8rdRg== | 4cXd |
+---+-------+-------+---------------------+---------------------+------------------------------------------+------+
5 rows in set (0.00 sec)
```


* * *
<a name=w></a>Web interface
----------

The few steps listed here will be needed for other sections.

## Setup database
* Started Amazon Redshift Query Editor
    * Select "default-workgroup"
    * Select "create database"
    * Click "Create Schema"
        * Select "samepldb" for database and enter "public"
    * Click on create Table
        * Select sampldb, public, call the table t1_web
	* Enter the columns as
```
a int NOT NULL
ni int not null
i int
d date
t timestamp
v varchar
nc varchar NOT NULL

```

###The table definition should be
```
CREATE TABLE public.t1_web (
    a integer NOT NULL ENCODE az64,
    ni integer NOT NULL ENCODE az64,
    i integer ENCODE az64,
    d date ENCODE az64,
    t timestamp without time zone ENCODE az64,
    v character varying(256) ENCODE lzo,
    nc character varying(256) NOT NULL ENCODE lzo
) DISTSTYLE AUTO;
```
You can also enter the above in a worksheet on database sampledb and schema public and then click "run".

## Create a cluster and role
   * When creating th cluster, select also to create the role for S3. 
   * Copy its arn

## Create a staging area to upload the json file.
* Sign up for free S3. There are limits if you exceed that you will have to pay for, but for testing purposes, this will be unlikely. 
* Once in S3, create a bucket.
* select thje bucket
* Click "upload"
    * Click add files
        * select data.json
    * click Upload
* Select the file
   * copy the S3 URI.
   * copy the arn, Amazon Resource Name (ARN


## In the worksheet
    * Create a staging table
    * Load data.json from the A3 bucket into the staging table
    * Create a link between the file an the staging table
    * Load the staging table into the final table
```
create temp table t1_web_temp (like t1_web);

-- change S3 URI and ARN
copy t1_web_temp
from 's3://mybucket/data.json' 
iam_role 'arn:aws:iam::994334653999:role/s3                                  ';

-- now select table
Select * from t1_web_temp;

```


* * *
<a name=api></a>API interface
----------

* * *
<a name=o></a>ODBC via Python
----------
