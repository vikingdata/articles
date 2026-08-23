
rm -rf ~/install/postgresql
mkdir ~/install/postgresql
cd ~/install/postgresql

wget -O create_instance.sh
wget -O setup_replication.sh
wget -O  requirements.conf

chmod 700 create_instance.sh setup_replication.sh
chmod 600 requirements.conf

sudo ./create_instance.sh publisher 5432
sudo ./create_instance.sh subscriber 5433
sudo ./setup_replication.sh
