
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

echo "#!/bin/bash

/usr/sbin/ifconfig lo:2 127.0.0.2 netmask 255.0.0.0 up
/usr/sbin/ifconfig lo:3 127.0.0.3 netmask 255.0.0.0 up
/usr/sbin/ifconfig lo:4 127.0.0.4 netmask 255.0.0.0 up
/usr/sbin/ifconfig lo:5 127.0.0.5 netmask 255.0.0.0 up
/usr/sbin/ifconfig lo:6 127.0.0.6 netmask 255.0.0.0 up

" > /etc/rc.local

chmod +x /etc/rc.local

systemctl enable rc-local

```

* * *
<a name=install></a>Install on one server
-----

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

