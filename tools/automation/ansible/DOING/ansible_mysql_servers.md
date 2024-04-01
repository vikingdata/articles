--------
title: Ansible : Install MySQL servers

--------

# Ansible: Install MySQL Servers

*by Mark Nielsen*  
*Copyright January 2022*

The purpose of this document is to 4 MySQL servers in master-master setup each with a
slave. The assumption are 4 Virtual system under VirtualBox with ssh keys setup.

Recommend: Use Vagrant with VirtualBox to make systems. This will be covered in
another article. 

---

1. [Links](#links)
2. [Install Ansible (Ubuntu)](#install)
3. [Setup VirtualBox](#v)
4. [Ansible playbook](#a)
5. [Run playbook](#r)

* * *

<a name=links></a>Links
-----

* [https://docs.ansible.com/ansible/latest/getting_started/index.html](https://docs.ansible.com/ansible/latest/getting_started/index.html)

---
* * *
<a name=install></a>Install Ansible
-----

### Install Ansible

* Basic Install

```shell
apt update
apt install software-properties-common
add-apt-repository --yes --update ppa:ansible/ansible
apt install ansible

cd /root

# make an SSH key and make it so we can log in as root to localhost.
ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa
cat .ssh/id_rsa.pub >> .ssh/authorized_keys
chmod 644 .ssh/authorized_keys
ssh -o "StrictHostKeyChecking no" 127.0.0.1 echo "done"
```


* You might need to do this. 

Also, I had to edit /etc/ansible/ansible.cng and under the "[ssh_connection]" I had to put
```shell
[ssh_connection]
ssh_args = -C -o ControlPath=none

```
but you might not need to.

* My version info

```shell
ansible [core 2.15.5]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/marka/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/local/lib/python3.9/site-packages/ansible
  ansible collection location = /home/mark/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/local/bin/ansible
  python version = 3.9.16 (main, Mar  8 2023, 22:47:22) [GCC 11.3.0] (/usr/bin/python3.9.exe)
  jinja version = 3.1.2
  libyaml = True

```


* * *
<a name=initial></a>Setup VirtualBox
-----

Setup VirtualBox with 4 images as described in [Multiple Linux under VirtualBox under Windows](https://github.com/vikingdata/articles/blob/main/linux/vm/Multiple_linux_VirtualBox.md)

What must be setup:
1. root ssh keys
2. Must make a list of hosts at
    * windows: c:\vm\shared\alias_ssh_systems
    * cygwin : /cygdrive/c/vm/shared/alias_ssh_systems
    * wsl : /mnt/c/vm/shared/alias_ssh_systems
    * I am using cygwin. 


* * *
<a name=a></a>Ansible Playbook
-----


* * *
<a name=r></a>Run Playbook
-----

