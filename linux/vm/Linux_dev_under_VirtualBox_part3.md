title : Linux Dev environment on Windows Part 3: Yugabyte Local
author : Mark Nielsen
copyright : November 2024
---


Linux Dev environment on Windows Part 3 : Yugabyte Local
==============================

_**by Mark Nielsen
Original Copyright November 2024**_

Sections
* [Links](#links)
* [Yugabyte Cluster with Xcluster Failover](#y)
  * [One node](#node)
  * [3 nodes installed locally](#threelocal)
  * [3 nodes installed on 3 servers.](#threeservers)
  * Xcluster failover

* * *
<a name=y></a>Yugabyte Cluster with Xcluster Failover
-----
* Links
* https://docs.yugabyte.com/preview/deploy/manual-deployment/install-software/
* https://download.yugabyte.com/local#linux
* https://www.youtube.com/watch?v=d8JWKgXReTg
* https://dev.to/yugabyte/yugabytedb-on-oci-free-tier-52cm
* https://www.baeldung.com/yugabytedb
* https://www.dedicatedcore.com/blog/install-gcc-compiler-ubuntu/
* https://www.youtube.com/watch?v=PMD5xsDAemE
* https://www.yugabyte.com/blog/introducing-yugabyted-the-simplest-way-to-get-started-with-yugabytedb/

We are installing yugbayte on 6 systems. To test you can
* Download it and run it locally. A one node yugabyte.
* Add ip addresses 127.0.0.2 and 127.0.0.3 and run 3 nodes locally.
* Download to multiple vms or servers. 

#### Install one node locally <a name=one></a>

* install -- connect to one your vms, suggest the admin server. 
```
sudo bash
cd
bash install_yugabte.sh

webfile=https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main/linux/vm/Linux_dev_under_VirtualBox_part3/install_yugabte.sh
wget $webfile -O  install_yugabte.sh

cd /usr/local/yugabyte-2024_server
./bin/yugabyted start --advertise_address=127.0.0.1

ysqlsh -c "select now(), current_user, inet_server_addr()"

```

* Output
```
+---------------------------------------------------------------------------------------------------+
|                                             yugabyted                                             |
+---------------------------------------------------------------------------------------------------+
| Status         : Bootstrapping.                                                                   |
| YSQL Status    : Not Ready                                                                        |
| YugabyteDB UI  : http://127.0.0.1:15433                                                           |
| JDBC           : jdbc:postgresql://127.0.0.1:5433/yugabyte?user=yugabyte&password=yugabyte        |
| YSQL           : bin/ysqlsh   -U yugabyte -d yugabyte                                             |
| YCQL           : bin/ycqlsh   -u cassandra                                                        |
| Data Dir       : /root/var/data                                                                   |
| Log Dir        : /root/var/logs                                                                   |
| Universe UUID  : d7d7e17a-83a8-4642-88ea-3c225882a2d5                                             |
+---------------------------------------------------------------------------------------------------+
```

* Connect
    * TO connect to database, log into the vm via ssh
        * Connect to the database  as instructed.
    * TO connect from your Windows or Linux Host
        * Setup firewall on host and open ports in Virtual Box

* Connect from host server -- TODO. 
   * Firewall
   * open ports
   * Web interface
   * database connection
   * Install client on Host server. 


#### Install three nodes locally <a name=three><a/>
* Add additional ip address
    * Add 127.0.0.2 and 127.0.0.3
        * sudo ifconfig lo:1 127.0.0.2
        * sudo ifconfig lo:2 127.0.0.3
* Install yugabyte
```
sudo bash
cd
bash install_yugabte.sh

webfile=https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main/linux/vm/Linux_dev_under_VirtualBox_part3/install_yugabte.sh
wget $webfile -O  install_yugabte.sh

cd /usr/local/yugabyte-2024_server

rm -r /db/yugabyte_local1
rm -r /db/yugabyte_local2
rm -r /db/yugabyte_local3

mkdir -p /db/yugabyte_local1
mkdir -p /db/yugabyte_local2
mkdir -p /db/yugabyte_local3

rm -rf /var/oot

```
* Start all three nodes
    * yugabyted start --advertise_address=127.0.0.1 --base_dir=/db/yugabyte_local1
    * yugabyted start --advertise_address=127.0.0.2 --base_dir=/db/yugabyte_local2 --join=127.0.0.1
    * yugabyted start --advertise_address=127.0.0.3 --base_dir=/db/yugabyte_local3 --join=127.0.0.1
* Check cluster
```
  # This will fail, for some reason need to specify user postgres
ysqlsh -c "select yb_servers()" -h 127.0.0.1

ysqlsh -c "select yb_servers()" -h 127.0.0.2 
ysqlsh -c "select yb_servers()" -h 127.0.0.2 "sslmode=disable" 
ysqlsh -c "select yb_servers()" -h 127.0.0.3 "sslmode=disable" postgres
ysqlsh -c "select yb_servers()" -h 127.0.0.3 "sslmode=disable" yugabyte
```

#### Install three nodes on vms or servers <a name=threeservers></a>

* For each server db1, db2 and db3 install software but do not start
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
source /root/server_ips
echo "source /root/server_ips" >> ~/.bashrc

rm -rf /root/var
mkdir -p /db/yugabyte/data
mkdir -p /db/yugabyte/log

cd
webfile=https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main/linux/vm/Linux_dev_under_VirtualBox_part3/install_yugabte.sh
wget $webfile -O  install_yugabte.sh
bash install_yugabte.sh
```
* start on db1
```
echo " {
  \"base_dir\":  \"/db/yugabyte/\",
  \"log_dir\":  \"/db/yugabyte/log\",
  \"data_dir\":  \"/db/yugabyte/data\",
  \"advertise_address\" : \"$db1\"
}" > /db/yugabyte/yugabyte.config

source ~/.bashrc
yugabyted start --config /db/yugabyte/yugabyte.config

ysqlsh -c "select yb_servers()" -h $db1
ysqlsh -c "select yb_servers()" -h $db2

```
* start on db2
```
echo " {
  \"base_dir\":  \"/db/yugabyte/\",
  \"log_dir\":  \"/db/yugabyte/log\",
  \"data_dir\":  \"/db/yugabyte/data\",
  \"advertise_address\" : \"$db2\",
  \"join\": \"$db1\"
}" > /db/yugabyte/yugabyte.config

ysqlsh -c "select yb_servers()" -h $db1
ysqlsh -c "select yb_servers()" -h $db2
ysqlsh -c "select yb_servers()" -h $db3

source ~/.bashrc
yugabyted start --config /db/yugabyte/yugabyte.config
```

* start on db3
```
echo " {
  \"base_dir\":  \"/db/yugabyte/\",
  \"log_dir\":  \"/db/yugabyte/log\",
  \"data_dir\":  \"/db/yugabyte/data\",
  \"advertise_address\" : \"$db3\",
  \"join\": \"$db1\"
}" > /db/yugabyte/yugabyte.config
	  

source ~/.bashrc
yugabyted start --config /db/yugabyte/yugabyte.config

ysqlsh -c "select yb_servers()" -h $db1
ysqlsh -c "select yb_servers()" -h $db2
ysqlsh -c "select yb_servers()" -h $db3

```
#### Setup Xcluster failover
Links
* https://docs.yugabyte.com/preview/deploy/multi-dc/async-replication/async-transactional-setup-automatic/
* https://docs.yugabyte.com/preview/develop/build-global-apps/
    * You must choose single, multi active (bi directional) , or other.
    * We will use single active.
* https://docs.yugabyte.com/preview/deploy/multi-dc/async-replication/async-transactional-setup-automatic/
* https://docs.yugabyte.com/preview/launch-and-manage/monitor-and-alert/xcluster-monitor/

Goal
1. Setup a failover cluster
2. Automatic Failover
3. Test failover by turning off nodes one at a time.
4. Monitor the xcluster
5. Manual failover

* First, setup 3 node cluster
     * [Install three nodes locally](#threeservers)
* Second setup another 3 node cluster
     * [Install three nodes locally](#threeservers)
     * NOTE: The instructions contain 6 servers for ".bashrc". Make sure both clusters have all 6 servers installed
     in "..bashrc".
* Setup firewall and connection to Master WebUi.
    * If you are on the same computer, in your browser: http://127.0.0.1:7000
    * Otherwise, setup the firewall and port forward described in
    [Part 1](https://github.com/vikingdata/articles/blob/main/linux/vm/Linux_dev_under_VirtualBox_part1.md#ssh)
 but use a different port for the firewall which should match the host port in
port forwarding.
        * For port forwarding
	    * Host Port: 7000
	    * Guest IP : IP address of the first node in your cluster.
	    * Guest Port : 7000
	* For Firewall:
	    * Port : 7000
	    * Name it : "Yugbyte Master UI: first cluster"
	* Url in Windows using Virtual box
	    * http://127.0.0.1:7000
