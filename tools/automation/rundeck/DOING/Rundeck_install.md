--------
title: Rundeck : Install 

--------

# Rundeck: Installation

*by Mark Nielsen*  
*Copyright April 2024*

---

1. [Links](#links)
2. [Install Rundeck](#install)
3. [Make first project](#p)


* * *

<a name=links></a>Links
-----

General
* [Rundeck Install Ubuntu](https://docs.rundeck.com/docs/administration/install/linux-deb.html#installing-rundeck)


---
* * *
<a name=install></a>Install Rundeck Ubuntu (under WSL for Windows)
-----


```
sudo bash

mkdir rundeck_install
cd rundeck_install

apt-get install openjdk-11-jre-headless

   # community
curl https://raw.githubusercontent.com/rundeck/packaging/main/scripts/deb-setup.sh 2> /dev/null | sudo bash -s rundeck

curl -L https://packages.rundeck.com/pagerduty/rundeck/gpgkey | sudo apt-key add -

echo "
deb https://packages.rundeck.com/pagerduty/rundeck/any/ any main
deb-src https://packages.rundeck.com/pagerduty/rundeck/any/ any main
" > /etc/apt/sources.list.d/rundeck.list

dpkg -i rundeck_5.2.0-20240410-1_all.deb

  # download rundecl from https://www.rundeck.com/downloads
  # register if you likke, you can add yourself to a mailing list
  # Copy from WSL
  # cp /mnt/c/Users/marka/Downloads/rundeck_5.2.0.20240410-1_all.deb .
  #   Change your username if WSL.

  # some get rundeck_5.2.0.20240410-1_all.deb into our current directory

  # Insall rundeck
dpkg -i rundeck_5.2.0.20240410-1_all.deb


systemctl daemon-reload
service rundeckd start

sleep 3
tail -n 10  /var/log/rundeck/service.log

  # If the following has about 250, it is valid. That webpage prints out 250 lines.
wget -O -  http://localhost:4440/user/login | wc -l
 
```

----
* * *
<a name=r></a>Reset Admin password
-----

```
   # change you password
   * Make it alpha numeric, no spaces. You can use underscore
pwd="my_password"
sed -i "s/^admin:admin/admin:$pwd/" /etc/rundeck/realm.properties

service rundeckd start


```

----
* * *
<a name=pl></a>First project
-----

* First login as user admin and password admin
* Change your password.
