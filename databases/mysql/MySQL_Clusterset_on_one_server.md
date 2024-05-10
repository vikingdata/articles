 
---
title : MySQL Clusterset on one server
author : Mark Nielsen  
copyright : May 2024
---



==============================

_**by Mark Nielsen
Original Copyright May 2024
**_

NOT DONE YET

1. [Links](#links)
2. [Install Mongo](#i)
3. [Setup MongoDB config files](#c)
4. [Start all instances](#s)
5. [Setup replica set](#r)


* * *
<a name=Links></a>Links
-----

* * *
<a name=i>Install ClusterSet on Ubuntu</a>
-----

```

sudo bash


mkdir -p /data/mysql1/logs
mkdir -p /data/mysql1/db
mkdir -p /data/mysql2/logs
mkdir -p /data/mysql2/db
mkdir -p /data/mysql3/logs
mkdir -p /data/mysql3/db
mkdir -p /data/mysql4/logs
mkdir -p /data/mysql4/db
mkdir -p /data/mysql5/logs
mkdir -p /data/mysql5/db
mkdir -p /data/mysql6/logs
mkdir -p /data/mysql6/db

mkdir -p /data/mysql1/logs/innodb
mkdir -p /data/mysql1/logs/binlog
mkdir -p /data/mysql1/logs/relay
mkdir -p /data/mysql1/logs/redo
mkdir -p /data/mysql1/logs/undo





```

* * *
<a name=c>Setup MySQL config file</a>
-----

```
sudo bash

mkdir -p /data/mysql1/logs
mkdir -p /data/mysql1/data


cd /data/mysq1
cd /data/mysq2
cd /data/mysq3
cd /data/mysq4
cd /data/mysq5
cd /data/mysq6

cd /lib/systemd/system/


```


* * *
<a name=s>Start all instances</a>
-----

```
killall mysqld
sleep 2

sudo -u mysqld mysqld --config=/data/mysql1/mysqld1.conf & 
sudo -u mysqld mysqld --config=/data/mysql2/mysqld2.conf &
sudo -u mysqld mysqld --config=/data/mysql3/mysqld3.conf &
sudo -u mysqld mysqld --config=/data/mysql4/mysqld4.conf &
sudo -u mysqld mysqld --config=/data/mysql5/mysqld5.conf &

sleep 2

   # See if they are still running
jobs

mysql -u root -p root -P 40001 "select @@hostname, now()"

   # test if you can connect
mysql -u root -p root -P 40001 "select @@hostname, now()"
mysql -u root -p root -P 40002 "select @@hostname, now()"
mysql -u root -p root -P 40003 "select @@hostname, now()"
mysql -u root -p root -P 40004 "select @@hostname, now()"
mysql -u root -p root -P 40005 "select @@hostname, now()"
mysql -u root -p root -P 40006 "select @@hostname, now()"


   # If so, kill and restart
killall mysqld
rm /data/mysql*/*.lock

systemctl daemon-reload

systemctl restart mysql1
systemctl restart mysql2
systemctl restart mysql3
systemctl restart mysql4
systemctl restart mysql5
systemctl restart mysql6


  # See if they started
ps auxw | grep mysqld


mongosh -eval "db.runCommand({ serverStatus: 1}).host" --port 30001
mongosh -eval "db.runCommand({ serverStatus: 1}).host" --port 30002
mongosh -eval "db.runCommand({ serverStatus: 1}).host" --port 30003
mongosh -eval "db.runCommand({ serverStatus: 1}).host" --port 30004

  # These next steps may be uncesssary.

  # If good, enable at restart, and then restart them
systemctl enable mysql1
systemctl enable mysql2
systemctl enable mysql3
systemctl enable mysql4
systemctl enable mysql5
systemctl enable mysql6

   # restart them using service 
service mysql1 restart
service mysql2 restart
service mysql3 restart
service mysql4 restart
service mysql5 restart
service mysql6 restart


```

* * *
<a name=r>Setup CluserSet</a>
-----

```



```