
---
title : MySQL Install
author : Mark Nielsen
copyright : February  2024
---


MySQL Install
==============================

_**by Mark Nielsen
Original Copyright Feb 2021**_

1. [Links](#links)
2. [Percona Manually by repository](#manual)
3. [Percona binaries](#binaries)
2. [Single Server](#single)
3. [MySQL Replication](#rep)
4. [MySQL Replication GTID an semi-scychronous](#gits)

* * *
<a name=links></a>Links
-----
* MySQL Server
* [Percona repsositories](https://docs.percona.com/percona-software-repositories/installing.html)
* [Percona binaries](https://repo.percona.com/)
* [MySQL Cluster install Ansible](https://github.com/garutilorenzo/ansible-role-linux-mysql/tree/master)


* * *
<a name=manual></a>Percona Manually
-----

```bash
sudo bash

apt install curl
curl -O https://repo.percona.com/apt/percona-release_latest.generic_all.deb
apt install gnupg2 lsb-release ./percona-release_latest.generic_all.deb
sudo apt update
sudo percona-release setup ps80

cat /etc/apt/sources.list.d/percona-original-release.list

   #It may ask you to supply the root password, 
sudo apt install percona-server-server


```

Post install tasks

```sql
  # log in as mysql
  # It will ask you for the root password. 
mysql -u root -p

  # execute in mysql
CREATE FUNCTION fnv1a_64 RETURNS INTEGER SONAME 'libfnv1a_udf.so';
CREATE FUNCTION fnv_64 RETURNS INTEGER SONAME 'libfnv_udf.so';
CREATE FUNCTION murmur_hash RETURNS INTEGER SONAME 'libmurmur_udf.so';

```

To uninstall

```bash

 apt list --installed | grep -i percona
apt remove  percona-release percona-server-client percona-server-common percona-server-server

```




https://repo.percona.com/