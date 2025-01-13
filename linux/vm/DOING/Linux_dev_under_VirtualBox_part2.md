
title : Linux Dev environment on Windows Part 2
author : Mark Nielsen
copyright : November 2024
---


Linux Dev environment on Windows Part 2
==============================

_**by Mark Nielsen
Original Copyright November 2024**_
TODO : import grfana dashboards


NOTE: This is very similar to having Linux as a Host instead of Windows. Any operating system as a host is almost
irrelevant.
I am just given a Windows laptop wherever I work, so I am stuck with it. 

The goal is to setup 3 servers, sent up basic Ansible. Install mysql master
and slave, install Grapana with Promehtesus and mysql_exporter and telegraph.

Monitoring Environment
* Setup we will use on admin1
    * Telegraf gets multiple data, cpu, memory, mysql, etc.
    * Promethesus gathers data from multiple servers.
       * It can monitor, report, display itself.
    * Grafana will connect to promethesus for monitor, report, and display.

So why use Grafana? It has a good interface for dashboards.

In general the goals are
* Setup 6 db servers. Your admin server as already been setup. 
* Setup One MySQL master, 2 Slave, and and accounts
* Install MongoDB as 2 clusters.
   * One mongos server -- located on admin box. 
   * 3 servers of MongoDB and MongoDB config servers in one cluster.
   * Same in the other cluster.
   * The config servers will tell mongos where the data is. The data will be
     split amoun the 2 replica sets. The 2 replica sets is one cluster.
* Install TiDB as a cluster
* Instal YugaByte as a cluster


