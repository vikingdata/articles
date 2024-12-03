
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
* [3 servers](#3)
* [Ansible](#a)
* [MySQL](#m)
* [Grpaha](#g)

* * *

<a name=links></a>Links
-----
* [Part 1](https://github.com/vikingdata/articles/blob/main/linux/vm/Linux_dev_under_Windows_part1.md)

* * *
<a name=3></a>4 servers
-----

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
    * The second server name db1 and use port 2002
    * The third server name   db2 and use port 2003
    * The fourth server should be db3 and use port 2004. 

* * *
<a name=3></a>Install MySQL on 3 servers manually.
-----
For now, we will just install 3 MySQL servers were one is the Master and
two are Slaves.

* Down install MySQL files and configuration files.
* Restart MySQL.
* Setup replication.

* * *
<a name=m></a>Install Monitoring software.
-----
* Install Grapaha on admin server.
* Install promethesus on admin server.
* Install MySQL on db1 manually.
    * Install Percona
    * Install MySQL programs for MySQL ClusterSet.
* Install mysqld_exporter on db1 and hook up to grafana. 
* Install telegraph on db1 and hook up to grafana.
xs



-------------------------

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