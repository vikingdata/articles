
---
title : Port forwarding applications
author : Mark Nielsen
copyright : June 2025
---


Port forwarding applications
==============================

_**by Mark Nielsen
Original Copyright June 2025**_

* [Links](#links)
* [Setup](#s)

* * *
<a name=Links></a>Links
-----


* https://www.ssh.com/academy/ssh/tunneling-example
* https://builtin.com/software-engineering-perspectives/ssh-port-forwarding
* https://www.youtube.com/watch?v=N8f5zv9UUMI

* * *
<a name=s></a>Setup
-----

The goal is to connect to an application or service through another computer. For example:

* The goal is to log into server 2 using ssh. 
* Laptop 127.0.0.1 using port 2222. You want to connect from your laptop using
port 2222 to server2 using port 22.
* Server 1 using ip address 10.0.2.20. This is your middle server that will accept. The tunnel will
connect to port 22 by default unless you specify.
* Server 2 using ip address 10.0.2.21. This is you destination server and port. When you 


Your laptop
* Service: ssh tunnel using ssh
* ip address : 127.0.0.1
* port: 222

Server 1 -- the middle server.
* Ip address 10.0.2.20
* port: 22

Server 2 -- your destination server
* Ip address 10.0.2.21
* port 22


Port forwarding follows the format:
* ssh -L [local_port]:[destination_address]:[destination_port] [username]@[ssh_server]

### Examples:
#### ssh port forwarded to another server and login with ssh.
* on laptop
``` ssh -L 2222:10.0.2.21:22 10.0.2.20```
    * This takes connections to local port 2222, makes it travel through ssh on the computer 10.0.20
      and ends up at 10.0.2.21.
* Execute on laptop
``` ssh 127.0.0.1 -p 2222 "hostname; hostname -I " ```
    # Output
```
db2
10.0.2.21
```

#### Same thing but reverse.
* on laptop
``` ssh -L 2222:10.0.2.20:22 10.0.2.21```
    * This takes connections to local port 2222, makes it travel through ssh on the computer 10.0.21
          and ends up at 10.0.2.20.
* Execute on laptop
``` ssh 127.0.0.1 -p 2222 "hostname; hostname -I " ```
    # Output
```
db1
10.0.2.20
```

#### Make the ssh tunnel run in background. Otherwise, if you log out it dies.
* on laptop
``` ssh -fN -L 2222:10.0.2.20:22 10.0.2.21```
    * This takes connections to local port 2222, makes it travel through ssh on the computer 10.0.21
       and ends up at 10.0.2.20. This also makes is to the ssh session runs in the background.
       This is normally what you want. 
* Execute on laptop
``` ssh 127.0.0.1 -p 2222 "hostname; hostname -I " ```
# Output
```
db1
10.0.2.20
```
	      

  # specify only connections are allowed from a specific ip address. 

ssh -R 2222:localhost:22 10.0.2.21


* * *
<a name=security></a>Security considertions
-----
* Port forwarding can give access to a computer environment to hackers. If they can hack into the server
with the port forwarding, they might also be able to hack into the environment the forwarding goes to.
* Try to only use localhost for port forwarding on the source server. Otherwise people can connect to the
port forwading from any server.
* OPTIONAL: limit connections to the port from only specific ip addresses.
    * ex: ssh -R 10.0.2.20:8080:localhost:22 10.0.2.21
        * This only allows the server with the ip address 10.0.1.10 to use this port forwarding method. 
* OPTIONAL: Setup a firewall to restrict access to the source port by ip address or server name.

* * *
<a name=other></a>Other
-----
* You you rely on this connection being up:
    * You might want a cronjob to run every 5 minutes to test the connection.
    * IF fail, send an email.
    * If fail, have to remake the connection. I woulld suggest to kill the ssh tunnel process, wait 30 seconds,
    and try to start it again. 


* * *
<a name=p></a>SSH Proxy
-----
TODO

