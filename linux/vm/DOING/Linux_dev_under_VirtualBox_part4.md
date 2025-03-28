
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
* Setup mysql and accounts
* Install grafana and promethesus on admin1 and Telegraf on the db servers
    * Telegraf will make data
    * Promethesus will gather data
       * It also also report, display, and monitor servers.
    * Grafana will gather data from Promethesus for monitoring. 

* [Links](#links)
* [3 db servers](#3)
* [MySQL](#m)
* [Install Telegraph and configure for promethesus](#t)
* [Install Promethesus](#t)
* [Grafana + promethesus](#g)

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

The end goal is to have 3 servers db1, db2, and db3. Each with ports
 2101, 2102, and 2103 on the host pointing to them at their port ssh 22. In addition, each
admin server can ssh to the other servers. 

* Now import the image as described in [Part 1](https://github.com/vikingdata/articles/blob/main/linux/vm/Linux_dev_under_Windows_part1.md#copies)
    * In Virtual Box, select Import Appliance
    * For File, put in C:\shared\UbuntuBase.ova
        * Or whatever you saved the base ubuntu image as.
    * Change settings
    * Name : admin2
    * Mac Address Policy : "Generate new"
    * click Finish
    * Start the instance
* Setup the firewall and port forward as in [Part 1](https://github.com/vikingdata/articles/blob/main/linux/vm/Linux_dev_under_Windows_part1.md#nat2) 
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
        * The port forwarding might need to be edited instead of making new ones.
        * db1 server should use port 2101  on host
        * db2 server should use port 2102  on host
        * db3 server should use port 2103  on host

* On each server, change the hostname
    * db1 :   hostnamectl set-hostname db1.myguest.virtualbox.org
    * db2 :   hostnamectl set-hostname db2.myguest.virtualbox.org
    * db3 :   hostnamectl set-hostname db3.myguest.virtualbox.org

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
    * ssh 127.0.0.1 -p 2101 -l root "echo '2101 good'"
    * ssh 127.0.0.1 -p 2102 -l root "echo '2202 good'"
    * ssh 127.0.0.1 -p 2103 -l root "echo '2303 good'"

* Make alias in .bashrc in Cygwin or WSL
```
cp ~/.bashrc ~/.bashrc_`date +%Y%m%d`

echo "
alias ssh_db1='ssh 127.0.0.1 -p 2101 -l root'
alias ssh_db2='ssh 127.0.0.1 -p 2202 -l root'
alias ssh_db3='ssh 127.0.0.1 -p 2303 -l root'
" >> ~/.bashrc
source ~/.bashrc

```
* In Windows, in cygwin or WSL. This should be unecessary. The base image should already have this.
```
for port in  2101 2102 2013; do
  ssh-copy-id -o "StrictHostKeyChecking no" -p $port -i ~/.ssh/id_rsa.pub root@127.0.0.1
  ssh -p $port root@127.0.0.1 "echo 'ssh firewall $port ok'"
done

#for port in 2102 2103; do
#  echo "transferring private and public keys to $port"
#  rsync -av  ~/.ssh/id_rsa.pub  ~/.ssh/id_rsa root@127.0.0.1:$port/.ssh
#done



```


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

* [Install Telegraph and configure for promethesus](#t)
* [Install Promethesus](#t)

* * *
<a name=t></a>Install Telegraph and configure for promethesus on db1
-----
* https://docs.influxdata.com/telegraf/v1/install/
* https://github.com/influxdata/telegraf/tree/master/plugins/outputs/prometheus_client
* https://docs.influxdata.com/telegraf/v1/plugins/
    * Plugin ID: outputs.prometheus_client
* https://prometheus.io/
* https://www.influxdata.com/integration/prometheus-input/
* https://gist.github.com/sgnl/0973e4709eee64a8b91bc38dd71f9e05
* https://grafana.com/tutorials/stream-metrics-from-telegraf-to-grafana/

Connect to db1
* ssh to db1 : execute "ssh_db1" or "ssh root@127.0.0.1 -p 2101"

```
cd
mkdir -p telegraf
cd telegraf

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
telegraf --input-filter $plugins --output-filter prometheus_client:file config > telegraf.conf_template
# outputs.prometheus_client

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
    "# metric_version = 1"                  " metric_version = 2"
    "interval = \"10s"\"                    "interval = \"60s\""
    "logfile_rotation_max_size = \"100MB\""    logfile_rotation_max_size = \"10MB\""
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
  | sed -e "s/${rep[16]}/${rep[17]}/g" \
  | sed -e "s/${rep[18]}/${rep[19]}/g" \
  | sed -e "s/${rep[20]}/${rep[21]}/g" \
  | sed -e "s/\[\"tcp(127.0.0.1:3306)\/\"\]/\[\"telegraf:telegraf\@tcp(127.0.0.1:3306)\/?tls=false\"\]/" \ 
> telegraf.conf

egrep -i "prometheus|metric_version|listen|token|organization|bucket|logfile|telegrapf|mysql|3306" telegraf.conf | grep -v '#'

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
   logfile="/var/log/telegraf/telegraf.log"
   logfile_rotation_interval = "1h"
   logfile_rotation_max_size = "100MB"
   logfile_rotation_max_archives = 5
[[outputs.prometheus_client]]
  listen = ":9273"
  2 metric_version = 2
[[inputs.mysql]]
  servers = ["tcp(127.0.0.1:3306)/"]
  metric_version = 2

```

* * *
<a name=p></a>Install Promethesus on admin server
-----
* https://prometheus.io/docs/prometheus/latest/installation/
* https://github.com/prometheus-community/ansible
* https://www.cherryservers.com/blog/install-prometheus-ubuntu
* https://ibrahims.medium.com/how-to-install-prometheus-and-grafana-on-ubuntu-22-04-lts-configure-grafana-dashboard-5d11e3cb3cfd
* https://prometheus.io/docs/prometheus/latest/configuration/configuration/
* https://medium.com/@parikshitaksande/a-step-by-step-guideto-setup-prometheus-server-for-monitoring-b444a2978ba9
* https://prometheus.io/docs/tutorials/getting_started/

Ibstall promethesus on admin server. Unfortuantely, you have to download binaries or source source, compile
and install it. We will download binaries, which for production you  should not do. 
```
sudo bash

useradd --shell /bin/false prometheus

mkdir -p  /etc/prometheus
mkdir -p /var/lib/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus 

cd
mkdir prometheus
cd prometheus

wget https://github.com/prometheus/prometheus/releases/download/v2.53.3/prometheus-2.53.3.linux-amd64.tar.gz
tar -zxvf prometheus-2.53.3.linux-amd64.tar.gz
cd prometheus-2.53.3.linux-amd64/

mv -f console* /etc/prometheus
cp -f prometheus.yml /etc/prometheus
cp -f prometheus.yml /etc/prometheus/prometheus.yml_orig
chown -R prometheus:prometheus /etc/prometheus

mv prometheus /usr/local/bin
mv promtool /usr/local/bin
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool

mkdir -p  /etc/prometheus/scrape
chown  prometheus:prometheus /etc/prometheus/scrape

echo "
scrape_config_files:
  - /etc/prometheus/scrape/*.yml

# Storage related settings that are runtime reloadable.
storage:
  - tsdb: 
    - path:
      - /var/lib/prometheus/

scrape_configs:
- job_name: telegraf
  static_configs:
  - targets:
    - "10.0.2.7:9273"
" 


```

#### In Windows

* Setup firewall
    * https://www.action1.com/how-to-block-or-allow-tcp-ip-port-in-windows-firewall/
    * In Windows, type in firewall in he search field and select "Firewall Network and Protection.
    * Click on Inbound rules, and select New.
        * Click port
        * Enter port 9009
        * Click Block connection
        * Select domain, private, and public
        * name it : A block promethesus 9090
        * Click on finish


#### Setup port forwarding port 9090 to 9090 in admin.

* Setup port forwarding in Virtual Box to Linux installation.
    * Select the running server "admin"
    * Devices -> Network -> Network Settings
        * Adapter 1 -> Attached to -> NAT
        * Click on Advanced and then port forwarding
            * Enter
            * Name : Rule5
            * Protocol : TCP
            * Host Ip: 127.0.0.1
            * Host Port : 9090
            * Guest IP : 10.0.2.6
            * Guest Port : 9090

### Start prometheus
```
sudo touch /etc/systemd/system/prometheus.service
echo "[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target
​
[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries
​
[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/prometheus.service

sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
sudo systemctl status prometheus

```
# log_level debug

global

query_log_file: /prometheus/query.log


/etc/logrotate.d/prometheus
/prometheus/query.log {
    daily
    rotate 7
    compress
    delaycompress
    postrotate
        killall -HUP prometheus
    endscript
}

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