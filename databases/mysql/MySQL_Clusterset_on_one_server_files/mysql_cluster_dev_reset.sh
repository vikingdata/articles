

rm -rf /data/mysql1
rm -rf /data/mysql2
rm -rf /data/mysql3
rm -rf /data/mysql4
rm -rf /data/mysql5
rm -rf /data/mysql6

killall mysqld
sleep 1
killall mysqld


#  apt list --installed | grep -i "percona|mysql"

# If you didn't have the percona version but the community version
# apt-get remove --purge libdbd-mysql-perl libmysqlclient21 mysql-apt-config mysql-client-8.0 mysql-client-core-8.0 mysql-common  mysql-server-8.0 mysql-server-core-8.0 mysql-server


