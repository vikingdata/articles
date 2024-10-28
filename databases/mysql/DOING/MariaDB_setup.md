 
---
title : MariaDB setup
author : Mark Nielsen  
copyright : October 2024  
---


MariaDB setup
==============================

_**by Mark Nielsen
Original Copyright October 2024**_

Setting up MariaDB in Master-Slave, Galera Cluster, and ClusterSet

1. [Links](#links)
2. [Setup nodes from VirtualBox](#vb)

<a name=Links></a>Links
-----
* https://dev.mysql.com/doc/refman/8.4/en/time-zone-support.html



  # Download the MariaDB binary. It really doesn't matter which one. 
  # We will get the commands to download from apt-get. 

  # https://mariadb.com/downloads/
  # Select your version of ubuntu. 
  # Save it at c:\shared directory in windows. 

  # rsync the MariaDB download to ubuntu
  # Change your username and ip address of Linux. 
rsync -av  /cygdrive/c/shared/mariadb-11.4.3-ubuntu-jammy-amd64-debs.tar mark@192.168.0.54:
 # Untar it
tar -axvf mariadb-11.4.3-ubuntu-jammy-amd64-debs.tar

  # Run commands to set respostiory
cd mariadb-11.4.3-ubuntu-jammy-amd64-debs
sudo ./setup_repositor

  # Ignore the download and install the latest mariadb
apt-get update && apt-get install mariadb-server

  # See if the MariaDB service file is installed
ls -al /etc/systemd/system/multi-user.target.wants/mariadb.service

  # restart mariadb
service mariadb restart

  # Test MySQL connection
root@Ububuntu-base:~# mysql -u root -e "select now()" 2>/dev/null
+---------------------+
| now()               |
+---------------------+
| 2024-10-27 22:21:27 |
+---------------------+
root@Ububuntu-base:~# mariadb -u root -e "select now()"
+---------------------+
| now()               |
+---------------------+
| 2024-10-27 22:21:51 |
+---------------------+


  # Installing with pip3 gave me an error, so I will compiled it myself. 
sudo apt install gcc
sudo apt install python3-dev
sudo apt install openssl

 sudo apt install curl