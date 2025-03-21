
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

#### Install
* On each of the 6 systems
    * Setup variables for ip addresses and install basic software without configuring or
    starting software. 
```
sudo bash
echo "
  # Change the ip addresses to your hosts
  # If you are using VirutalBox, it is the ip addresses of the servers
  # that should be able to see each other in its own network.
export db1="10.0.2.7"
export db2="10.0.2.8"
export db3="10.0.2.9"
export db4="10.0.2.10"
export db5="10.0.2.11"
export db6="10.0.2.12"
" > /root/server_ips


mkdir -p software_install
cd software_install

wget https://software.yugabyte.com/releases/2024.2.2.1/yugabyte-2024.2.2.1-b6-linux-x86_64.tar.gz
tar xvfz yugabyte-2024.2.2.1-b6-linux-x86_64.tar.gz 
mv yugabyte-2024.2.2.1 /usr/local
cd /usr/local
ln -s yugabyte-2024.2.2.1 yugabyte-2024_server
cd /usr/local/yugabyte-2024_server
echo "PATH=/usr/local/yugabyte-2024_server/bin:\$PATH" >> ~/.bashrc
source ~/.bashrc


./bin/post_install.sh


 ## Configure time --- this is NOT AWS, so no chrony

apt-get -y install ntp 


 ## Change ulimits
echo "
*                -       core            unlimited
*                -       data            unlimited
*                -       fsize           unlimited
*                -       sigpending      119934
*                -       memlock         64
*                -       rss             unlimited
*                -       nofile          1048576
*                -       msgqueue        819200
*                -       stack           8192
*                -       cpu             unlimited
*                -       nproc           12000
*                -       locks           unlimited
" > /etc/security/limits.conf


  ## add huge pages
echo always > /sys/kernel/mm/transparent_hugepage/enable
cat  /sys/kernel/mm/transparent_hugepage/enable

bash -c 'sysctl vm.swappiness=0 >> /etc/sysctl.conf'
bash -c 'sysctl vm.max_map_count=262144 >> /etc/sysctl.conf'

mkdir -p /db/yugabyte/disks/d1
mkdir -p /db/yugabyte/disks/d2
mkdir -p /db/yugabyte/log

echo "
--master_addresses $db1:7100,$db2:7100,$db3:7100 
--rpc_bind_addresses *.*.*.*:7100 
--fs_data_dirs '/db/yugabyte/disks/d1,/db/yugabyte/disks/d2' 
" > /db/yugabyte/tmaster.conf

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