 
---
title : MySQL Clusterset on one server
author : Mark Nielsen  
copyright : May 2024
---



==============================

_**by Mark Nielsen
Original Copyright May 2024
**_

NOTE: Has been tested, but need to add router and ReplicaSet, and test again

1. [Links](#links)
2. [Notes](#n) x
3. [Install Percona and mysqlsh](#i)
4. [Setup directories and files for MySQL ClusterSet](#s)
5. [Start all instances](#start)
6. [Setup Clusterset](#c)
6. [Reset](#r)
7. [TODO](#todo)

* * *
<a name=Links></a>Links
-----
* https://dev.mysql.com/doc/dev/mysqlsh-api-javascript/8.0/classmysqlsh_1_1dba_1_1_dba.html
* https://dev.mysql.com/doc/dev/mysqlsh-api-javascript/8.0/classmysqlsh_1_1dba_1_1_cluster.html
* https://dev.mysql.com/doc/dev/mysqlsh-api-javascript/8.0/classmysqlsh_1_1dba_1_1_cluster_set.html

* * *
<a name=n></a>Notes
-----
When cconnecting to MySQL AFTER installation. 

| Login | notes| matching account for root |
|---- | --- | --- |
| -p 4001 -h localhost | need to specify socket file or it fails | localhost |
| -p 4001 -h 127.0.0.1 | Connects to  127.0.01 but uses localhost password | localhost |
| -S socket | specfy -S /data/mysql1/mysqls.socket" or other | localhost |
| -p 4001 -h <your external ip> | | % |


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

   # install router and shell

wget https://dev.mysql.com/get/Downloads/MySQL-Router/mysql-router_8.0.37-1ubuntu22.04_amd64.deb
wget https://dev.mysql.com/get/Downloads/MySQL-Router/mysql-router-community_8.0.37-1ubuntu22.04_amd64.deb
dpkg -i mysql-router-community_8.0.37-1ubuntu22.04_amd64.deb mysql-router_8.0.37-1ubuntu2

wget https://dev.mysql.com/get/Downloads/MySQL-Shell/mysql-shell_8.0.37-1ubuntu22.04_amd64.deb
wget https://dev.mysql.com/get/Downloads/MySQL-Shell/mysql-shell-8.0.37-linux-glibc2.28-x86-64bit.tar.gz
dpkg -i mysql-shell_8.0.37-1ubuntu22.04_amd64.deb mysql-shell-8.0.37-linux-glibc2.28-x86-64bit.tar.gz
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
echo "CREATE USER if not exists '$SUDO_USER'@'localhost' IDENTIFIED WITH auth_socket;" > $root_file
echo "grant all privileges on *.* to '$SUDO_USER'@'localhost';"          >>  $root_file

   # create root @ % with all privs. 
echo "CREATE USER if not exists 'root'@'%' IDENTIFIED by 'root';" >> $root_file
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
echo "CREATE USER if not exists '$SUDO_USER'@'%' IDENTIFIED by '$SUDO_USER';"          >>  $root_file
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
<a name=start>Start all instances</a>
-----

```

cd /data

killall mysqld
sleep 2

sleeptime=2
echo "init mysql1"
sudo -u mysql /usr/sbin/mysqld --defaults-file=/data/mysql1/mysqld1.cnf_initialize --defaults-group-suffix= --initialize-insecure &
sleep $sleeptime

echo "init mysql2"
sudo -u mysql /usr/sbin/mysqld --defaults-file=/data/mysql2/mysqld2.cnf_initialize --defaults-group-suffix= --initialize-insecure &
sleep $sleeptime

echo "init mysql3"
sudo -u mysql /usr/sbin/mysqld --defaults-file=/data/mysql3/mysqld3.cnf_initialize --defaults-group-suffix= --initialize-insecure &
sleep $sleeptime

echo "init mysql4"
sudo -u mysql /usr/sbin/mysqld --defaults-file=/data/mysql4/mysqld4.cnf_initialize --defaults-group-suffix= --initialize-insecure &
sleep $sleeptime

echo "init mysql5"
sudo -u mysql /usr/sbin/mysqld --defaults-file=/data/mysql5/mysqld5.cnf_initialize --defaults-group-suffix= --initialize-insecure &
sleep $sleeptime

echo "init mysql6"
sudo -u mysql /usr/sbin/mysqld --defaults-file=/data/mysql6/mysqld6.cnf_initialize --defaults-group-suffix= --initialize-insecure &

count_mysql=1
while [ $count_mysql -gt 0 ]; do
  echo "mysql processes -- this can take a long time, depending on speed of computer"
  ps auxw | grep /usr/sbin/mysqld | egrep -v   'grep|sudo' | wc -l
  count_mysql=`ps auxw | grep /usr/sbin/mysqld | egrep -v   'grep|sudo' | wc -l`  
  ps auxw | grep /usr/sbin/mysqld | egrep -v   'grep|sudo' 
  du -sh /data/mysql*/db
  sleep 1
  clear
done

  # In other windows you can watch the processes
# watch -n 1 "clear;ps auxw | grep /usr/sbin/mysqld | egrep -v   'grep|sudo' ; echo ""; du -sh /data/mysql*/db"


  ### restart services
systemctl restart mysqld1
systemctl restart mysqld2
systemctl restart mysqld3
systemctl restart mysqld4
systemctl restart mysqld5
systemctl restart mysqld6
sleep 10

  # In other windows you can watch the processes
# watch -n 1 "clear;ps auxw | grep /usr/sbin/mysqld | egrep -v   'grep|sudo' ; echo ""; du -sh /data/mysql*/db"


   # test if you can connect

for i in 1 2 3 4 5 6; do
  mysql -N -u root  -e "select @@hostname, now(), @@port" -S /data/mysql$i/mysqld$i.sock | cat
done

  # Load The account information
echo "loading accounts"
for i in 1 2 3 4 5 6; do
   mysql -u root  -e "source $root_file" -S /data/mysql$i/mysqld$i.sock
done

echo "testing root localhost"
my_ip=`ifconfig  | grep "inet "| grep -v 127 | sed -e "s/  */ /g" | cut -d ' ' -f3`
echo  "my external ip is $my_ip"
# If this is the wrong, change it.
# my_ip="<MY_IP>"  

echo "checking mysql root on socket"
for i in 1 2 3 4 5 6; do
mysql -sN -u root -proot  -S /data/mysql$i/mysqld$i.sock -e "select user(),current_user(), @@hostname, @@port" 2> /dev/null
done

sleep 2
echo ""
echo "checking mysql root on 127.0.0.1"
for i in 1 2 3 4 5 6; do
mysql -sN -u root -proot  -P 400$i -h 127.0.0.1 -e "select user(),current_user(),@@hostname, @@port" 2> /dev/null
done

sleep 2
echo ""
echo "checking mysql root on $my_ip"
for i in 1 2 3 4 5 6; do
mysql -sN -u root -proot  -P 400$i -h $my_ip -e "select user(),current_user(),@@hostname, @@port" 2> /dev/null
done

echo "echo 'stopping mysql6 '"       > /data/mysql_init/Start_mysql_servers.sh
echo "service mysqld6 stop"       >> /data/mysql_init/Start_mysql_servers.sh
for i in 5 4 3 2 1; do
  echo "echo 'stopping mysql$i'"     >> /data/mysql_init/Start_mysql_servers.sh
  echo "service mysqld$i stop"    >> /data/mysql_init/Start_mysql_servers.sh
done
echo "echo 'starting mysql6 '"       >> /data/mysql_init/Start_mysql_servers.sh
echo "service mysqld6 start"       >> /data/mysql_init/Start_mysql_servers.sh
for i in 1 2 3 4 5; do
  echo "echo 'starting mysql$i'"     >> /data/mysql_init/Start_mysql_servers.sh
  echo "service mysqld$i start"    >> /data/mysql_init/Start_mysql_servers.sh
done

echo "echo 'dba.rebootClusterFromCompleteOutage()' | mysqlsh -u root -proot -h 127.0.0.1 -P 4011 " >> /data/mysql_init/Start_mysql_servers.sh

chmod 755 /data/mysql_init/Start_mysql_servers.sh

```

* * *
<a name=c>Setup CluserSet</a>
-----

Do this in order. Open two login sessions and root. Call them Window1 and Window2. HINT: You could use screen or tmux. 
* On Window1:
    * mysqlsh -u root -proot -h $my_ip -P 4011
    * Execute: c1 = dba.createCluster('primary', {localAddress:'127.0.0.1:4001'});
    * Execute : c1.addInstance('localhost:4002', {recoveryMethod:'clone'});
    * When you see the message "Waiting for server restart"
        * Switch to Window2 and execute
            * service mysqld2 restart
            * switch back to Window1
    * On Window1 you should see two hosts from
        * execute: c1.status()
* On Window1:
    * Execute : c1.addInstance('localhost:4003', {recoveryMethod:'clone'});
    * When you see the message "Waiting for server restart"
        * Switch to Window2 and execute
            * service mysqld3 restart
            * switch back to Window1
    * On Window1 you should see three hosts from
        * execute: c1.status()
* On Window1, we create the clusterset.
    * execute: cs1 = c1.createClusterSet('cs1');


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

* * *
<a name=todo></a>To Do
-----
* Add a Replica Cluster to take full advantage of ClusterSet
* Show router example.
* Test everything from scratch one more time. 