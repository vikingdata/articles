

# Login as root or sudo
sudo bash

cat /shared/virtual_host_aliases.sh

echo "" >> ~/.bashrc
echo "source /shared/virtual_host_aliases.sh " >> ~/.bashrc
source /shared/virtual_host_aliases.sh
