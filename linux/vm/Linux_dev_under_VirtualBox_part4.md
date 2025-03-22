
title : Linux Dev environment on Windows Part 4
author : Mark Nielsen
copyright : November 2024
---


Linux Dev environment on Windows Part 2
==============================

_**by Mark Nielsen
Original Copyright November 2024**_

Sections
* [Links](#links)
* Install locally the Distributed Databases and Clusters
  * [CockroachDB](#c)
  * [TIDB](#t)
  * [Yugabyte](#y)
  * MongoDB
  * Percona MySQL Cluster
  * MySQL CluserSet
  * [Turn off and on services](#turn)

* * *
<a name=links></a>Links
-----

* * *
<a name=c></a>CockroachDB
-----

* * *
<a name=t></a>TiDB
-----

* * *
<a name=y></a>Yugabyte
-----
* Links
* https://docs.yugabyte.com/preview/deploy/manual-deployment/install-software/
* https://download.yugabyte.com/local#linux
* https://www.youtube.com/watch?v=d8JWKgXReTg
* https://dev.to/yugabyte/yugabytedb-on-oci-free-tier-52cm
* https://www.baeldung.com/yugabytedb
* https://www.dedicatedcore.com/blog/install-gcc-compiler-ubuntu/


We are installing yugbayte on 6 systems. To test you can
* Download it and run it locally. A one node yugabyte.
* Add ip addresses 127.0.0.2 and 127.0.0.3 and run 3 nodes locally.
* Download to multiple vms or servers. 

#### Install one node locally

```
sudo bash
cd
wget https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main/linux/vm/Linux_dev_under_VirtualBox_part4/install_yugabte.sh > install_yugabte.sh
bash install_yugabte.sh

```
#### Install three nodes locally


#### Install three nodes on vms or servers



echo "
--master_addresses $db1:7100,$db2:7100,$db3:7100 
--rpc_bind_addresses *.*.*.*:7100 
--fs_data_dirs=/db/yugabyte/disks/d1
" > /db/yugabyte/tmaster.conf

source /root/server_ips
cd /usr/local/yugabyte-2024_server/
./bin/yb-master --flagfile /db/yugabyte/tmaster.conf  >& /db/yugabyte/log/yb-master.out &

./bin/yugabyted start

```
My Output
```
Starting yugabyted...
✅ YugabyteDB Started
✅ UI ready
✅ Data placement constraint successfully verified

⚠ WARNINGS:
- ntp/chrony package is missing for clock synchronization. For centos 7, we recommend installing either ntp or chrony package and for centos 8, we recommend installing chrony package.
- Transparent hugepages disabled. Please enable transparent_hugepages.
- Cluster started in an insecure mode without authentication and encryption enabled. For non-production use only, not to be used without firewalls blocking the internet traffic.

Please review the following docs and rerun the start command:
- Quick start for Linux: https://docs.yugabyte.com/preview/quick-start/linux/

+-------------------------------------------------------------------------------------------------------+
|                                               yugabyted                                               |
+-------------------------------------------------------------------------------------------------------+
| Status              : Running.                                                                        |
| YSQL Status         : Ready                                                                           |
| Replication Factor  : 1                                                                               |
| YugabyteDB UI       : http://10.0.2.7:15433                                                           |
| JDBC                : jdbc:postgresql://10.0.2.7:5433/yugabyte?user=yugabyte&password=yugabyte        |
| YSQL                : bin/ysqlsh -h 10.0.2.7  -U yugabyte -d yugabyte                                 |
| YCQL                : bin/ycqlsh 10.0.2.7 9042 -u cassandra                                           |
| Data Dir            : /root/var/data                                                                  |
| Log Dir             : /root/var/logs                                                                  |
| Universe UUID       : f96732bf-1424-4f32-b6ca-14e13cd33957                                            |
+-------------------------------------------------------------------------------------------------------+
🚀 YugabyteDB started successfully! To load a sample dataset, try 'yugabyted demo'.
🎉 Join us on Slack at https://www.yugabyte.com/slack
👕 Claim your free t-shirt at https://www.yugabyte.com/community-rewards/
```

* * *
<a name=turn></a>Turn off and on services
-----
The VM's have low memory. You cannot have all the database services. The purpose is to only work on
the database service you want. Turn them all off and then turn on the one you want. 