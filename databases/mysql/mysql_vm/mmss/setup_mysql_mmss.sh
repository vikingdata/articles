#!/usr/bin/bash

# Run this under cygwin for Windows

cygwin_count=`echo $PATH | grep cygdrive | wc -l`
if [ $cygwin_count -gt 0 ]; then
    source /cygdrive/c/vm/shared/alias_ssh_systems
fi

wsl_count=`set | grep -i ^wsl | wc -l`
if [ $wsl_count -gt 0 ]; then
    source /mnt/c/vm/shared/alias_ssh_systems
fi

uuid=`uuidgen`
    
mkdir -p temp
  # change this to your user
sudouser='mark'

for m in mysql1 mysql2 mysql3 mysql4; do
  temp=$m"_name"
  eval name=\$$temp
  host="$name"".myguest.virtualbox.org"
  temp=$m"_ip"
  eval ip=\$$temp

  id=`echo $ip | cut -d '.' -f4`
  
#  echo $name $ip
  
  if [ "$name" == "" ]; then continue; fi

  echo ""
  echo "processing $name $ip"

  file="temp/$name"".my.cnf"
  sed -e "s/__ID__/$id/" mysqld_mmss_my.cnf | sed -s "s/__HOST__/$host/" | sed -e "s/__UUID__/$uuid/" > $file

  echo "Stopping mysql via ssh with root"
  ssh -o StrictHostKeyChecking=accept-new $ip -l root "service mysql stop; sleep 2"

  echo "removing auto.cnf, which has uuid"  
  ssh $ip -l root "rm -f /var/lib/mysql/auto.cnf"
  
  echo "copying my.cnf "
  scp $file root@$ip:/etc/my.cnf

  echo "Stopping mysql via ssh with root"
  ssh $ip -l root "service mysql start; sleep 2"
  
  ssh $ip -l root "systemctl set-environment MYSQLD_OPTS='--skip-grant-tables'; systemctl restart mysql "
  ssh $ip -l root "mysql -e \"update mysql.user set plugin='auth_socket', authentication_string='' where user='root' and host='localhost'; flush privileges\"";
  ssh $ip -l root "systemctl set-environment MYSQLD_OPTS=''; systemctl restart mysql "

  ssh $ip -l root "mysql -e \"CREATE USER 'root'@'%'  IDENTIFIED by 'root' ; grant all privileges on *.* to 'root'@'%' with grant option; flush privileges\""

  mysql -u root -proot -h $ip -e "select now(), @@hostname"
  mysql -u root -proot -h $ip -e "source accounts_mmss.sql"
  mysql -u root -proot -h $ip -e "select user,host,plugin from mysql.user"

done

