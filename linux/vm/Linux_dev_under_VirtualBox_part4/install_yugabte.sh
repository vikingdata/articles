
### Execute as root
if [ ! $USER = 'root' ]; then
   echo "Not root user, aborting"
fi

rm -rf /root/yugabyte_install
mkdir -p /root/yugabyte_install
cd /root/yugabyte_install


rm -rf /usr/local/yugabyte-2024.2.2.1
rm -f /usr/local/yugabyte-2024_server

wget https://software.yugabyte.com/releases/2024.2.2.1/yugabyte-2024.2.2.1-b6-linux-x86_64.tar.gz -O yugabyte-2024.2.2.1-b6-linux-x86_64.tar.gz

tar xvfz yugabyte-2024.2.2.1-b6-linux-x86_64.tar.gz
sudo mv yugabyte-2024.2.2.1 /usr/local
cd /usr/local
sudo ln -s yugabyte-2024.2.2.1 yugabyte-2024_server
cd /usr/local/yugabyte-2024_server
echo "PATH=/usr/local/yugabyte-2024_server/bin:\$PATH" >> ~/.bashrc
source ~/.bashrc


./bin/post_install.sh
