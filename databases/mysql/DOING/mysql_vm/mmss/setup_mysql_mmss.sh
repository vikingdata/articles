#!/usr/bin/bash

# Run this under cygwin for Windows

source /cygdrive/c/vm/shared/alias_ssh_systems
mkdir -p temp
  # change this to your user
sudouser='mark'

uuid=`uuidgen`

for m in mysql1 mysql2 mysql3 mysql4; do
  temp=$m"_name"
  eval name=\$$temp
  host="$name"".myguest.virtualbox.org"
  temp=$m"_ip"
  eval ip=\$$temp

  id=`echo $ip | cut -d '.' -f4`
  
#  echo $name $ip
  
  if [ "$name" == "" ]; then continue; fi

  echo "processing $name $ip"

  file="temp/$name"".my.cnf"
  sed -e "s/__ID__/$id/" mysqld_mmss_my.cnf | sed -s "s/__HOST__/$host/" | sed -e "s/__UUID__/$uuid/"> $file

  echo "Stopping mysql via ssh with root"
  ssh $ip -l root "service mysql stop; sleep 2"

  echo "copying my.cnf "
  scp $file root@$ip:/etc/my.cnf

  echo "Stopping mysql via ssh with root"
  ssh $ip -l root "service mysql start; sleep 2"
  
  ssh $ip -l root "systemctl set-environment MYSQLD_OPTS='--skip-grant-tables'; systemctl restart mysql "
  ssh $ip -l root "mysql -e \"update mysql.user set plugin='auth_socket', authentication_string='' where user='root'; flush privileges\"";
  ssh $ip -l root "systemctl set-environment MYSQLD_OPTS=''; systemctl restart mysql "

  ssh $ip -l root "mysql -e \"CREATE USER 'root'@'%'  IDENTIFIED by 'root' ; grant all privileges on *.* to 'root'@'%' with grant option; flush privileges\""

  mysql -u root -proot -h $ip -e "select now()"
  mysql -u root -proot -h $ip -e "source accounts_mmss.sql"
  
done
