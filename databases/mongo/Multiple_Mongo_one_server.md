 
---
title : Multiple MongoDB one one server
author : Mark Nielsen  
copyright : March 2024  
---


Multiple MongoDB on one server
==============================

_**by Mark Nielsen
Original Copyright April 2024
**_

Since MongoDB doesn't work easily under virutal box, I wanted to make a simple replica set
on one computer so testing and debugging can be performed. It is not meant for performance
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
* Old webpages I have on Mongo [http://www.menprojects.com/public/mongo_help.html](http://www.menprojects.com/public/mongo_help.html)

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


ln -s /var/lib/mongodb /data/mongod_old/db

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

So why did I chose port 30001? I needed 4 servers with their own uniqr ports. In another article I will shard this replica set
and I will need the default port of 27017 for mongos. In an future article, I will be exploring replica set, sharding, and other
things based on the setup here. 

```
sudo bash
cd /etc
wget -r https://raw.githubusercontent.com/vikingdata/articles/main/databases/mongo/Multiple_Mongo_one_server_files/mongod.conf



cd /data/mongo1
rm -f mongod1.conf
wget https://raw.githubusercontent.com/vikingdata/articles/main/databases/mongo/Multiple_Mongo_one_server_files/mongod1.conf
cd /data/mongo2
rm -f mongod2.conf
wget https://raw.githubusercontent.com/vikingdata/articles/main/databases/mongo/Multiple_Mongo_one_server_files/mongod2.conf
cd /data/mongo3
rm -f mongod2.conf
wget https://raw.githubusercontent.com/vikingdata/articles/main/databases/mongo/Multiple_Mongo_one_server_files/mongod3.conf
cd /data/mongo4
rm -f mongod2.conf
wget https://raw.githubusercontent.com/vikingdata/articles/main/databases/mongo/Multiple_Mongo_one_server_files/mongod4.conf

cd /lib/systemd/system/
rm -f mongod1.service mongod2.service mongod3.service mongod4.service
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
sleep 2

sudo -u mongodb mongod --config=/data/mongo1/mongod1.conf & 
sudo -u mongodb mongod --config=/data/mongo2/mongod2.conf &
sudo -u mongodb mongod --config=/data/mongo3/mongod3.conf &
sudo -u mongodb mongod --config=/data/mongo4/mongod4.conf &
sleep 2

   # See if they are still running
jobs

   # test if you can connect
mongosh -eval "db.runCommand({ serverStatus: 1}).host" --port 30001
mongosh -eval "db.runCommand({ serverStatus: 1}).host" --port 30002
mongosh -eval "db.runCommand({ serverStatus: 1}).host" --port 30003
mongosh -eval "db.runCommand({ serverStatus: 1}).host" --port 30004

   # If so, kill and restart
killall mongod
rm /data/mongo*/db/*.lock

systemctl daemon-reload

systemctl restart mongod1
systemctl restart mongod2
systemctl restart mongod3
systemctl restart mongod4

  # See if they started
ps auxw | grep mongod

  # If they don't restart
# systemctl status --full --lines=50 mongod1
# systemctl status --full --lines=50 mongod2
# systemctl status --full --lines=50 mongod3
# systemctl status --full --lines=50 mongod4

mongosh -eval "db.runCommand({ serverStatus: 1}).host" --port 30001
mongosh -eval "db.runCommand({ serverStatus: 1}).host" --port 30002
mongosh -eval "db.runCommand({ serverStatus: 1}).host" --port 30003
mongosh -eval "db.runCommand({ serverStatus: 1}).host" --port 30004

  # These next steps may be uncesssary.

  # If good, enable at restart, and then restart them
systemctl enable mongod1
systemctl enable mongod2
systemctl enable mongod3
systemctl enable mongod4

   # make sure they have stopped

systemctl stop mongod1
systemctl stop mongod2
systemctl stop mongod3
systemctl stop mongod4

ps auxw | grep mongod


   # restart them using service 
service mongod1 restart
service mongod2 restart
service mongod3 restart
service mongod4 restart

```

* * *
<a name=r>Setup replica set</a>
-----

```
sudo bash 
cd /usr/bin
   # I hate sh because it means "shell". Perl is perl, python is Python. Python should be pythonsh then. I don't like it.
ln -s mongosh mongo

mongo --port 30001 --eval "rs.initiate( { _id: 'rs1', version: 1, members: [ {_id :0, host: 'localhost:30001' } ] } )"
mongo --port 30001 --eval "rs.add('localhost:30002')"
mongo --port 30001 --eval "rs.add('localhost:30003')"
mongo --port 30001 --eval "rs.add('localhost:30004')"

   # First 3 are the main server, the 4th is hidden and cannot become primary.
   # Usually, the 4th is for backups or other. 

echo "
cfg = rs.conf();
cfg.members[0].priority = 3;
cfg.members[1].priority = 2;
cfg.members[2].priority = 1;
cfg.members[3].priority = 0;
cfg.members[3].hidden = 1;
cfg.members[3].votes = 0;

rs.reconfig(cfg);
" >> /tmp/reconfig.js

cat /tmp/reconfig.js | mongo --port 30001


# Let's print out some info
mongo --port 30001 --eval "rs.status()"
mongo --port 30001 --eval "rs.status()" | egrep "name:|state:|uptime:|health:|stateStr:"
mongo --port 30001 --eval "rs.conf()" | egrep "_id:|arbiterOnly:|hidden:|priority:|votes:"

```