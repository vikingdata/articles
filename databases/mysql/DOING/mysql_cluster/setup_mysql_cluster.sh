#!/usr/bin/bash

# Run this under cygwin for Windows

source /cygdrive/c/vm/shared/alias_ssh_systems
mkdir -p temp
  # change this to your user
sudouser='mark'

uuid=`uuidgen`

for m in mysql1 mysql2 mysql3; do
  temp=$m"_name"
  eval name=\$$temp
  host="$name"".myguest.virtualbox.org"
  temp=$m"_ip"
  eval ip=\$$temp

  id=`echo $ip | cut -d '.' -f4`
  
#  echo $name $ip
  
  if [ "$name" == "" ]; then continue; fi

  echo "processing $name $ip"
  file_initialize="temp/$name""_initialize.my.cnf"
  sed -e "s/__ID__/$id/" mysqld_cluster_my_initialize.cnf | sed -s "s/__HOST__/$host/" > $file_initialize

  file="temp/$name"".my.cnf"
  sed -e "s/__ID__/$id/" mysqld_cluster_my.cnf | sed -s "s/__HOST__/$host/" | sed -e "s/__UUID__/$uuid/"> $file

  
  echo "Stopping mysql via ssh with root"
  ssh $ip -l root "service mysql stop; sleep 5"  

  echo "copying my.cnf to initialize"
  scp $file_initialize root@$ip:/etc/my.cnf

  echo "Removing mysql base directory and recreating"
  ssh $ip -l root "rm -rf /var/lib/mysql; mkdir -p /var/lib/mysql; chown mysql.mysql /var/lib/mysql"

  echo "Intialzing mysql"
  ssh $ip -l root "/usr/sbin/mysqld --initialize --user=mysql "
done

echo ""
   ## Setup single node cluster
ip=$mysql1_ip
echo "Making mysql1 a single node cluster"

ssh $ip -l root "systemctl set-environment MYSQLD_OPTS='--skip-grant-tables'; systemctl restart mysql "
ssh $ip -l root "mysql -e \"update mysql.user set plugin='auth_socket', authentication_string='' where user='root'; flush privileges\"";
ssh $ip -l root "systemctl set-environment MYSQLD_OPTS=''; systemctl restart mysql "

ssh $ip -l root "mysql -e \"CREATE USER 'root'@'%'  IDENTIFIED by 'root';\""
ssh $ip -l root "mysql -e \"grant all privileges on *.* to 'root'@'%';\""

scp root_permissions root@$ip:/tmp/r.perm
ssh $ip -l root "mysql -e 'source /tmp/r.perm'"


mysql -u root -proot -h $ip "select now()"


echo "restaring mysql with final my.cnf"
1file="temp/mysql1.my.cnf"
scp $file root@$ip:/etc/my.cnf
ssh $ip -l root "systemctl restart mysql "

echo "Setting up cluster"
ssh $ip -l root "mysql -e 'SET GLOBAL group_replication_bootstrap_group=ON;'"

#ssh $ip -l root "mysql -e 'SET GLOBAL group_replication_bootstrap_group=ON;'"
#START GROUP_REPLICATION;
#SET GLOBAL group_replication_bootstrap_group=OFF;
