 
---
title : Multiple MongoDB one one server
author : Mark Nielsen  
copyright : March 2024  
---


Multiple MongoDB on one server
==============================

_**by Mark Nielsen
Original Copyright March April
**_

Since MongoDB doesn't work easily under virutal box, I wanted to make a simple replica set
on one computer so testing and debugging and be performed. It is not meant for performance
testing. 

1. [Links](#links)
2. [Install Mongo](#i)
3. [Setup MongoDB config files](#c)
4. [Start all instances](#s)
5. [Setup replica set](#r)


* * *
<a name=Links></a>Links
-----
* [MongoBD Ubuntu](https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/)
* Old webpages I have on Mongo (http://www.menprojects.com/public/mongo_help.html)htttp://www.menprojects.com/public/mongo_help.html]

* * *
<a name=i>Install Mongo</a>
-----

```

sudo bash

mkdir -p /var/lib/mongo
mkdir -p /data
ln -s /var/lib/mongo /data/db
mkdir -p /data/mongo1/logs
mkdir -p /data/mongo1/db
mkdir -p /data/mongo2/logs
mkdir -p /data/mongo2/db
mkdir -p /data/mongo3/logs
mkdir -p /data/mongo3/db
mkdir -p /data/mongo4/logs
mkdir -p /data/mongo4/db
mkdir -p /data/mongo_old/db
mkdir -p /data/mongo_old/logs

useradd mongodb --shell /bin/bash --create-home
chown -R mongodb.mongodb /data /var/lib/mongo


mkdir /data
ln -s /var/lib/mongodb /data/db
   #Install Mongodb and other programs

sudo apt-get install gnupg curl
rm -f /usr/share/keyrings/mongodb-server-7.0.gpg 
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
   --dearmor

   # For jammy, check /etc/lsb-release
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

   # If focal
# echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

   # update ubuntu packages
sudo apt-get update

   # Get the latest
apt-get install -y mongodb-org


   # start mongo
systemctl start mongod

   # Test if it works
mongosh -eval "db.runCommand({ serverStatus: 1}).host"

   #enable it at boot as a service
systemctl enable mongod

   # restart it and test again as a service
service mongod restart
mongosh -eval "db.runCommand({ serverStatus: 1}).host"

```

* * *
<a name=c>Setup MongoDB config file</a>
-----

```
sudo bash
cd /data/mongo1
wget https://raw.githubusercontent.com/vikingdata/articles/main/databases/mongo/Multiple_Mongo_one_server_files/mongod1.conf
cd /data/mongo2
wget https://raw.githubusercontent.com/vikingdata/articles/main/databases/mongo/Multiple_Mongo_one_server_files/mongod2.conf
cd /data/mongo3
wget https://raw.githubusercontent.com/vikingdata/articles/main/databases/mongo/Multiple_Mongo_one_server_files/mongod3.conf
cd /data/mongo4
wget https://raw.githubusercontent.com/vikingdata/articles/main/databases/mongo/Multiple_Mongo_one_server_files/mongod4.conf

cd /lib/systemd/system/

wget https://raw.githubusercontent.com/vikingdata/articles/main/databases/mongo/Multiple_Mongo_one_server_files/mongod1.service
wget https://raw.githubusercontent.com/vikingdata/articles/main/databases/mongo/Multiple_Mongo_one_server_files/mongod2.service
wget https://raw.githubusercontent.com/vikingdata/articles/main/databases/mongo/Multiple_Mongo_one_server_files/mongod3.service
wget https://raw.githubusercontent.com/vikingdata/articles/main/databases/mongo/Multiple_Mongo_one_server_files/mongod4.service
```



* * *
<a name=s>Start all instances</a>
-----

```
killall mongod
sleep(2)

sudo -u mongodb mongod --config=/etc/mongo1.conf --port 3001 

   # start mongo1
systemctl start mongod1
mongosh -eval "db.runCommand({ serverStatus: 1}).host"
systemctl enable mongod1
service mongod1 restart
mongosh -eval "db.runCommand({ serverStatus: 1}).host"





```

* * *
<a name=r>Setup replica set</a>
-----
