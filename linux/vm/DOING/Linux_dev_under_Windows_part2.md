
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

In general
* Setup mysql and accounts
* Install Influxdb and Telegraf
    * Install InfluxDB where we will store our data.
    * Install Telegraf which will fill InfluxDB with data.
        * View data on influxdb webpage.
    * Connect Grafana to InfluxDB
        * View the data in Grafana. 

* [Links](#links)
* [4 servers](#4)
* [MySQL](#m)
* [Grafana](#g)
* [Install Telegraph and configure grafana](#t)

* * *

<a name=links></a>Links
-----
* [Part 1](https://github.com/vikingdata/articles/blob/main/linux/vm/Linux_dev_under_Windows_part1.md)
* https://logz.io/blog/grafana-tutorial/
* https://grafana.com/docs/grafana/latest/developers/http_api/data_source/
* https://www.youtube.com/watch?v=Dcumy5Ir1Ag
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
* Make alias in .bashrc
```
cp ~/.bashrc ~/.bashrc_`date +%Y%m%d`

echo "
alias ssh_admin='ssh 127.0.0.1 -p 2000 -l root'
alias ssh_db1='ssh 127.0.0.1 -p 2001 -l root'
alias ssh_db2='ssh 127.0.0.1 -p 2002 -l root'
alias ssh_db3='ssh 127.0.0.1 -p 2003 -l root'
" >> ~/.bashrc
source ~/.bashrc


```
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

mysql -u root -proot -e "create user telegraf@localhost IDENTIFIED BY 'telegraf'"
mysql -u root -proot -e "GRANT SELECT ON performance_schema.* TO 'telegraf'@'localhost';"
mysql -u root -proot -e "GRANT PROCESS ON *.* TO 'telegraf'@'localhost';"
mysql -u root -proot -e "GRANT REPLICATION CLIENT ON *.* TO 'telegraf'@'localhost';"


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
apt-get install -y apt-transport-https software-properties-common wget

mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null

echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

apt-get update

apt-get -y install grafana

  # start,  verify and configure as boot. 
systemctl daemon-reload
systemctl start grafana-server
systemctl status grafana-server
systemctl enable grafana-server.service

```
* Test the grafana url : <a href="http://127.0.0.1:3000" target=grafana>http://127.0.0.1:3000</a>
     * For user and password, enter "admin"
     * It will ask for you to change your password. 

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

* * *

<a name=t></a>Install Telegraph and configure grafana
-----
* https://docs.influxdata.com/telegraf/v1/install/
* https://gist.github.com/sgnl/0973e4709eee64a8b91bc38dd71f9e05
* https://grafana.com/tutorials/stream-metrics-from-telegraf-to-grafana/

### Install Influxdb locally
*  https://docs.influxdata.com/influxdb/v2/install/?t=Linux

```

curl --silent --location -O \
https://repos.influxdata.com/influxdata-archive.key
echo "943666881a1b8d9b849b74caebf02d3465d6beb716510d86a39f6c8e8dac7515  influxdata-archive.key" \
| sha256sum --check - && cat influxdata-archive.key \
| gpg --dearmor \
| tee /etc/apt/trusted.gpg.d/influxdata-archive.gpg > /dev/null \
&& echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive.gpg] https://repos.influxdata.com/debian stable main' \
| tee /etc/apt/sources.list.d/influxdata.list

apt-get update && apt-get -y install influxdb2

echo "" >> /etc/influxdb/config.toml
echo 'http-bind-address = ":8086"' >> /etc/influxdb/config.toml

sudo service influxdb start

service --status-all

influx setup -f -u admin -p  admin123  -o myorg -b bucket1 -r 10h -t 1234567890

key_influx=`create   --org myorg   --all-access | egrep -v "^ID" | cut -d "[" -f1 | sed -e 's/\t/ /g' | sed -e "s/  */ /g"| cut -d " " -f2`

echo "my influx key is:$key_influx"

curl -H'Content-Type: application/json' -vi -XPOST -d'{"name":"test0","type":"elasticsearch","url":"http://localhost:9200","access":"proxy","database":"demo-azure.log","user":"admin","password":"admin"}' http://admin:admin@localhost:3000/api/datasources

TODO: make token for grafana

```

To reset influxdb

```
service influxdb stop
rm -f /var/lib/influxdb/influxd.*
rm -rf ~/.influxdbv2
service influxdb start
influx setup -f -u influxdb -p  influxdb  -o myorg -b bucket1 -r 10h -t 1234567890

```
* Test login
    * Use "admin" and "admin123" for the user and password.
    * On the virtual host: http://10.0.2.15:8086 or http://127.0.0.1:8086
    * On host : http://127.0.0.1:8801/


### Setup the firewall and port forwarding for telegraph

* https://www.action1.com/how-to-block-or-allow-tcp-ip-port-in-windows-firewall/
* In Windows, type in firewall in the search field and select "Firewall Network and Protection.
* Click on Inbound rules, and select New.
* Click port
* Enter port 8801
* Click Block connection
* Select domain, private, and public
* name it : A block grafana 8801
* Click on finish

Setup port forwarding port 8801 to 8086 in db1.

* Setup port forwarding in Virtual Box to Linux installation.
    * Select the running server "admin"
    * Devices -> Network -> Network Settings
        * Adapter 1 -> Attached to -> NAT
        * Click on Advanced and then port forwarding
            * Enter
            * Name : Rule1
            * Protocol : TCP
            * Host Ip: 0.0.0.0
            * Host Port : 8801
            * Guest IP : 10.0.2.15
            * Guest Port : 8086

### On db1, install Infludb, Telegraf, and add mysql to Telegraf



```
mkdir influx
cd influx

curl --silent --location -O \
https://repos.influxdata.com/influxdata-archive.key \
&& echo "943666881a1b8d9b849b74caebf02d3465d6beb716510d86a39f6c8e8dac7515  influxdata-archive.key" \
| sha256sum -c - && cat influxdata-archive.key \
| gpg --dearmor \
| sudo tee /etc/apt/trusted.gpg.d/influxdata-archive.gpg > /dev/null \
&& echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive.gpg] https://repos.influxdata.com/debian stable main' \
| sudo tee /etc/apt/sources.list.d/influxdata.list
apt-get update && sudo apt-get install telegraf


  # https://docs.influxdata.com/telegraf/v1/plugins/#input-plugins
export plugins="cpu:mem:disk:diskio:kernel:kernel_vmstat:processes:swap:system:mysql"
telegraf --input-filter $plugins --output-filter influxdb_v2:file config > telegraf.conf_template

mkdir -p /var/lib/telegraf
chown telegraf.telegraf /var/lib/telegraf

rep=(
    "# logfile = \"\""                      " logfile=\"\/var\/log\/telegraf\/telegraf.log\""
    "# logfile_rotation_interval = \"0h\""  " logfile_rotation_interval = \"1h\""
    "# logfile_rotation_max_size = \"0MB\"" " logfile_rotation_max_size = \"100MB\""
    "# logfile_rotation_max_archives = 5"   " logfile_rotation_max_archives = 5"
    "files = \[\"stdout\", \"\/tmp\/metrics.out\"\]" "files = \[\"stdout\", \"\/var\/lib\/telegraf\/metrics.out\"\]"
    " token = \"\""                         " token = \"1234567890\""
    " organization = \"\""                  " organization = \"myorg\""
    " bucket = \"\""                        " bucket = \"bucket1\""
)
# "\[\"tcp\(127.0.0.1:3306\)\/\"\]
sed -e "s/${rep[0]}/${rep[1]}/g" telegraf.conf_template \
  | sed -e "s/${rep[2]}/${rep[3]}/g" \
  | sed -e "s/${rep[4]}/${rep[5]}/g" \
  | sed -e "s/${rep[6]}/${rep[7]}/g" \
  | sed -e "s/${rep[8]}/${rep[9]}/g" \
  | sed -e "s/${rep[10]}/${rep[11]}/g" \
  | sed -e "s/${rep[12]}/${rep[13]}/g" \
  | sed -e "s/${rep[14]}/${rep[15]}/g" \
  | sed -e "s/\[\"tcp(127.0.0.1:3306)\/\"\]/\[\"telegraf:telegraf\@tcp(127.0.0.1:3306)\/?tls=false\"\]/" \ 
> telegraf.conf

egrep -i "influx|8086|token|organization|bucket|logfile|telegrapf|mysql|3306" telegraf.conf | grep -v '#'

mv /etc/telegraf/telegraf.conf /etc/telegraf/telegraf.conf_orig
cp telegraf.conf /etc/telegraf/telegraf.conf

# OPTIONAL: test it
telegraf --config telegraf.conf
   ## Kill it ith Ctrl-C


chown -R telegraf.telegraf /var/lib/telegraf /var/log/telegraf
systemctl start telegraf

tail -f /var/log/telegraf/telegraf.log


```

Output of egrep
```
[[outputs.influxdb_v2]]
  urls = ["http://127.0.0.1:8086"]
  token = "1234567890"
  organization = "myorg"
  bucket = "bucket1"
  data_format = "influx"
[[inputs.mysql]]
  servers = ["telegraf:telegraf@tcp(127.0.0.1:3306)/?tls=false"]
```


### Setup firewall and port forwarding for telegraf on db1


### Configure Grafana to connect to Influxdb

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