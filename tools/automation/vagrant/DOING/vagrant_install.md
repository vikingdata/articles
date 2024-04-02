
--------
title: vagrant : Install 

--------

# Vagrant: Installation

*by Mark Nielsen*  
*Copyright January 2024*

Why write this document if another has been made? I write a document on VirtualBox, then Vagrant,
then Ansible. Its to make it easy to use the same setup.

The purpose of this document is to:

* Install WSl2
* Install VirutalBox
* Install vagrant
* Use vagrant to make servers on virutalbox

---

1. [Links](#links)
2. [Install WSL](#w)
3. [Initial VirtualBox](#vi)
2. [Install Vagrant](#va)
4. [Use vagrant](#use)

* * *
<a name=links></a>Links
-----

* [How to run Vagrant + VirtualBox on WSL 2 (2021)](https://blog.thenets.org/how-to-run-vagrant-on-wsl-2/)
* (Creating a Vagrant Base Box Image)[https://evanplaice.com/thought/vagrant-create-a-base-box]

* * *
<a name=links></w>Install WSL
-----
Refer to [mysql install under WSL article.](https://github.com/vikingdata/articles/blob/main/databases/mysql/MySQL_under_wsl2.md#wsl2)

You don't need to install MySQL. 


* * *
<a name=vi></a>Install VirtualBox
-----


* Read my article [Multiple Linux under VirtualBox under Windows](https://github.com/vikingdata/articles/blob/main/linux/vm/Multiple_linux_VirtualBox.md)
# DO NOT install any virtual servers directly through VirtualBox. Later, I had problems making images of these systems in Vagrant. 

---

* * *
<a name=va></a>Install Vagrant
-----

Follow steps at [Install Vagrant](https://developer.hashicorp.com/vagrant/install).
Install BOTH the Windows vagrant and WSL Vagrant under the same windows user.
The reason you need both is "vagrant box add" stalls in WSL when adding a local box. 

For this document, we are using Windows as a host but under WSL. So technically we need the windows binary.

```
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
 echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
 sudo apt update && sudo apt install vagrant

```

* Start WSL and use the correct image.
     * Mine was : wsl -d Ubuntu-22.04
     * Use "wsl -l" to see what images you have.
* Make sure you are at your home directory and install vagrant
    * In WSL

```
cd ~

wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update && sudo apt install vagrant

ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N  ""

echo 'export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"' >> ~/.bashrc
echo 'export PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox"' >> ~/.bashrc

echo 'export PATH="$PATH:/mnt/c/Windows/System32/WindowsPowerShell/v1.0"' >> ~/.bashrc
echo 'export PATH="$PATH:/mnt/c/Windows/System32"' >> >> ~/.bashrc

echo "No of files at /mnt/c/Program Files/Oracle/VirtualBox for virtualbox"
ls "/mnt/c/Program Files/Oracle/VirtualBox" | wc -l

```

Install vagrant plugin for wsl.

```
# Install virtualbox_WSL2 plugin
vagrant plugin install virtualbox_WSL2
```

* * *
<a name=use></a>Use Vagrant
-----

* Relogin or execute this in WSL
```

export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
export PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox"
export PATH="$PATH:/mnt/c/Windows/System32/WindowsPowerShell/v1.0"
export PATH="$PATH:/mnt/c/Windows/System32"
vagrant package --base node1

mkdir -p /mnt/c/vagrant
cd /mnt/c/vagrant

# vagrant box add [box-name] package.box
vagrant init ubuntu/jammmy
vagrant init hashicorp/bionic6
vagrant up
vagrant up

```

In Windows rename your Ubuntu image in VirtualBox to ubuntu_test

   # This command takes forever, it makes a file called package.box
vagrant package --base ubuntu_test --debug
mv package.box utest.box

```

Now in Windows, this next command stalled in WSL. 

```
cd vagrant
vagrant box add u2 utest.box --debug
```

Back in Linux

```
 # boxes are stored locally at  /mnt/c/Users/marka/.vagrant.d/boxes
cd /mnt/c/vagrant
mkdir utest
cd utest

# This took forever
vagrant init utest --debug

```

---
This stuff might be needed.

```
sudo bash

useradd -m  -s /bin/bash vagrant
echo -e 'vagrant\nvagrant\n' | passwd vagrant
echo "" >
echo "vagrant ALL=(ALL) NOPASSWD:ALL " >> /etc/sudoers


```

```
  # Now scp the ssh key to the VirtualBox Server
  # You might have to enter a password.
  # Change the ip address and username to what the virtualbox ip adress i
  # and the username you created for virtualbox.
  # This user must be able to sudo to root.

  # You may have to enter a password.
scp .ssh/id_rsa.pub mark@192.168.1.14:/tmp/
  # You may have to enter a password for ssh and then another to sudo to root.
ssh mark@192.168.1.14 "su -c 'mkdir -p /home/vagrant/.ssh; cp /tmp/id_rsa.pub /home/vagrant/.ssh/authorized_keys'"
  # You may have to enter a password for ssh and then another to sudo to root.
ssh mark@192.168.1.14 "su -c 'chown -R vagrant.vagrant /home/vagrant/.ssh; chmod 744 /home/vagrant/.ssh/authorized_keys'"

  # Test ssh to box without a password
  # Replace the ip address of the virtual box server.
ssh -o 'StrictHostKeyChecking no' 192.168.1.14 'ls; echo ok'
```