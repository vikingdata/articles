
title : Linux Dev environment on Windows Part 2
author : Mark Nielsen
copyright : November 2024
---


Linux Dev environment on Windows Part 2
==============================

_**by Mark Nielsen
Original Copyright November 2024**_

The goal is to setup 3 servers, sent up basic Ansible. Install mysql master
and slave, install Grapana with Promehtesus and mysql_exporter and telegraph.

* [Links](#links)
* [4 servers](#4)
* [MySQL](#m)
* [Grafana](#g)

* * *

<a name=links></a>Links
-----
* [Part 1](https://github.com/vikingdata/articles/blob/main/linux/vm/Linux_dev_under_Windows_part1.md)

* * *
<a name=4></a>4 servers
-----

The end goal is to have 4 servers, admin, db1, db2, and db3. Each with ports
200, 2001, 2002, and 2003 on the host pointing to them at their port ssh 22. 

* Now import the image
    * In Virtual Box, select Import Appliance
    * For File, put in C:\shared\UbuntuBase.ova
        * Or whatever you saved the base ubuntu image as.
    * Change settings
    * Name : admin
    * Mac Address Policy : "Generate new"
    * click Finish
    * Start the instance
* Setup the firewall and port forward as in [Part 1](https://github.com/vikingdata/articles/blob/main/linux/vm/Linux_dev_under_Windows_part1.md#nat2) but use port 2001 instead of 2000. 

* Repeat the previous steps.
    * The port forwarding might need to be edited instead of making new ones.
    * The admin server should use port 2000
    * The second server name db1 and use port 2001
    * The third server name db2 and use port 2002
    * The fourth server should be db3 and use port 2003 

* Test the connections
    * ssh 127.0.0.1 -p 2000 -l root "echo '2000 good'"
    * ssh 127.0.0.1 -p 2001 -l root "echo '2001 good'"
    * ssh 127.0.0.1 -p 2002 -l root "echo '2002 good'"
    * ssh 127.0.0.1 -p 2003 -l root "echo '2003 good'"

* On each server, change the hostname
    * admin : hostnamectl set-hostname admin.myguest.virtualbox.org
    * db1 :   hostnamectl set-hostname db1.myguest.virtualbox.org
    * db2 :   hostnamectl set-hostname db2.myguest.virtualbox.org
    * db3 :   hostnamectl set-hostname db3.myguest.virtualbox.org
* * *
<a name=db1_mysql></a>Install MySQL on db1 manually
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
sudo apt install gnupg2 lsb-release ./percona-release_latest.generic_all.deb
sudo apt update
sudo percona-release setup ps80

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
sudo apt install percona-server-server=8.0.39-30-1.jammy

mysql -u root -proot -e "CREATE FUNCTION fnv1a_64 RETURNS INTEGER SONAME 'libfnv1a_udf.so'"
mysql -u root -proot -e "CREATE FUNCTION fnv_64 RETURNS INTEGER SONAME 'libfnv_udf.so'"
mysql -u root -proot -e "CREATE FUNCTION murmur_hash RETURNS INTEGER SONAME 'libmurmur_udf.so'"

mysql -u root -proot -e "create user grafana@localhost IDENTIFIED BY 'grafana'"
mysql -u root -proot -e "grant select, REPLICATION SLAVE on *.* to grafana@'%';"
mysql -u root -proot -e "create user grafana@localhost IDENTIFIED BY 'grafana'"
mysql -u root -proot -e "grant select, REPLICATION SLAVE on *.* to grafana@'%';"




```

### Setup firewall and port forwarding
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

Setup port forwarding port 3101 to 3306 in db1. 

* Setup port forwarding in Virtual Box to Linux installation.
    * Select the running server "db1"
    * Devices -> Network -> Network Settings
        * Adapter 1 -> Attached to -> NAT
        * Click on Advanced and then port forwarding
            * Enter
            * Name : Rule1
            * Protocol : TCP
            * Host Ip: 0.0.0.0
            * Host Port : 3101
            * Guest IP : 10.0.2.15
	    * Guest Port : 3306

* Test connection on host: mysql -u root -proot -h 127.0.0.1 -e "select 'good'" -P 3101

* * *
<a name=g></a>Setup Grafana on admin server
-----
Install Grafana, Promethesus, mysqld_exporter, and telegraph

* https://grafana.com/docs/grafana/latest/setup-grafana/installation/debian/

Switch to your "admin" server. 

```
sudo apt-get install -y apt-transport-https software-properties-common wget

sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null

echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

sudo apt-get update

sudo apt-get -y install grafana

  # start,  verify and configure as boot. 
sudo systemctl daemon-reload
sudo systemctl start grafana-server
sudo systemctl status grafana-server
sudo systemctl enable grafana-server.service

 sudo /bin/systemctl daemon-reload
 sudo /bin/systemctl enable grafana-server
### You can start grafana-server by executing
 sudo /bin/systemctl start grafana-server


```
### Setup the firewall and port forwarding.

* https://www.action1.com/how-to-block-or-allow-tcp-ip-port-in-windows-firewall/
* In Windows, type in firewall in the search field and select "Firewall Network and Protection.
* Click on Inbound rules, and select New.
* Click port
* Enter port 3000
* Click Block connection
* Select domain, private, and public
* name it : A block grafana 3000 
* Click on finish

Setup port forwarding port 3101 to 3306 in db1.

* Setup port forwarding in Virtual Box to Linux installation.
    * Select the running server "admin"
    * Devices -> Network -> Network Settings
        * Adapter 1 -> Attached to -> NAT
        * Click on Advanced and then port forwarding
            * Enter
            * Name : Rule1
            * Protocol : TCP
            * Host Ip: 0.0.0.0
            * Host Port : 3000
            * Guest IP : 10.0.2.15
            * Guest Port : 3000



-------------------------

```
myysql
status
show slave status
/var/log/messegs
dmesg | egrep -i "mysql|restart"
tail mysql log
lastlog
sudo cat /var/log/auth.log | more

## Once you find out who you are looking for
tail /home/user_name/.bash_history
or
tail /root/.bash_history

spy
sysdig -c spy_users

```