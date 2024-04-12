 
---
title :  Exposing ssh or ports in WSL
author : Mark Nielsen  
copyright : April 2024  
---


Exposing ssh or ports in WSL
==============================

_**by Mark Nielsen
Original Copyright April 2024**_

The purpose is as follows:
1. You are behind a router. This means EVERY computer connecting to your router
protects all your computers from being exposed to the internet. All your
computers are given a local ip address from the router. This is meant for home use.
2. You install WSL (Linux) on a Windows box.
3. You install services in WSL and expost it ONLY to your local computers. In this case ssh and http proxy.

***

1. [Install wsl](#wsl)
2. [Install services in WSL](#s)
3. [port forward to WSL](#f)
4. [Open up port in Windows Firewall Defender](#p)


* * *
<a name=Links></a>Links
-----
* [How to open a port on the firewall](https://ec.europa.eu/digital-building-blocks/sites/display/CEKB/How+to+open+a+port+on+the+firewall)
* [Port Forwarding WSL 2 to Your LAN](https://jwstanly.com/blog/article/Port+Forwarding+WSL+2+to+Your+LAN)
* [Find your IP address in Windows](https://support.microsoft.com/en-us/windows/find-your-ip-address-in-windows-f21a9bbc-c582-55cd-35e0-73431160a1b9)

* * *
<a name=wsl>WSL</a>
-----

Info Commands is Windows Shell or Powershell

* Open Shell as administrator
    * wsl --install --distribution  Ubuntu-22.04
       * It will ask for a username and password
    * If you leave , you can reenter by :
```bash
  # This sets the default doe wsl
wsl --set-default Ubuntu-22.04
wsl

  # or if you didn't set the default
wsl --distribution Ubuntu-22.04

  # Once in Linux
  # to get to your home directory in Linux and not the Windows home directory
cd
```

Do first things:
* Put your account into sudoers file.

```text


  # sudo to root
sudo bash

  # Add yourself to sudoers file passwordless
echo "$SUDO_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

echo "I am user $USER"
apt-get update
apt-get install emacs screen -y
apt-get install nmap -y
apt-get install net-tools -y
apt-get install ssh -y
echo "I am sudo user $SUDO_USER"

  # Set the default user.
echo '[user]' >> /etc/wsl.conf
echo "default = $SUDO_USER" >> /etc/wsl.conf

  # Start ssh, tinyproxy, and command are startup
echo '[boot]' >> /etc/wsl.conf
echo 'command = /etc/start_services.sh' >> /etc/wsl.conf

  # Make start script
echo '#!/usr/bin/bash' > /etc/start_services.sh
echo "" >> /etc/start_services.sh
echo 'service ssh start' >> /etc/start_services.sh
echo 'service tinyproxy start' >> /etc/start_services.sh
chmod 755 /etc/start_services.sh

 /etc/start_services.sh
  # Have root change to the /root when it logs in
cd /root/
echo "" >> ~/.bashrc
echo "cd" >> ~/.bashrc

exit
exit
```


* * *
<a name=s>Install services in WSL</a>
-----
In WSL
```
apt-get install ssh
sudo service ssh restart

 sudo apt-get install tinyproxy
 sudo apt-get install tinyproxy

   # Change the network to yours. 
echo "Allow 192.168.0.0/16" >> /etc/tinyproxy/tinyproxy.conf

sudo service tinyproxy start

```



* * *
<a name=f>port forward to WSL</a>
-----

Open up PowerShell in windows as administrator and execute

```
netsh interface portproxy add v4tov4 listenport=22 listenaddress=0.0.0.0 connectport=8080 connectaddress=[WSL_IP]
netsh interface portproxy add v4tov4 listenport=8888 listenaddress=0.0.0.0 connectport=8888 connectaddress=[WSL_IP]

```

and the way you find out your ip address in WSL is:
* start WSL
* ifconfig | grep "inet " | grep -v 127.0.0.1


* * *
<a name=p>Open up port in Windows Firewall Defender</a>
-----

Follow the instructions in [How to open a port on the firewall](https://ec.europa.eu/digital-building-blocks/sites/display/CEKB/How+to+open+a+port+on+the+firewall)

Open up port 22 and 8080.
