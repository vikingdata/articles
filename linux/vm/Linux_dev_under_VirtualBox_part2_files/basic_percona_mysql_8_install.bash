
# TODO
# Put versions in for software. 
  # Execute as root
  # 'sudo root' or 'su -l' root first. 

cd /database/install_scripts

mkdir percona
cd percona

apt install curl -y
curl -O https://repo.percona.com/apt/percona-release_latest.generic_all.deb
apt -y install gnupg2 lsb-release ./percona-release_latest.generic_all.deb
apt update
percona-release setup ps80

apt-get update

   # install router and shell
wget https://dev.mysql.com/get/Downloads/MySQL-Router/mysql-router-community_8.0.40-1ubuntu22.04_amd64.deb
dpkg -i mysql-router-community_8.0.40-1ubuntu22.04_amd64.deb

wget https://dev.mysql.com/get/Downloads/MySQL-Shell/mysql-shell_8.0.40-1ubuntu22.04_amd64.deb
dpkg -i mysql-shell_8.0.40-1ubuntu22.04_amd64.deb


  # Install a specific version, it must be 8.0.36 or earlier, because
  # the router software is 8.0.37

  # It may ask for password, make the password "root" or your own password.
  # I suggest a better password than "root"
# This version may change and cause the script to abort.
  ### TODO Put check in here is the version installed. 
sudo apt -y install percona-server-server=8.0.40-31-1.jammy

mysql -u root -proot -e "CREATE FUNCTION fnv1a_64 RETURNS INTEGER SONAME 'libfnv1a_udf.so'"
mysql -u root -proot -e "CREATE FUNCTION fnv_64 RETURNS INTEGER SONAME 'libfnv_udf.so'"
mysql -u root -proot -e "CREATE FUNCTION murmur_hash RETURNS INTEGER SONAME 'libmurmur_udf.so'"

mysql -u root -proot -e "create user grafana@localhost IDENTIFIED BY 'grafana'"
mysql -u root -proot -e "grant select, REPLICATION SLAVE on *.* to grafana@'%';"
mysql -u root -proot -e "create user grafana@'%' IDENTIFIED BY 'grafana'"
mysql -u root -proot -e "grant select, REPLICATION SLAVE on *.* to grafana@'%';"

mysql -u root -proot -e "create user telegraf@localhost IDENTIFIED BY 'telegraf'"
mysql -u root -proot -e "GRANT SELECT ON performance_schema.* TO 'telegraf'@'localhost';"
mysql -u root -proot -e "GRANT PROCESS ON *.* TO 'telegraf'@'localhost';"
mysql -u root -proot -e "GRANT REPLICATION CLIENT ON *.* TO 'telegraf'@'localhost';"

mysql -u root -proot -e "create user root@'%' IDENTIFIED BY 'root'"
mysql -u root -proot -e "GRANT all privileges on *.* to  'root'@'%';"



cd
mkdir -p mysql
cd mysql
wget https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main/linux/vm/Linux_dev_under_VirtualBox_part2_files/Dev_basic_my_cnf.md
 sed -e 's/__NO__/1/g' Dev_basic_my_cnf.md > /etc/mysql/conf.d/Dev_basic_my_cnf.md

# I am not sure why, but changes to buffer pool is not read of configuration files
# other than my.cnf. You need to define buffer pool in the main file
# and then it will override it with the one in conf.d -- weird. 

echo "
[mysqld]
innodb_buffer_pool_size=5242881
" >> /etc/mysql/my.cnf

service mysql restart
mysql -u root -proot -e "SELECT * FROM performance_schema.global_variables where VARIABLE_NAME in ('server_id', 'innodb_buffer_pool_size')" 


