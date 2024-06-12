
---
title : MySQL General
author : Mark Nielsen
copyright : June 2024 
---


MySL General
==============================

_**by Mark Nielsen
Original Copyright June 2924**_

This article will grow over time. 

Not including
* Info queries
* MySQL variables

1. [mysqldump](#mysqldump)


* * *

<a name=mysqldump></a>MySQL Dump
-----

* See if you have triggers or stored procedures
   * Unless you dump mysql and all-databases, you can ignore dumping triggers and stored procedures if you find none
```
SELECT  routine_schema,  
        routine_name,  
        routine_type 
FROM information_schema.routines 
WHERE routine_schema not in ('sys', 'mysql', 'mysql_innodb_cluster_metadata', 'information_schema', 'performance_schema') 
ORDER BY routine_name;

  # just trigger name
select trigger_schema, trigger_name
  from information_schema.triggers
  WHERE trigger_schema not in ('sys', 'mysql', 'mysql_innodb_cluster_metadata', 'information_schema', 'performance_schema');
```

* mysqldump command,, with triggers, stored procedure, and replication position, everything
```
  # pre 8.0
  # needs testing
mysqldump -u root -p --single-transaction --events --triggers --routines --opt --all-databases \
--master-data=1 --dump-slave=2 --master-data=2 \
   | gzip > mysqlbackup_`hostname`_`date +%Y%m%d_%H%M%S`.sql.gz 

```

* to make a list of databases to ignore, select databases you want and add --databases to the option. Or use mysqlpump which has an exclude option.
```

SELECT group_concat( schema_name SEPARATOR ',')
  FROM information_schema.schemata
  where
     schema_name not in ('sys', 'performance_schema', 'information_schema', 'mysql_innodb_cluster_metadata')
     and  schema_name not like 'Ignore_pattern1%'
     and schema_name not like '%Ignore_pattern2%';

```


