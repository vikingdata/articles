---
title : MySQL To Percona Innodb Cluster
author : Mark Nielsen
copyright : January 2026
---


MySQL to Percona InnoDB cluster
=============================

_**by Mark Nielsen
Copyright January 2026**_


1. [Links](#links)
2. [Requirements](#r)
2. [Steps](#s)

* * *
<a name=links></a>Links
-----

TODO: Link these links
* Setup Virtual Box, base image, firewall 3 ports, 3 virtual box images
  and port forwarding
    * Virtual Box Install
    * Making a base image
    * Setup 3 firewalled ports
    * Setup 3 virtual box servers
    * Do port forwarding and Nat Network

* * *
<a name=r></a>Requirements
-----
* Virtual Box installed
     * Installed on Windows 11
     * Installing Oracle Linux 8 under VirtualBox
     * Linux instances use Nat Network so they can see each other.
     * You use port forwarding in VirtualBox to ssh to a windows port which
        ssh to the Linux instances on port 22.
     * You block he windows ports with firewall from the outside.	
* OracleLinux 8.10
* MySQL 8.0.43 InnoDB CLuster
* Converting to Percona 8.4.7 Innodb Cluster (not Galera Cluster)
* Turn on auditing in Percona

* * *
<a name=s></a>Steps
-----

Steps
* Setup install directory
```
mkdir -p mysql_to_percona
cd mysql_to_percona

* Download install files

```
httpd_main="https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main"
loc=$httpd_main/databases/mysql/mysql_to_percona_innodb_cluster_files"

wget -O global_vars.sh $loc/global_vars.txt
wget -O ssh_install.sh $loc/ssh_install.txt

 

```
* Edit global_vars.sh for your servers. 

* Execute scripts

```

source global_vars.sh

echo ' install ssh'
bash ssh_install.sh


```