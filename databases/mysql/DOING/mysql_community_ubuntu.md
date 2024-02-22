---
title : MySQL Community Ubuntu Install
author : Mark Nielsen
copyright : November 2023
---


MySQL Community Ubuntu Install
==============================

_**by Mark Nielsen
Original Copyright November 2023**_

1. [links](#links)
2. [Install](#install)
3. [Remove](#remove)

* * *
<a name=Link></a>Links
-----

* [MySQL Installation Guide](https://dev.mysql.com/doc/mysql-installation-excerpt/8.0/en/)
    * [A Quick Guide to Using the MySQL APT Repository](https://dev.mysql.com/doc/mysql-apt-repo-quick-guide/en/)
        * [ MySQL APT Repository](https://dev.mysql.com/downloads/repo/apt/)



* * *
<a name=install></a>Install
-----

* Download apt config file
    * Download file from : https://dev.mysql.com/downloads/repo/apt/
        * Install the file:
            * example: dpkg -i mysql-apt-config_0.8.28-1_all.deb
	        * choose everything
        * Or download and install
            * wget https://dev.mysql.com/get/mysql-apt-config_0.8.28-1_all.deb
            * dpkg -i mysql-apt-config_0.8.28-1_all.deb
               * choose everything
        * DO NOT DO THIS: Copy this file to /etc/apt/sources.list.d/mysql.list
	    * NOTE: the gpg package for keyrings in config dpk package is not installed. 
* Change /etc/apt/sources.list.d/mysql.list if necessary
    * For example, I change "jammy" to "focal".
        * Check the [Ubuntu Releases](https://wiki.ubuntu.com/Releases)
	
* Stop password prompt

[stackflow question]](https://stackoverflow.com/questions/7739645/install-mysql-on-ubuntu-without-a-password-prompt)

````
  # Set the password
  # This one worked for me. 
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password CHANGE_ME'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password CHANGE_ME'

  # For specific versions
sudo debconf-set-selections <<< 'mysql-server-5.6 mysql-server/root_password password your_password'
sudo debconf-set-selections <<< 'mysql-server-5.6 mysql-server/root_password_again password your_password'
sudo apt-get -y install mysql-server-5.6

  # For community version

sudo debconf-set-selections <<< 'mysql-community-server mysql-community-server/root-pass password your_password'
sudo debconf-set-selections <<< 'mysql-community-server mysql-community-server/re-root-pass password your_password'
sudo apt-get -y install mysql-community-server

  # or this, which will leave a blank password. 
export DEBIAN_FRONTEND=noninteractive

```


* Issue the commands

```
apt-get update
sudo apt-get install mysql-server
   # Provide a password. 
```


* * *
<a name=remove></a>Remove MySQL
-----

* To remove mysql but leave configuration files and database.
```

sudo apt list --installed | grep -i mysql | cut -d '/' -f1

sudo apt remove`apt list --installed | grep -i mysql | cut -d '/' -f1`


  # Which is similar to this command. 
sudo apt-get remove libmysqlclient21 \
mysql-apt-config                \
mysql-client                    \
mysql-common                    \
mysql-community-client-core     \
mysql-community-client-plugins  \  
mysql-community-client          \
mysql-community-server-core     \
mysql-community-server          \
mysql-server

sudo apt list --installed | grep -i mysql

```
* To remove files,
```
sudo apt-get purge `apt list --installed | grep -i mysql | cut -d '/' -f1`


   ### DANGEROUS: remove data files
sudo rm -rf /var/lib/mysql
   ### DANGEROUS: remove config files
sudo rm -rf /etc/mysql/

```

