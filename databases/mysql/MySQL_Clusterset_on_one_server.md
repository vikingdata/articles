 
---
title : MySQL Clusterset on one server
author : Mark Nielsen  
copyright : May 2024
---



==============================

_**by Mark Nielsen
Original Copyright May 2024
**_

NOT DONE YET

1. [Links](#links)
2. [Install Percona and mysqlsh](#i)
3. [Setup directories and files for MySQL ClusterSet](#s)
4. [Start all instances](#s)
5. [Setup replica set](#r)
6. Reset

* * *
<a name=Links></a>Links
-----

* * *
<a name=n></a>Notes
-----

* Login
    * The socket file matches root@loacalhost 


* * *
<a name=i>Install Percona MySQL, mysqlsh, mysql router on Ubuntu</a>
-----

```

sudo bash

apt install curl -y
curl -O https://repo.percona.com/apt/percona-release_latest.generic_all.deb
sudo apt install gnupg2 lsb-release ./percona-release_latest.generic_all.deb
sudo apt update
sudo percona-release setup ps80

#------------------------------------------
### If percona-release doesn't work, for example I run LinutMint which is Ubuntu comptabile

echo "
deb http://repo.percona.com/prel/apt jammy main
deb-src http://repo.percona.com/prel/apt jammy main
"> /etc/apt/sources.list.d/percona-prel-release.list

echo "
deb http://repo.percona.com/ps-80/apt jammy main
deb-src http://repo.percona.com/ps-80/apt jammy main
" > /etc/apt/sources.list.d/percona-ps-80-release.list

echo "
deb http://repo.percona.com/tools/apt jammy main
deb-src http://repo.percona.com/tools/apt jammy main
" > /etc/apt/sources.list.d/percona-tools-release.list

echo "
deb http://repo.percona.com/ps-57/apt jammy main
deb-src http://repo.percona.com/ps-57/apt jammy main
" >> /etc/apt/sources.list.d/percona-ps-57-release.list

apt-get update

#-----------------------------------------

# Disable app armor
# https://www.cyberciti.biz/faq/ubuntu-linux-howto-disable-apparmor-commands/

sudo ln -s /etc/apparmor.d/usr.sbin.mysqld /etc/apparmor.d/disable/
sudo apparmor_parser -R /etc/apparmor.d/usr.sbin.mysqld

# check with
 sudo aa-status | grep -i mysql

  # It will may ask for password for percona mysql
  # If it does, leave passwored blank and it will allow
  # root authetication by sudo to root only.
#sudo apt-get install percona-server-server-5.7

sudo apt install percona-server-server -y
  # If it asks for a password, just press enter.

  # Optional install a specific version
  # We must have 8.0.36 or earlier, because we download oracle's shell and router at 8.0.36
# apt list -a percona-server-server
# apt install  percona-server-server=8.0.35-27-1.jammy

sudo apt install percona-server-server -y

```

* * *
<a name=s>Setup directories and files for MySQL ClusterSet</a>
-----

```

for i in 1 2 3 4 5 6; do
  mkdir -p /data/mysql$i/db
  mkdir -p /data/mysql$i/log/innodb

  mkdir -p /data/mysql$i/log/binlog
  mkdir -p /data/mysql$i/log/relay

  mkdir -p /data/mysql$i/log/undo
  mkdir -p /data/mysql$i/log/redo
  mkdir -p /data/mysql$i/log/doublewrite
done

chown -R mysql.mysql /data/mysql*
chmod +w -R /data/mysql*/log /data/mysql*/db

echo "this is a dev server" > /data/THIS_IS_A_DEV_SERVER

  # Create a script to make local and remote account with admin privs.

mkdir -p /data/mysql_init/

   # create user account with most priviledges with no password, localhost. 
export root_file=/data/mysql_init/root_account.sql
echo "CREATE USER '$SUDO_USER'@'localhost' IDENTIFIED WITH auth_socket;" > $root_file
echo "grant all privileges on *.* to '$SUDO_USER'@'localhost';"          >>  $root_file

   # create root @ % with all privs. 
echo "CREATE USER 'root'@'%' IDENTIFIED by 'root';" > $root_file
echo "grant all privileges on *.* to 'root'@'%';"          >>  $root_file

echo "GRANT CLONE_ADMIN, CONNECTION_ADMIN, CREATE USER, EXECUTE, FILE, GROUP_REPLICATION_ADMIN, PERSIST_RO_VARIABLES_ADMIN, PROCESS, RELOAD, REPLICATION CLIENT, REPLICATION SLAVE, REPLICATION_APPLIER, REPLICATION_SLAVE_ADMIN, ROLE_ADMIN, SELECT, SHUTDOWN, SYSTEM_VARIABLES_ADMIN ON *.* TO 'root'@'%' WITH GRANT OPTION;
GRANT DELETE, INSERT, UPDATE ON mysql.* TO 'root'@'%' WITH GRANT OPTION;
GRANT ALTER, ALTER ROUTINE, CREATE, CREATE ROUTINE, CREATE TEMPORARY TABLES, CREATE VIEW, DELETE, DROP, EVENT, EXECUTE, INDEX, INSERT, LOCK TABLES, REFERENCES, SHOW VIEW, TRIGGER, UPDATE ON mysql_innodb_cluster_metadata.* TO 'root'@'%' WITH GRANT OPTION;
GRANT ALTER, ALTER ROUTINE, CREATE, CREATE ROUTINE, CREATE TEMPORARY TABLES, CREATE VIEW, DELETE, DROP, EVENT, EXECUTE, INDEX, INSERT, LOCK TABLES, REFERENCES, SHOW VIEW, TRIGGER, UPDATE ON mysql_innodb_cluster_metadata_bkp.* TO 'root'@'%' WITH GRANT OPTION;
GRANT ALTER, ALTER ROUTINE, CREATE, CREATE ROUTINE, CREATE TEMPORARY TABLES, CREATE VIEW, DELETE, DROP, EVENT, EXECUTE, INDEX, INSERT, LOCK TABLES, REFERENCES, SHOW VIEW, TRIGGER, UPDATE ON mysql_innodb_cluster_metadata_previous.* TO 'root'@'%' WITH GRANT OPTION;
" >> $root_file

  # Update the root local password to %
echo "set password for root@localhost = 'root';" >> $root_file
echo "FLUSH PRIVILEGES;" >> $root_file

  # create local user with most privs for all other hosts. 
echo "CREATE USER '$SUDO_USER'@'%' IDENTIFIED by '$SUDO_USER';"          >>  $root_file
echo "grant all privileges on *.* to '$SUDO_USER'@'%';"                  >>  $root_file

echo "select user,host,plugin,authentication_string from mysql.user ;" >>  $root_file

port=4000
for i in 1 2 3 4 5 6; do
  let port=$port+1

  cd /data/mysql$i
  wget -O mysqld$i.cnf_initialize https://raw.githubusercontent.com/vikingdata/articles/main/databases/mysql/MySQL_Clusterset_on_one_server_files/mysql.cnf_initialize
  wget -O mysqld$i.cnf https://raw.githubusercontent.com/vikingdata/articles/main/databases/mysql/MySQL_Clusterset_on_one_server_files/mysql.cnf

  sed -i "s/__NO__/$i/g"       mysqld$i.cnf_initialize
  sed -i "s/__PORT__/$port/g"  mysqld$i.cnf_initialize

  sed -i "s/__NO__/$i/g"       mysqld$i.cnf
  sed -i "s/__PORT__/$port/g"  mysqld$i.cnf

done

cd /lib/systemd/system/

for i in 1 2 3 4 5 6; do
  rm -f mysqld$i.service
  wget -O mysqld$i.service https://raw.githubusercontent.com/vikingdata/articles/main/databases/mysql/MySQL_Clusterset_on_one_server_files/mysql.service
  sed -i "s/__NO__/$i/g"  mysqld$i.service
done

systemctl daemon-reload

```


* * *
<a name=s>Start all instances</a>
-----

```
killall mysqld
sleep 2

sudo -u mysql /usr/sbin/mysqld --defaults-file=/data/mysql1/mysqld1.cnf_initialize --defaults-group-suffix= --initialize-insecure
sudo -u mysql /usr/sbin/mysqld --defaults-file=/data/mysql2/mysqld2.cnf_initialize --defaults-group-suffix= --initialize-insecure
sudo -u mysql /usr/sbin/mysqld --defaults-file=/data/mysql3/mysqld3.cnf_initialize --defaults-group-suffix= --initialize-insecure
sudo -u mysql /usr/sbin/mysqld --defaults-file=/data/mysql4/mysqld4.cnf_initialize --defaults-group-suffix= --initialize-insecure
sudo -u mysql /usr/sbin/mysqld --defaults-file=/data/mysql5/mysqld5.cnf_initialize --defaults-group-suffix= --initialize-insecure
sudo -u mysql /usr/sbin/mysqld --defaults-file=/data/mysql6/mysqld6.cnf_initialize --defaults-group-suffix= --initialize-insecure

sleep 2

   # See if they are still running
jobs

mysql -u root -p root -P 4001 "select @@hostname, now()"

   # test if you can connect
mysql -u root  -e "select @@hostname, now()" -S /data/mysql1/mysqld1.sock
mysql -u root  -e "select @@hostname, now()" -S /data/mysql2/mysqld2.sock
mysql -u root  -e "select @@hostname, now()" -S /data/mysql3/mysqld3.sock
mysql -u root  -e "select @@hostname, now()" -S /data/mysql4/mysqld4.sock
mysql -u root  -e "select @@hostname, now()" -S /data/mysql5/mysqld5.sock
mysql -u root  -e "select @@hostname, now()" -S /data/mysql6/mysqld6.sock


   # If so, kill and restart
killall mysqld
rm /data/mysql*/*.lock

systemctl daemon-reload

systemctl restart mysql1
systemctl restart mysql2
systemctl restart mysql3
systemctl restart mysql4
systemctl restart mysql5
systemctl restart mysql6


  # See if they started
ps auxw | grep mysqld


  # These next steps may be uncesssary.

  # If good, enable at restart, and then restart them
systemctl enable mysql1
systemctl enable mysql2
systemctl enable mysql3
systemctl enable mysql4
systemctl enable mysql5
systemctl enable mysql6

   # restart them using service 
service mysql1 restart
service mysql2 restart
service mysql3 restart
service mysql4 restart
service mysql5 restart
service mysql6 restart


```

* * *
<a name=r>Setup CluserSet</a>
-----

```
 #

mysqlsh -u root -proot -h 192.168.1.7 -P 4011

dba.creatcluster('test')

watch -n 1 "clear;ps auxw | grep mysqld$| grep -v grep ; du -sh /data/mysql*/db; tail -n 10 mysql1/log/mysql1.log"

```

* * *
<a name=r>Reset</a>
-----


```
killall mysqld
sleep 3
killall -9 mysqld
sleep 3

rm -rf /data/mysql1 /data/mysql2 /data/mysql3 /data/mysql4 /data/mysql5 /data/mysql6


```