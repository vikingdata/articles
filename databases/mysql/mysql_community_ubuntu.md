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

apt list --installed | grep -i mysql | cut -d '/' -f1

apt remove`apt list --installed | grep -i mysql | cut -d '/' -f1`


  # Which is similar to this command. 
apt-get remove libmysqlclient21 \
mysql-apt-config                \
mysql-client                    \
mysql-common                    \
mysql-community-client-core     \
mysql-community-client-plugins  \  
mysql-community-client          \
mysql-community-server-core     \
mysql-community-server          \
mysql-server

apt list --installed | grep -i mysql

```
* To remove files,
```
apt-get purge `apt list --installed | grep -i mysql | cut -d '/' -f1`

```

