 
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
    * percona-xtrabackup-81_8.1.0-1-1.jammy_amd64.deb
* Clicked on donwload link or
    *[This](https://downloads.percona.com/downloads/Percona-XtraBackup-innovative-release/Percona-XtraBackup-8.1.0-1/binary/debian/jammy/x86_64/percona-xtrabackup-test-81_8.1.0-1-1.jammy_amd64.deb?_gl=1*o2958s*_gcl_au*MTg3NjMzMTYxOS4xNzEzMzE2NDAx)

```
sudo
mkdir xtrabackup_install
cd xtrabackup_install

wget https://downloads.percona.com/downloads/Percona-XtraBackup-LATEST/Percona-XtraBackup-8.0.26-18/binary/debian/focal/x86_64/percona-xtrabackup-80_8.0.26-18-1.focal_amd64.de
sudo dpkg -i percona-xtrabackup-80_8.0.26-18-1.focal_amd64.deb



```

or because I am using linux Mint

```


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
