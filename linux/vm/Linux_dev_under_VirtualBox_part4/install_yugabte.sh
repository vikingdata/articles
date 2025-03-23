
### Execute as root
if [ ! $USER = 'root' ]; then
   echo "Not root user, aborting"
fi

kilall yugabyted yb-master yb-tserver yugabyted-ui postgres
sleep 2
kilall -9 yugabyted yb-master yb-tserver yugabyted-ui postgres

rm -rf /root/yugabyte_install
mkdir -p /root/yugabyte_install
cd /root/yugabyte_install


rm -rf /usr/local/yugabyte-2024.2.2.1
rm -f /usr/local/yugabyte-2024_server

if [ ! -f "yugabyte-2024.2.2.1-b6-linux-x86_64.tar.gz" ]; then
  wget https://software.yugabyte.com/releases/2024.2.2.1/yugabyte-2024.2.2.1-b6-linux-x86_64.tar.gz -O yugabyte-2024.2.2.1-b6-linux-x86_64.tar.gz 
fi

tar xvfz yugabyte-2024.2.2.1-b6-linux-x86_64.tar.gz
sudo mv yugabyte-2024.2.2.1 /usr/local
cd /usr/local
sudo ln -s yugabyte-2024.2.2.1 yugabyte-2024_server
cd /usr/local/yugabyte-2024_server

echo "PATH=/usr/local/yugabyte-2024_server/bin:\$PATH" >> ~/.bashrc

source ~/.bashrc
./bin/post_install.sh

#cd /usr/local/yugabyte-2024_server
#./bin/yugabyted start --advertise_address=127.0.0.1


