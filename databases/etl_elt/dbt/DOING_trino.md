---
Title : DBT with mutiple channels using Trino
Author : Mark Nielsen
Copyright : November 2023
---

Using Simple DBT
===============

_**by Mark Nielsen
Copyright November 2023**_

* * *

1. [Links](#links)
2. [Install PostgreSQL and setup Snowflake](#pg)
4. [Download and configure Trino](#trino)
5. [Connect Trino to PostgreSQL and Snowflake](#tpg)
6. [Download Trino CLI](#cli)
7. [Use Trino Cli to connect to PostgreSQL and Snowflake](#clittest)
9. [Download DBT](#dbt)
9. [Configure DBT to use Trino](#tdbt)
10. [Use DBT to pull data from PostgreSQL and make table on Snowflake](#usedbt)

* * *
<a name=links></a>Links
-----
    
    * [Deploying Trino](https://trino.io/docs/current/installation/deployment.html)
    * [Trino Cli](https://trino.io/docs/current/client/cli.html)

* * *
<a name=pg></a> Install PostgreSQL and setup Snowflake
-----

Refer to my article (DBT install : CLI and Adapters)[https://github.com/vikingdata/articles/blob/main/databases/snowflake/setup/snowflake_interfaces.md].

It also include DBT setup.

* * *
<a name=trino></a> Download and configure Trino
-----
* Download and untar
    * [Deploying Trino](https://trino.io/docs/current/installation/deployment.html)
    * NOTE : int eh commands below change '192.168.1.7' to the hostname or ip address of where you install Trino.
        * 127.0.0.1 might work????
	
```shell
apt-get purge openjdk-\* 

wget https://download.oracle.com/java/17/archive/jdk-17.0.9_linux-x64_bin.deb
dpkg -i jdk-17.0.9_linux-x64_bin.deb

useradd -m trino
echo 'trino:change_this_password' | sudo chpasswd
mkdir -p /var/trino/data
chown -R trino /var/trino



cd /usr/local
wget https://repo1.maven.org/maven2/io/trino/trino-server/431/trino-server-431.tar.gz
tar -xxvf trino-server-431.tar.gz
ln -s trino-server-431 trino
cd trino

mkdir etc
echo "
node.environment=production
node.id=ffffffff-ffff-ffff-ffff-ffffffffffff
node.data-dir=/var/trino/data
" > etc/node.properties

echo "
coordinator=true
node-scheduler.include-coordinator=true
http-server.http.port=8080
discovery.uri=http://192.168.1.7:8080
" > etc/config.properties

echo "
io.trino=INFO
" > etc/log.properties

mkdir etc/catalog
echo "
connector.name=jmx
" > etc/catalog/jmx.properties

echo "
-server
-Xmx1G
-XX:InitialRAMPercentage=10
-XX:MaxRAMPercentage=10
-XX:G1HeapRegionSize=32M
-XX:+ExplicitGCInvokesConcurrent
-XX:+ExitOnOutOfMemoryError
-XX:+HeapDumpOnOutOfMemoryError
-XX:-OmitStackTraceInFastThrow
-XX:ReservedCodeCacheSize=512M
-XX:PerMethodRecompilationCutoff=10000
-XX:PerBytecodeRecompilationCutoff=10000
-Djdk.attach.allowAttachSelf=true
-Djdk.nio.maxCachedBufferSize=2000000
-XX:+UnlockDiagnosticVMOptions
-XX:+UseAESCTRIntrinsics
-Dfile.encoding=UTF-8
# Disable Preventive GC for performance reasons (JDK-8293861)
-XX:-G1UsePreventiveGC
# Reduce starvation of threads by GClocker, recommend to set about the number of cpu cores (JDK-8192647)
-XX:GCLockerRetryAllocationCount=32
" > etc/jvm.config

echo "
cd /usr/local/trino
sudo -u trino -s bin/launcher run
" > run_trino
chmod 755 run_trino

echo "
cd /usr/local/trino
sudo -u trino -s bin/launcher start
sleep 2
ps auxw| grep trino | grep -v grep | cut -c1-150
" > start_trino
chmod 755 start_trino

echo "
cd /usr/local/trino
bin/launcher stop
" > stop_trino
chmod 755 stop_trino



```

* * *
<a name=tdbt></a>Connect Trino to PostgreSQL and Snowflake
-----
```shell

# Make trino user on postgresql

echo "CREATE USER trino WITH PASSWORD 'trino';" | sudo -iu postgres psql
echo " create database trino owner trino;" | sudo -iu postgres psql	

echo "
connector.name=postgresql
connection-url=jdbc:postgresql://localhost:5432/trino
connection-user=trino
connection-password=trino
" > etc/catalog/postgres.properties 


```

6. [Download Trino CLI](#cli)



7. [Use Trino Cli to connect to PostgreSQL and Snowflake](#clittest)

9. [Download DBT](#dbt)

Refer to my previous article (Using Simple DB)[https://github.com/vikingdata/articles/blob/main/databases/etl_elt/dbt/dbt1-1.md].


* * *
<a name=tdbt></a>Configure DBT to use Trino
-----
* (Setup DBT for trino)[https://docs.getdbt.com/docs/core/connect-data-platform/trino-setup]
    * Install plugin
        * pip install dbt-trino
    * Configure dbt



11. [Use DBT to pull data from PostgreSQL and make table on Snowflake](#usedbt)
