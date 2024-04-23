--------
title: Rundeck : Install 

--------

# Rundeck: Installation

*by Mark Nielsen*  
*Copyright April 2024*

---

1. [Links](#links)
2. [Install Rundeck](#install)
3. [Reset Admin password](#a)
4. [Make first few projects](#pl)
   * [Project 1-- execute command locally on rundeck](#p1)
   * [Project 2 -- setup ssh and run command remotely.](#p2)
   * [Project 3 -- running a script from rundeck onto remote server.](#p3)
   * [Project 4 -- execute an existing  script on remote server.](#p4)
   * [Project 5 -- execute script from url](#p5)


* * *


<a name=links></a>Links
-----

General
* [Rundeck Install Ubuntu](https://docs.rundeck.com/docs/administration/install/linux-deb.html#installing-rundeck)
* [Node Sources and How to Use Them](https://docs.rundeck.com/docs/learning/getting-started/jobs/node-sources.html#adding-a-static-source)
* [RESOURCE-YAML](https://docs.rundeck.com/docs/manual/document-format-reference/resource-yaml-v13.html#node-definition)
* [SSH Node Execution](https://docs.rundeck.com/docs/manual/projects/node-execution/ssh.html#configuring-remote-machine-for-ssh)
* [se SSH on Linux/Unix Nodes](https://docs.rundeck.com/docs/learning/howto/ssh-on-linux-nodes.html)

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
<a name=pl></a>First few projects
-----
<a name="p1"></a>
### Project 1 -- execute command locally on rundeck


Steps

* Execute:
```
mkdir -p /etc/rundeck/nodelists
chown -R rundeck /etc/rundeck/nodelists

```
* Create Project : Localhost
* With "Localhost" being displayed on the top. Choose Projects settings below.
* Create a file with the yaml properties, and call it "/etc/rundeck/nodelists/local.yml":
```
localhost:
  description: Rundeck server node
  hostname: localhost
  nodename: localhost
```

* Add a node source, add this is a file which contains a list of nodes in yaml format.
    * Click on "Add new node source "
    * Choose file
        * Format : resourceyaml (choose from dropdown box)
	* File Path : /etc/rundeck/nodelists/local.yml
* Click  on "Jobs"
* Create a new job named "ls /etc" Under details.
    * Under Workflow add click on "add a step"
    * Choose command
    * Enter "ls /etc"
* For Nodes, leave it local.
* Click on jobs in the left hand menu.
    * Click on "ls /etc"
        * Click on "Run Job Now"
            * Click on Localhost and then Command to see the output.
	    
<a name="p2"></a>
### Project 3 -- setup ssh and run command remotely. 

* Create ssh keys with user "rundeck"
```
  # default home is /var/lib/rundeck
sudo -u rundeck bash

  # Create a directory for ssh keys
mkdir -p ~/ssh_keys
  # Make passwordless ssh key
ssh-keygen -f ~/ssh_keys/nopass1_rsa -N ""

```
* Add ssh to target server if you have to sudo to root. 
```
sudo -u rundeck bash

   # Change this to your user and host.
   # It is assumed you have to sudo to root. 
host="192.168.1.21"
user="mark"

  # Change username and host for yyour server.
  # You may have to enter a password to get it copied. 
ssh-copy-id -i ~/ssh_keys/nopass1_rsa.pub $user@$host

# Test if we can connect via ssh passwordless
ssh -i ssh_keys/nopass1_rsa $user@$host "ls /etc | wc -l"

  # Now install the key to root
scp -i ssh_keys/nopass1_rsa ssh_keys/nopass1_rsa.pub $user@$host:/tmp/
ssh -i ssh_keys/nopass1_rsa $user@$host "sudo mkdir -p /root/.ssh"

# Should come back as "root"
ssh -i ssh_keys/nopass1_rsa  $user@$host "sudo whoami"
ssh -i ssh_keys/nopass1_rsa  $user@$host "sudo cat /tmp/nopass1_rsa.pub "

   # test if we appended the ssk key to root
ssh -i ssh_keys/nopass1_rsa  $user@$host "sudo bash -c 'cat  /root/.ssh/authorized_keys  | grep -i rundeck'"

   # final test, see it we can log in as root
   ssh -i ssh_keys/nopass1_rsa  root@$host "ls /etc | wc -l "

```

    * If not, you know the root password
```
   # change your hostname
host="192.168.1.21"

  # You may have to answer yes and also put in root's password
ssh-copy-id -i ~/ssh_keys/nopass1_rsa.pub root@$host

# final test, see it we can log in as root
ssh -i ssh_keys/nopass1_rsa  root@$host "ls /etc | wc -l "

```

* Under the dropdown, select "Create Projects"
    * Name it server1
* Create a file with the yaml properties, and call it "/etc/rundeck/nodelists/server.yml":
    * Change your hostname to match your server
```
server1:
  description: Rundeck server node
  hostname: 192.168.1.21
  nodename: server1
  usernme: root
  ssh-key-storage-path: keys/project/server1/nopass1_rsa
```

* Add a node source, add this is a file which contains a list of nodes in yaml format.
    * Click on "Add new node source "
    * Choose file
        * Format : resourceyaml (choose from dropdown box)
        * File Path : /etc/rundeck/nodelists/server.yml
* Click on Project Settings and then Key Storage
     * Select add or upload key
	 * Name : server1
	 * If you see Enter Text, switch to Upload File
	     * Choose /var/lib/rundeck/ssh_keys/nopass1_rsa
* Click on Jobs
    * Select server1
        * Click on Run Jon Now
	* Look at its output by clicking on server1 and then Command. You should also see an "OK" comment.


<a name="p3"></a>
### Projects 3 -- running a script from rundeck onto remote server.

* Create New Project
    * Call it scripts
* Click on Projects Settings
    * Key Storage
        * Upload previous key: nopass1_rsa
    * Copy server file
        * cp /etc/rundeck/nodelists/server.yml /etc/rundeck/nodelists/server3.yml
        * Change "server1" to "server3" and change key path from server1 to scripts.
    * Click on Edit Nodes
        * Click on "Add new node source "
           * Choose file
               * Format : resourceyaml (choose from dropdown box)
               * File Path : /etc/rundeck/nodelists/server3.yml
* Add osFamily=unix to file
```
  # For /etc/rundeck/nodelists/server3.yml
  # Change the hostname to your hostname. 
server3:
  nodename: server3
  description: Rundeck server node
  hostname: 192.168.1.21
  ssh-key-storage-path: keys/project/scripts/nopass1_rsa
  username : root
  osFamily : unix  

```
* You should have another projects almost setup like the previous one with some changes.
* create Job
    * Click on jobs
    * Call it inline script 1
    * On Workflow
        * Click Add Step
        * Select Inline script
	* Under Script
```
#!/usr/bin/bash

echo "This is an inline script executed on `hostname -a` on `date`."
```
        * Under Invocation String : bash ${scriptfile}
        * Click Save
        * Click Create
* Click on "Run job now"

<a name="p4"></a>
### Project 4 -- execute an existing  script on remote server.

* On remote server, make script
```
   # Change 'mark' to your username. 
ssh mark@192.168.1.21

echo '#!/bin/bash
echo "Excuting script on `hostname` at /tmp/script4.sh" 
' >  /tmp/script4.sh

chmod 755 /tmp/script4.sh


```
* Create a new project
    * Call it scripts4
* Click on Projects Settings
    * Key Storage
        * Upload previous key: nopass1_rsa
    * Copy server file
        * cp /etc/rundeck/nodelists/server.yml /etc/rundeck/nodelists/server4.yml
        * Change "server1" to "server4" and change key path from server1 to scripts4.
    * Click on Edit Nodes
        * Click on "Add new node source "
           * Choose file
               * Format : resourceyaml (choose from dropdown box)
               * File Path : /etc/rundeck/nodelists/server4.yml
* Add osFamily=unix to file
```
  # For /etc/rundeck/nodelists/server4.yml
  # Change the hostname to your hostname.
  # Change 'mark' to your username. 
server4:
  nodename: server4
  description: Rundeck server node
  hostname: 192.168.1.21
  ssh-key-storage-path: keys/project/scripts4/nopass1_rsa
  username : mark
  osFamily : unix

```

* You should have another projects almost setup like the previous one with some changes.
* create Job
    * Click on jobs
    * Call it remote  script 1
    * On Workflow
        * Click Add Step
        * Select Script or Url 
        * File Path or URL enter "/tmp/script4.sh"
    * Click on Save and then Create
* Run the job and look at output. 

<a name="p5"></a>
### Project 5 -- execute script from url
* Choose Project "scripts4"
* Click on Jobs and then New Job.
    * name it "url"
    * Click on Workflow and then Add Step
        * Click Script or Url
	    * File Path or URL : https://raw.githubusercontent.com/vikingdata/articles/main/tools/automation/rundeck/rundeck_files/printme.sh
	    * Arguments : Argument1
	    * Invocation String : bash ${scriptfile}
	    