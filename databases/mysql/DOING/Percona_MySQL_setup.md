
sudo apt install -y curl
curl -O https://repo.percona.com/apt/percona-release_latest.generic_all.deb
sudo apt install -y gnupg2 lsb-release ./percona-release_latest.generic_all.deb
sudo apt update

apt list --upgradable

sudo percona-release setup ps80
sudo percona-release enable ps-80 release

apt list --upgradable
sudo apt update

# Enter your password, I just used "root" twice because 
# you have to log into Windows first/
sudo apt install -y percona-server-server

percona-release setup pdps8.0

        mysql -u root -proot -e "CREATE FUNCTION fnv1a_64 RETURNS INTEGER SONAME 'libfnv1a_udf.so'"
        mysql -u root -proot -e "CREATE FUNCTION fnv_64 RETURNS INTEGER SONAME 'libfnv_udf.so'"
        mysql -u root -p3proot -e "CREATE FUNCTION murmur_hash RETURNS INTEGER SONAME 'libmurmur_udf.so'"


# download nd install percona tools

# Download and install percona xtrbackup

# Download MySQL community Cluster files. 

# Download Python MySQL connector 
