 
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
2. [Install MySQL Cluster](#i)
3. [Setup MySQL config files](#c)
4. [Start all instances](#s)
5. [Setup replica set](#r)
6. Reset

* * *
<a name=Links></a>Links
-----

* * *
<a name=i>Install ClusterSet on Ubuntu</a>
-----

fg
```

sudo bash

apt install curl -y
curl -O https://repo.percona.com/apt/percona-release_latest.generic_all.deb
apt install gnupg2 lsb-release ./percona-release_latest.generic_all.deb -y
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

apt-get update

#-----------------------------------------

  # It will may ask for password for percona mysql
  # If it does, leave passwored blank and it will allow
  # root authetication by sudo to root only.
sudo apt install percona-server-server -y
  # If it asks for a password, just press enter.

  # Optional install a specific version
  # We must have 8.0.36 or earlier, because we download oracle's shell and router at 8.0.36
# apt list -a percona-server-server
# apt install  percona-server-server=8.0.35-27-1.jammy

sudo apt install percona-server-server -y

for i in 1 2 3 4 5 6; do
  mkdir -p /data/mysql$i/db
  mkdir -p /data/mysql$i/innodb

  mkdir -p /data/mysql$i/binlog
  mkdir -p /data/mysql$i/relay

  mkdir -p /data/mysql$i/undo
  mkdir -p /data/mysql$i/logs
done

chown -R mysql.mysql /data/mysql*

echo "this is a dev server" > /data/THIS_IS_A_DEV_SERVER

  # Create a script to make local and remote account with admin privs.

export root_file=/data/mysql_init/root_account.sql
echo "CREATE USER '$SUDO_USER'@'localhost' IDENTIFIED WITH auth_socket;" > $root_file
echo "grant all privileges on *.* to '$SUDO_USER'@'localhost';"          >>  $root_file

echo "CREATE USER '$SUDO_USER'@'%' IDENTIFIED by '$SUDO_USER';"          >>  $root_file
echo "grant all privileges on *.* to '$SUDO_USER'@'%';"                  >>  $root_file
echo "select user,host,plugin,authentication_string from mysql.user where user='$SUDO_USER';" >>  $root_file

```

* * *
<a name=c>Setup MySQL config file</a>
-----

```
sudo bash

port=4000
for i in 1 2 3 4 5 6; do
  let port=$port+1
  cd /data/mysql$i
  wget -O mysql$i.cnf_initialize https://raw.githubusercontent.com/vikingdata/articles/main/databases/mysql/MySQL_Clusterset_on_one_server_files/mysql.cnf_initialize
  wget -O mysql$i.cnf https://raw.githubusercontent.com/vikingdata/articles/main/databases/mysql/MySQL_Clusterset_on_one_server_files/mysql.cnf

  sed -i "s/__NO__/$i/g"       mysql$i.cnf_initialize
  sed -i "s/__PORT__/$port/g"  mysql$i.cnf_initialize

  sed -i "s/__NO__/$i/g"       mysql$i.cnf
  sed -i "s/__PORT__/$port/g"  mysql$i.cnf

done

cd /lib/systemd/system/

for i in 1 2 3 4 5 6; do
  rm -f mysqld$i.service
  wget -O mysql$i.service https://raw.githubusercontent.com/vikingdata/articles/main/databases/mysql/MySQL_Clusterset_on_one_server_files/mysql.service
  sed -i "s/__NO__/$i/g"  mysqld$i.service
done


```


* * *
<a name=s>Start all instances</a>
-----

```
killall mysqld
sleep 2

sudo -u mysqld mysqld --config=/data/mysql1/mysqld1.conf & 
sudo -u mysqld mysqld --config=/data/mysql2/mysqld2.conf &
sudo -u mysqld mysqld --config=/data/mysql3/mysqld3.conf &
sudo -u mysqld mysqld --config=/data/mysql4/mysqld4.conf &
sudo -u mysqld mysqld --config=/data/mysql5/mysqld5.conf &

sleep 2

   # See if they are still running
jobs

mysql -u root -p root -P 40001 "select @@hostname, now()"

   # test if you can connect
mysql -u root -p root -P 40001 "select @@hostname, now()"
mysql -u root -p root -P 40002 "select @@hostname, now()"
mysql -u root -p root -P 40003 "select @@hostname, now()"
mysql -u root -p root -P 40004 "select @@hostname, now()"
mysql -u root -p root -P 40005 "select @@hostname, now()"
mysql -u root -p root -P 40006 "select @@hostname, now()"


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



```

* * *
<a name=r>Reset</a>
-----
