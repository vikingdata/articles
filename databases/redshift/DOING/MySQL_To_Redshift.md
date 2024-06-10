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

* * *
<a name=api></a>API interface
----------

* * *
<a name=o></a>ODBC via Python
----------
