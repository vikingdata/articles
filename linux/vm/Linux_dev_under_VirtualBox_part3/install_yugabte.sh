


sudo apt install -y python-is-python3 jq

### Execute as root
if [ ! $USER = 'root' ]; then
   echo "Not root user, aborting"
fi

killall -q yugabyted
killall -q yb-master
killall -q yb-tserver
killall -q yugabyted-ui
killall -q postgres
sleep 2
killall -q -9 yugabyted
killall -q -9 yb-master
killall -q -9 yb-tserver
killall -q -9 yugabyted-ui
killall -q -9 postgres


if [ ! -d "/root/yugabyte_install" ]; then
    FILENAME="yugabyte-2024.2.2.1-b6-linux-x86_64.tar.gz"
    let size_desired=1024*1024*390
    file_size=`stat -c %s $FILENAME`

    if [ ! "$file_size" -ge "$size_desired" ]; then
	echo "$FILE is not $size_desired bytes, removing."
	rm -rf /root/yugabyte_install
    fi

    mkdir -p /root/yugabyte_install
fi    

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


