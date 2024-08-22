
---
title : Percona Galera Mysql
author : Mark Nielsen
copyright : August 2024 
---


Percona Galera Mysql
==============================

_**by Mark Nielsen
Original Copyright August 2024**_

We will install it on one computer. It is meant for functional testing and not performance. 

* [Links](#links)
* [Install on one server](#install)
* [Variables to pay attention to](#vars)
* [Command line monitoring](#mon)

* * *
<a name=Links></a>Links
-----
* Adding ip via rc.local
    * I couldn't figure out network.services
    * https://www.linuxbabe.com/linux-server/how-to-enable-etcrc-local-with-systemd
* Install
    * https://docs.percona.com/percona-software-repositories/index.html
    * https://docs.percona.com/percona-xtradb-cluster/5.7/install/apt.html#apt
* https://severalnines.com/blog/improve-performance-galera-cluster-mysql-or-mariadb/


* * *
<a name=ip></a>Add ip addresses to Ubuntu
-----
```
echo "

[Unit]
 Description=/etc/rc.local Compatibility
 ConditionPathExists=/etc/rc.local

[Service]
 Type=forking
 ExecStart=/etc/rc.local start
 TimeoutSec=0
 StandardOutput=tty
 RemainAfterExit=yes
 SysVStartPriority=99

[Install]
 WantedBy=multi-user.target


" > /etc/systemd/system/rc-local.service

echo '#!/bin/bash

/usr/sbin/ifconfig lo:2 127.0.0.2 netmask 255.0.0.0 up
/usr/sbin/ifconfig lo:3 127.0.0.3 netmask 255.0.0.0 up
/usr/sbin/ifconfig lo:4 127.0.0.4 netmask 255.0.0.0 up
/usr/sbin/ifconfig lo:5 127.0.0.5 netmask 255.0.0.0 up
/usr/sbin/ifconfig lo:6 127.0.0.6 netmask 255.0.0.0 up

' > /etc/rc.local

chmod +x /etc/rc.local

/etc/rc.local

  # Test with ifconfig

ifconfig | grep -i lo:

  # Optional, test with ping
for i in 2 3 4 5 6; do ping -c 1 127.0.0.$i; done

  # enable it on reboot
systemctl enable rc-local

```

* * *
<a name=install></a>Install on one server
-----

```

apt remove apparmor
apt update
apt install curl 


curl -O https://repo.percona.com/apt/percona-release_latest.generic_all.deb
apt install gnupg2 lsb-release ./percona-release_latest.generic_all.deb
sudo apt update

  ## we want 5.6, because we want to upgrade. 
  ## You will be asked to supply a password, for testing purposes only use "root" for password
apt install percona-xtradb-cluster-56


  # Stop mysql

service mysql stop

```
* * *
<a name=vars></a>Variables to pay attention to
-----

* * *
<a name=mon></a>Command line monitoring
-----

* * *
<a name=add></a>Add a Node
-----

* * *
<a name=remove></a>Remove a Node
-----

* * *
<a name=backups></a>Backups
-----

* * *
<a name=upgrade></a>Upgrade to 5.7
-----
