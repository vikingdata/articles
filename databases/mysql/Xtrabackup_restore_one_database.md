 
---
title : MySQL 8: Xtrabackup restore onedatabase
author : Mark Nielsen  
copyright : May 2024  
---


MySQL 8: Xtrabackup restore onedatabase
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
* [full backups](https://docs.percona.com/percona-xtrabackup/8.0/create-full-backup.html#:~:text=To%20create%20a%20backup%2C%20run,the%20location%20of%20those%2C%20too.)
* [Percona XtraBackup: Backup and Restore of a Single Table or Database](https://www.percona.com/blog/percona-xtrabackup-backup-and-restore-of-a-single-table-or-database/)
* [Recover MySQL Database from FRM and IBD Files](https://community.spiceworks.com/t/recover-mysql-database-from-frm-and-ibd-files/10143940)

* * *
<a name=i></a> Installing Xtrabackup

-----

I am using LinutMint, jammy Ubuntu comptaible.

* Go to : https://www.percona.com/downloads
* Go to Percona XtraDB Cluster on the page
* I switched to Percona XtraBackup 8.0
* Select version and platform
   * Choose mysql 8.0.35 and Ubuntu Jammy
* select file(s)
    * percona-xtrabackup-82_8.2.0-1-1.jammy_amd64.deb
* Clicked on donwload link or
    * [This](https://downloads.percona.com/downloads/Percona-XtraBackup-8.0/Percona-XtraBackup-8.0.35-30/binary/debian/jammy/x86_64/percona-xtrabackup-80_8.0.35-30-1.jammy_amd64.deb?_gl=1*1vehs2w*_gcl_au*MTg3NjMzMTYxOS4xNzEzMzE2NDAx)

```

wget -O https://downloads.percona.com/downloads/Percona-XtraBackup-8.0/Percona-XtraBackup-8.0.35-30/binary/debian/jammy/x86_64/percona-xtrabackup-80_8.0.35-30-1.jammy_amd64.deb?_gl=1*1vehs2w*_gcl_au*MTg3NjMzMTYxOS4xNzEzMzE2NDAx

 ls -al p.deb
#  -rw-r--r-- 1 root root 44310224 Mar 12 02:17 p.deb

  # Ignore if says th
dpkg -i  p.deb

apt list --installed | egrep percona-xtra
# percona-xtrabackup-80/unknown,now 8.0.35-30-1.jammy amd64 [installed]


# install perl dependencies
apt-get install libdbd-mysql-perl
  # which failed so I did this and answered yes
apt --fix-broken install

```

* * *
<a name=s></a>Setting up data
-----

I installed MySQL on /data/mysqld1 and its socket file /data/mysql1/mysqld1.sock.

Make the sql file
```
echo "
tee load.log
drop database if exists ptest1;
drop database if exists ptest2;
drop database if exists ptest3;
create database ptest1;
use ptest1;
create table p1 (i int, PRIMARY Key(i));
insert into p1 values (1);

create database ptest2;
use ptest2;
create table p2 (i int, PRIMARY Key(i));
insert into p2 values (2);

create database ptest3;
use ptest3;
create table p3 (i int, PRIMARY Key(i));
insert into p3 values(3);
" > load.sql

rm -f load.log

  # Logged in as root, with auth_socket password for the root acccount. 
mysql -e " source load.sql" -vvv -S  /data/mysql1/mysqld1.sock

# Yours might be
mysql -u root -p<PASSSWORD> -e " tee load.log; source loads.sql" -vvv

# Or log in as mysql and do
source load.sql

```

* * *
<a name=b></a>Backup data
-----

```
   # Change your datadir and target destination
DEFAULTS_FILE=/data/mysql1/mysqld1.cnf
TARGET_DIR=/data/mysql_test_restore

  # Comment if you keep other things in this directory you want to keep. 
rm -rf $TARGET_DIR

mkdir -p TARGET_DIR

xtrabackup --defaults-file=$DEFAULTS_FILE --backup --target-dir=$TARGET_DIR

xtrabackup --prepare --target-dir=$TARGET_DIR


```


* * *
<a name=r></a>Restore one database
-----

* NOTE
    * You probably don't need the socket file.
    * You might want to add -u and -p is needed for username and password.
        * Login like this : mysql -u <NAME> -p
	* and then enter the commands for mysql

* Check files are different
```
ls -al /data/mysql_test_restore/ptest1/p1.ibd /data/mysql1/db/ptest1/p1.ib

# Change data and verify
mysql -e " insert into p1 values (10);" ptest1  -S  /data/mysql1/mysqld1.sock
mysql -e " select * from p1 ;" ptest1  -S  /data/mysql1/mysqld1.sock  

   # Discard table, cop old table reimport old table
mysql -e "alter table p1 DISCARD TABLESPACE;" ptest1  -S  /data/mysql1/mysqld1.sock
rsync -av /data/mysql_test_restore/ptest1/p1.ibd /data/mysql1/db/ptest1
chown mysql /data/mysql1/db/ptest1/p1.ibd
mysql -e "alter table p1 IMPORT TABLESPACE;" ptest1  -S  /data/mysql1/mysqld1.sock  

   # Verify data is old table, Verify old table is now the same as live table. 
ls -al /data/mysql_test_restore/ptest1/p1.ibd /data/mysql1/db/ptest1/p1.ib
mysql -e " select * from p1 ;" ptest1  -S  /data/mysql1/mysqld1.sock 

```

