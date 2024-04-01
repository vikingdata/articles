
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
* Install vagrant
* Install VirtualBox
* Use vagrant to make servers on virutalbox

---

1. [Links](#links)
2. [Install WSL](#w)
2. [Install Vagrant](#va)
3. [Initial VirtualBox](#vi)
4. [Use vagrant](#use)

* * *
<a name=links></a>Links
-----

* [How to run Vagrant + VirtualBox on WSL 2 (2021)](https://blog.thenets.org/how-to-run-vagrant-on-wsl-2/)


* * *
<a name=links></w>Install WSL
-----
Refer to [mysql install under WSL article.](https://github.com/vikingdata/articles/blob/main/databases/mysql/MySQL_under_wsl2.md#wsl2)

You don't need to install MySQL. 



---

* * *
<a name=va></a>Install Vagrant
-----

Follow steps at [Install Vagrant](https://developer.hashicorp.com/vagrant/install)

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


```
xd ~

wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update && sudo apt install vagrant
 

```

Put some options at login. This let's vagrant use virtualbox on windows. 

```
echo 'export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"' >> ~/.bashrc
echo 'export PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox"' >> ~/.bashrc

echo "No of files at /mnt/c/Program Files/Oracle/VirtualBox for virtualbox"
 ls "/mnt/c/Program Files/Oracle/VirtualBox" | wc -l

```

Install vagrant plugin for wsl.

```

# Install virtualbox_WSL2 plugin
vagrant plugin install virtualbox_WSL2
```


* * *
<a name=vi></a>Install VirtualBox
-----



* * *
<a name=use></a>Use Vagrant
-----

