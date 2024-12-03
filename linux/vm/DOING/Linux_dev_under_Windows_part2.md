
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
* [Grapaha](#g)

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
    * The second server name db1 and use port 2001
    * The third server name db2 and use port 2002
    * The fourth server should be db3 and use port 2003. 

* Test the connections
    * ssh 127.0.0.1 -p 2000 -l root "echo '2000 good'"
    * ssh 127.0.0.1 -p 2001 -l root "echo '2001 good'"
    * ssh 127.0.0.1 -p 2002 -l root "echo '2002 good'"
    * ssh 127.0.0.1 -p 2003 -l root "echo '2003 good'"

* * *
<a name=db1_mysql></a>Install MySQL on db1 manually
-----
**** Include Percona + mysql tools for ClusterSet later. 

**** Setup firewall and port forwarding
Setup firewall for port 3001

* https://www.action1.com/how-to-block-or-allow-tcp-ip-port-in-windows-firewall/
* In Windows, type in firewall in he search field and select "Firewall Network and Protection.
* Click on Inbound rules, and select New.
* Click port
* Enter port 3001
* Click Block connection
* Select domain, private, and public
* name it : A block mysql 3001
* Click on finish

Setup port forwarding port 3001 to 3306 in db1. 

* Setup port forwarding in Virtual Box to Linux installation.
    * Select the running server "db1"
    * Devices -> Network -> Network Settings
        * Adapter 1 -> Attached to -> NAT
        * Click on Advanced and then port forwarding
            * Enter
            * Name : Rule1
            * Protocol : TCP
            * Host Ip: 0.0.0.0
            * Host Port : 3001
            * Guest IP : 10.0.2.15
	    * Guest Port : 3306

* Test connection on host: mysql -u root -proot -h 127.0.0.1 -e "select 'good'" -P 3001

* * *
<a name=g></a>Setup Grahana
-----
Install Grapahana, Promethesus, mysqld_exporter, and telegraph





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