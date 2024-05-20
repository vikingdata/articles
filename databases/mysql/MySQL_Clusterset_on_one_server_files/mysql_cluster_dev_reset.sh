
killall mysqld
sleep 10
killall mysqld

mkdir -p /data
cd /data

for i in 1 2 4 5 6; do

      rm -rvf /data/mysql$i
      mkdir -vp /data/mysql$i/log
    
      cd /data/mysql$i/log
      rm -rvf redo undo db binlog
      mkdir -vp redo undo db binlog
      cd ..
      rm -rvf db
      mkdir -vp db

      cd /data
done
chown -R mysql /data/mysql*

port=4000
for i in 1 2 3 4 5 6; do
  let port=$port+1
  mkdir -p /data/mysql$i
  cd /data/mysql$i
  wget -O mysqld$i.cnf_initialize https://raw.githubusercontent.com/vikingdata/articles/main/databases/mysql/MySQL_Clusterset_on_one_server_files/mysql.cnf_initialize
  wget -O mysqld$i.cnf https://raw.githubusercontent.com/vikingdata/articles/main/databases/mysql/MySQL_Clusterset_on_one_server_files/mysql.cnf

  sed -i "s/__NO__/$i/g"       mysqld$i.cnf_initialize
  sed -i "s/__PORT__/$port/g"  mysqld$i.cnf_initialize

  sed -i "s/__NO__/$i/g"       mysqld$i.cnf
  sed -i "s/__PORT__/$port/g"  mysqld$i.cnf

done

for i in 1 2 4 5 6; do
   echo "init mysql$i node, this may take a while"
   sudo -u mysql /usr/sbin/mysqld --defaults-file=/data/mysql$i/mysqld$i.cnf_initialize --defaults-group-suffix= --initialize-insecure
done

cd /lib/systemd/system/

for i in 1 2 3 4 5 6; do
  rm -f mysqld$i.service
  wget -O mysqld$i.service https://raw.githubusercontent.com/vikingdata/articles/main/databases/mysql/MySQL_Clusterset_on_one_server_files/mysql.service
  sed -i "s/__NO__/$i/g"  mysqld$i.service
done

systemctl daemon-reload


killall mysqld
sleep 1
killall mysqld


#  apt list --installed | egrep -i "percona|mysql"

apt-get remove --purge percona-release percona-server-client percona-server-common percona-server-server


# If you didn't have the percona version but the community version
# apt-get remove --purge libdbd-mysql-perl libmysqlclient21 mysql-apt-config mysql-client-8.0 mysql-client-core-8.0 mysql-common  mysql-server-8.0 mysql-server-core-8.0 mysql-server