Sections
* [Links](#links)
* [3 db servers](#3)
* [MySQL](#m)
* [MongoDB](#mongodb)
* [TiDB](#t)
* [Yugabyte](#y)
* [Couchbase](#c)

* * *

<a name=links></a>Links
-----
TODO verify links and redo links
* [Part 1](https://github.com/vikingdata/articles/blob/main/linux/vm/Linux_dev_under_Windows_part1.md)
* https://logz.io/blog/grafana-tutorial/
* https://grafana.com/docs/grafana/latest/developers/http_api/data_source/
* https://www.youtube.com/watch?v=Dcumy5Ir1Ag
* * *
<a name=3></a>3 db servers
-----

First, do [Linux Dev under VirtualBox Part 1](Linux_dev_under_VirtualBox_part1.md)

End goal:
    * 6 servers db1, db2, db3, db4, db5, and db6. Each type of database
      will use some or all of the servers. 
    * MySQL will use 3 servers.
    * MongoDB will use 7 servers. 6 database servers and one admin server.
    * TIDB will use
    * Yugabyte will use
    * Couchbase will use
    * Install MySQL ClusterSet on all 6 servers.
    * Install Percona Galera Cluster on all 6 servers. 

* Now import the image as described in [Part 1](Linux_dev_under_Windows_part1.md#copies)
    * In Virtual Box, select Import Appliance
    * For File, put in C:\shared\UbuntuBase.ova
        * Or whatever you saved the base ubuntu image as.
    * Change settings
    * Name : admin2
    * Mac Address Policy : "Generate new"
    * click Finish
    * Start the instance
* Setup the firewall and port forward as in [Part 1](Linux_dev_under_Windows_part1.md#nat2) 
* To find out the ip address of each server, on each server:
```
ifconfig |grep "inet 10" | sed -e "s/  */ /g" | cut -d " " -f 3
my_ip=`ifconfig |grep "inet 10" | sed -e "s/  */ /g" | cut -d " " -f 3`
echo "my ip address is : $my_ip"
```

* Setup the firewall and port forward 
    * Described in [Part 1](https://github.com/vikingdata/articles/blob/main/linux/vm/Linux
_dev_under_Windows_part1.md#ssh) but use a different port for the firewall which should match the host port in
port forwarding.
        * Example for db1:
            * Make the firewall block with port 2002
            * In Virtual Box Manager, the port forward
                * Name : Rule3
                * Protocol : TCP
                * Host Ip: 127.0.0.1
                * Host Port : 2101
                * Guest IP : 10.0.2.7
                    * Change to the ip address of your virtual box.
                * Guest Port : 22


    * Repeat the previous steps.
        * The port forwarding might need to be edited instead of making new ones. This is for "ssh". 
        * db1 server should use port 2101  on host
        * db2 server should use port 2102  on host
        * db3 server should use port 2103  on host
        * db4 server should use port 2103  on host
        * db5 server should use port 2103  on host
        * db6 server should use port 2103  on host


* On each server, change the hostname
    * db1 :   hostnamectl set-hostname db1.myguest.virtualbox.org
    * db2 :   hostnamectl set-hostname db2.myguest.virtualbox.org
    * db3 :   hostnamectl set-hostname db3.myguest.virtualbox.org
    * db4 :   hostnamectl set-hostname db4.myguest.virtualbox.org
    * db5 :   hostnamectl set-hostname db5.myguest.virtualbox.org
    * db6 :   hostnamectl set-hostname db6.myguest.virtualbox.org

* on each server, save the alias
```
sudo bash


echo "Change the alias name depending which servers you are on!"

export alias_name="ssh_"`hostname`
echo " my hostname", `hostname`, " and my alias is $alias_name"
my_ip=`ifconfig |grep "inet 10" | sed -e "s/  */ /g" | cut -d " " -f 3`
echo "alias $alias_name='ssh -l $my_ip'" >> /shared/aliases
echo "$alias_name='$my_ip'" >> /shared/server_ips
echo ""; echo ""; echo "";

echo " my hostname", `hostname`, " and my alias is $alias_name"
echo "my ip is: $my_ip"

```

* Test the connections -- NOTE, the port forwarding must be done already. 
    * ssh 127.0.0.1 -p 2101 -l root "echo '2101 good', `hostname`"
    * ssh 127.0.0.1 -p 2102 -l root "echo '2202 good', `hostname`"
    * ssh 127.0.0.1 -p 2103 -l root "echo '2303 good', `hostname`"
    * ssh 127.0.0.1 -p 2104 -l root "echo '2304 good', `hostname`"
    * ssh 127.0.0.1 -p 2105 -l root "echo '2305 good', `hostname`"
    * ssh 127.0.0.1 -p 2106 -l root "echo '2306 good', `hostname`"


* Make alias in .bashrc in Cygwin or WSL
```
cp ~/.bashrc ~/.bashrc_`date +%Y%m%d`

echo "
alias ssh_db1='ssh 127.0.0.1 -p 2101 -l root'
alias ssh_db2='ssh 127.0.0.1 -p 2202 -l root'
alias ssh_db3='ssh 127.0.0.1 -p 2303 -l root'
alias ssh_db4='ssh 127.0.0.1 -p 2104 -l root'
alias ssh_db5='ssh 127.0.0.1 -p 2205 -l root'
alias ssh_db6='ssh 127.0.0.1 -p 2306 -l root'

" >> ~/.bashrc
source ~/.bashrc

```
* In Windows, in cygwin or WSL. This should be unecessary. The base image should already have this.
```
for port in  2101 2102 2013 2014 2015 2016; do
  ssh-copy-id -o "StrictHostKeyChecking no" -p $port -i ~/.ssh/id_rsa.pub root@127.0.0.1
  ssh -p $port root@127.0.0.1 "echo 'ssh firewall $port ok'"
done

#for port in 2102 2103; do
#  echo "transferring private and public keys to $port"
#  rsync -av  ~/.ssh/id_rsa.pub  ~/.ssh/id_rsa root@127.0.0.1:$port/.ssh
#done



```


* * *
<a name=m></a>Install MySQL on all 6 servers manually
-----
###  Include Percona + mysql tools for ClusterSet later. 

* Follow install inbstructions from [MySQL Clusterset on one server](https://github.com/vikingdata/articles/blob/main/databases/mysql/MySQL_Clusterset_on_one_server.md#i) in just the secion "Install Percona MySQL, mysqlsh, mysql router on Ubuntu". Or follow these steps

NOTE: the router and shell must be equal or ahead of the percona version. Installing a specific version of
percona seems to not work when newer versions come out. An option is to download the tarball and add to
the PATH the location of the binaries. You might want to also download the percona binaries and the mysql binaries
or tarballs, as they tend to vanish over time as new versions come out. 


```
ssh 127.0.0.1 -p 2001 -l root

 # after you login

mkdir percona
cd percona

apt install curl -y
curl -O https://repo.percona.com/apt/percona-release_latest.generic_all.deb
apt -y install gnupg2 lsb-release ./percona-release_latest.generic_all.deb
apt update
percona-release setup ps80

apt-get update

   # install router and shell
wget https://dev.mysql.com/get/Downloads/MySQL-Router/mysql-router-community_8.0.40-1ubuntu22.04_amd64.deb
dpkg -i mysql-router-community_8.0.40-1ubuntu22.04_amd64.deb

wget https://dev.mysql.com/get/Downloads/MySQL-Shell/mysql-shell_8.0.40-1ubuntu22.04_amd64.deb
dpkg -i mysql-shell_8.0.40-1ubuntu22.04_amd64.deb


  # Install a specific version, it must be 8.0.36 or earlier, because
  # the router software is 8.0.37

  # It may ask for password, make the password "root" or your own password.
  # I suggest a better password than "root"
sudo apt -y install percona-server-server=8.0.39-30-1.jammy

mysql -u root -proot -e "CREATE FUNCTION fnv1a_64 RETURNS INTEGER SONAME 'libfnv1a_udf.so'"
mysql -u root -proot -e "CREATE FUNCTION fnv_64 RETURNS INTEGER SONAME 'libfnv_udf.so'"
mysql -u root -proot -e "CREATE FUNCTION murmur_hash RETURNS INTEGER SONAME 'libmurmur_udf.so'"

mysql -u root -proot -e "create user grafana@localhost IDENTIFIED BY 'grafana'"
mysql -u root -proot -e "grant select, REPLICATION SLAVE on *.* to grafana@'%';"
mysql -u root -proot -e "create user grafana@'%' IDENTIFIED BY 'grafana'"
mysql -u root -proot -e "grant select, REPLICATION SLAVE on *.* to grafana@'%';"

mysql -u root -proot -e "create user telegraf@localhost IDENTIFIED BY 'telegraf'"
mysql -u root -proot -e "GRANT SELECT ON performance_schema.* TO 'telegraf'@'localhost';"
mysql -u root -proot -e "GRANT PROCESS ON *.* TO 'telegraf'@'localhost';"
mysql -u root -proot -e "GRANT REPLICATION CLIENT ON *.* TO 'telegraf'@'localhost';"

mysql -u root -proot -e "create user root@'%' IDENTIFIED BY 'root'"
mysql -u root -proot -e "GRANT all privileges on *.* to  'root'@'%';"



cd
mkdir -p mysql
cd mysql
wget https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main/linux/vm/DOING/Linux_dev_under_VirtualBox_part2_files/Dev_basic_my_cnf.md
 sed -e 's/__NO__/1/g' Dev_basic_my_cnf.md > /etc/mysql/conf.d/Dev_basic_my_cnf.md

# I am not sure why, but changes to buffer pool is not read of configuration files
# other than my.cnf. You need to define buffer pool in the main file
# and then it will override it with the one in conf.d -- weird. 

echo "
[mysqld]
innodb_buffer_pool_size=5242881
" >> /etc/mysql/my.cnf

service mysql restart
mysql -u root -proot -e "SELECT * FROM performance_schema.global_variables where VARIABLE_NAME in ('server_id', 'innodb_buffer_pool_size')" 
```

Output of mysql query
```
+-------------------------+----------------+
| VARIABLE_NAME           | VARIABLE_VALUE |
+-------------------------+----------------+
| innodb_buffer_pool_size | 5242880        |
| master_info_repository  | TABLE          |
| server_id               | 1              |
+-------------------------+----------------+
3 rows in set (0.53 sec)
```

### Setup firewall and port forwarding for db1
Setup firewall for port 3301

* https://www.action1.com/how-to-block-or-allow-tcp-ip-port-in-windows-firewall/
* In Windows, type in firewall in the search field and select "Firewall Network and Protection.
* Click on Inbound rules, and select New.
* Click port
* Enter port 3101
* Click Block connection
* Select domain, private, and public
* name it : A block mysql 3101
* Click on finish
* Do the same thing for port 2101
   * Label it : A block ssh 2101

Setup port forwarding port 3101 to 3306 in db1. 

* Setup port forwarding in Virtual Box to Linux installation.
    * Select the running server "db1"
    * Devices -> Network -> Network Settings
        * Adapter 1 -> Attached to -> NAT
        * Click on Advanced and then port forwarding
            * Enter
            * Name : Rule3
            * Protocol : TCP
            * Host Ip: 127.0.0.1
            * Host Port : 3101
            * Guest IP : 10.0.2.15
	    * Guest Port : 3306
    * Do the same thing for ssh.
            * Name : Rule3
            * Protocol : TCP
            * Host Ip: 127.0.0.1
            * Host Port : 2101
            * Guest IP : 10.0.2.15
            * Guest Port : 22


* Test connection on host: mysql -u root -proot -h 127.0.0.1 -e "select 'good'" -P 3101
     * ssh test : ssh root@127.0.0.1 -p 2101 "echo 'ssh 2101 worked'"

### Setup firewall and port forwarding for other database servers. 