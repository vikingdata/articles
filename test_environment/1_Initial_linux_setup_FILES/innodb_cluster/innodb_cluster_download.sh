
cd /root/
mkdir -p install/innodb_cluster
cd install/innodb_cluster

m=`systemctl list-units --type=service| grep mysql.service | cut -d '.' -f1  | sed 's/ //g'`
if [ "$m" = 'mysql' ]; then
    echo "Stopping percona mysql and disabling service."
    sudo systemctl stop mysql
    sudo systemctl disable mysql
fi

### see percona is installed and abort if not

set -e
sudo apt install -y wget curl gnupg ca-certificates lsb-release software-properties-common dirmngr vim unzip tar

#rm -rf *.deb
deb1=https://dev.mysql.com/get/Downloads/MySQL-Shell/mysql-shell_26.7.1-1ubuntu24.04_amd64.deb
deb2=https://dev.mysql.com/get/Downloads/MySQL-Shell/mysql-shell-dbgsym_26.7.1-1ubuntu24.04_amd64.deb
deb3=https://dev.mysql.com/get/Downloads/MySQL-Router/mysql-router-community_26.7.0-1ubuntu24.04_amd64.deb
deb4=https://dev.mysql.com/get/Downloads/MySQL-Router/mysql-router-community-dbgsym_26.7.0-1ubuntu24.04_amd64.deb

if [ ! -e "mysql-shell_26.7.1-1ubuntu24.04_amd64.deb" ]; then
  wget $deb1
  wget $deb2
  wget $deb3
  wget $deb4
fi

count=`apt list --installed 2>/dev/null | grep mysql-| wc -l`
echo $count

if [ $count -lt 5 ]; then
    apt -y install ./*.deb
fi




