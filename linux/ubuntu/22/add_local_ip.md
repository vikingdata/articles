
---
title : Linux: Add local ip address
author : Mark Nielsen  
copyright : Oct 2023  
---


Add local ip address
==============================

_**by Mark Nielsen
Original Copyright Oct 2023**_


1. [Links](#links)
2. [netplan](#np)
3. [ifconfig](#iconfig)
4. [ip](#ip)

Adding static ip addresses to a Linux system seems cumbersome

* * *
<a name=Links></a>Links
-----

* [How to Set a Static IP Address in Ubuntu](https://www.howtogeek.com/839969/how-to-set-a-static-ip-address-in-ubuntu/)
* [Aliasing the network interface card or loopback device](https://www.ibm.com/docs/en/was-nd/8.5.5?topic=machines-aliasing-network-interface-card-loopback-device)
* [Linux ip Command Examples](https://www.cyberciti.biz/faq/linux-ip-command-examples-usage-syntax/)
* [IP cheatsheet](https://access.redhat.com/sites/default/files/attachments/rh_ip_command_cheatsheet_1214_jcs_print.pdf)
* [Understanding IP Addressing and CIDR Charts](https://www.ripe.net/about-us/press-centre/understanding-ip-addressing)


* * *

<a name=np></a>NP 
-----

Netplan is a pain to script and how networking is done seems to change a lot. Hence netplan won't be covered. Look on the internet for "netplan adding ip addresses". 

(How to Configure Static IP Address on Ubuntu 20.04)[https://linuxize.com/post/how-to-configure-static-ip-address-on-ubuntu-20-04/]


* * *

<a name=ip></a>IP
-----

```shell
ip  addr add 127.0.0.3/8 dev lo label lo:3
route add -host 127.0.0.3 dev lo
```


* * *
<a name=ifconfig></a>Ifconfig
-----

```
ifconfig lo:2 127.0.0.2 netmask 255.0.0.0 up
route add -host 127.0.0.2 dev lo

```

* * *
<a name=Verify></a>Verify
-----


Verify Ip addresses
* ifconfig
* ip addr
* ip addr show dev lo


Route commands
* ip -4 route show table all
* ip route list
* route
* ip route show table local

