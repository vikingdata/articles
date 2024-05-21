 
---
title : MySQL: Xtrabackup restore onedatabase
author : Mark Nielsen  
copyright : May 2024  
---


MySQL: Xtrabackup restore onedatabase
==============================

_**by Mark Nielsen
Original Copyright May 2024**_

NOT DONE

1. [Links](#links)
2. [Installing Xtrabackup](#i)
3. [Setting up data](#s)
4. [Backup data](#b)
5. [Restore one database](#r)

* * *
<a name=Links></a>Links
-----
* https://docs.percona.com/percona-xtrabackup/8.0/installation.html

* * *
<a name=i></a> Installing Xtrabackup

-----

I am using LinutMint, jammy Ubuntu comptaible.

* Go to : https://www.percona.com/downloads
* Go to Percona XtraDB Cluster on the page
* Select version and platform
   * Choose 8.1.0-1 and Ubuntu Jammy
* select file(s)
    * percona-xtrabackup-83_8.3.0-1-1.jammy_amd64.deb
        * I am using 8.0.36 MySQL
* Clicked on donwload link or
    * [This](https://downloads.percona.com/downloads/Percona-XtraBackup-innovative-release/Percona-XtraBackup-8.3.0-1/binary/debian/jammy/x86_64/percona-xtrabackup-83_8.3.0-1-1.jammy_amd64.deb?_gl=1*2ekmol*_gcl_au*MTg3NjMzMTYxOS4xNzEzMzE2NDAx)

```
dpkg -i  percona-xtrabackup-83_8.3.0-1-1.jammy_amd64.deb


```

* * *
<a name=s></a>Setting up data
-----

* * *
<a name=b></a>Backup data
-----

* * *
<a name=r></a>Restore one database
-----
