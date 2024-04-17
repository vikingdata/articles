 
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
* [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/x17837.html)

* * *
<a name=i>Install Mongo</a>
-----

```

sudo bash

mkdir -p /var/lib/mongo
mkdir -p /data/mongo1/logs
mkdir -p /data/mongo1/db
mkdir -p /data/mongo2/logs
mkdir -p /data/mongo2/db
mkdir -p /data/mongo3/logs
mkdir -p /data/mongo3/db
mkdir -p /data/mongo4/logs
mkdir -p /data/mongo4/db

useradd mongodb --shell /bin/bash --create-home



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

```

* * *
<a name=c>Setup MongoDB config file</a>
-----

* * *
<a name=s>Start all instances</a>
-----


* * *
<a name=r>Setup replica set</a>
-----
