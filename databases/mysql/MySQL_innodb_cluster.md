
---
title : MySQL InnoDB Cluster
author : Mark Nielsen
copyright : November 2025
---


MySQL InnoDB Cluster
==============================

_**by Mark Nielsen
Copyright November 2025**_

1. [Cluster Status](#cs)


* * *
<a name=links></a>Links
-----
 Inside mysqlsh after connecting to a node:
```
dba.getCluster().status();
dba.getClusterSet().status();


dba.getCluster().status({extended:1});
dba.getClusterSet().status({extended:1});


```
Inside mysql client, Workbench, or doing "\sql" in mysqlsh.

```
SELECT
   t2.MEMBER_HOST, t2.member_state, member_role,
   t1.COUNT_TRANSACTIONS_IN_QUEUE AS 'Transactions Local',
   t1.COUNT_TRANSACTIONS_REMOTE_IN_APPLIER_QUEUE AS 'Transactions Remote'
FROM
   performance_schema.replication_group_member_stats t1
   JOIN
   performance_schema.replication_group_members t2
   ON
   t2.MEMBER_ID = t1.MEMBER_ID;



```
TODO: include gtid positions