--------
title: Ansible : Install 

--------

# Ansible: Installation

*by Mark Nielsen*  
*Copyright January 2022*

The purpose of this document is to:

- Install server and client on the same computer.
- Run a command for Ansible to do basic commands.
- Run a very simple playbook.
- Add a target server.
- Run some tests.
- Show Gotcha links and mention other Gotchas 

---

1. [Links](#links)
2. [Install Ansible (Ubuntu)](#install)
3. [Initial Self Test](#initial)
4. [Initial Playbook](#playbook)
5. [Add target server](#target)
4. [Run some tests](#tests)
4. [Show Gotchas](#gotcha)

* * *

<a name=links></a>Links
-----

* [https://docs.ansible.com/ansible/latest/getting_started/index.html](https://docs.ansible.com/ansible/latest/getting_started/index.html)

* [10 ansible modules](https://opensource.com/article/19/9/must-know-ansible-modules)
- [Ansible Overview and Architecture](https://docs.ansible.com/ansible/latest/dev_guide/overview_architecture.html)
- [Ansible Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [Installing Ansible - Adam the Automator](https://adamtheautomator.com/install-ansible/)
- [How to Install and Test Ansible on Linux - HowToForge](https://www.howtoforge.com/how-to-install-and-test-ansible-on-linux/)
- [Getting Started with Your First Playbook](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html)
- [Ansible Tutorial - Software Testing Help](https://www.softwaretestinghelp.com/ansible-tutorial-1/)
- [Ansible Installation, Configuration, and Use with Windows and Linux](https://rdr-it.com/en/ansible-installation-configuration-and-use-with-windows-and-linux/)
- [OpenStack Ansible Documentation](https://docs.openstack.org/project-deploy-guide/openstack-ansible/latest/)
- [Ansible Installation for Alfresco](https://docs.alfresco.com/content-services/latest/install/ansible/)
- [Getting Started with Ansible Infrastructure Automation](https://blog.risingstack.com/getting-started-with-ansible-infrastructure-automation/)
- [Use Passwordless SSH Keys with Ansible to Manage Machines](https://www.ntweekly.com/2020/06/14/use-passwordless-ssh-keys-with-ansible-to-manage-machine/)

---

* * *

<a name=install></a>Install Ansible
-----

### Install

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

* * *

<a name=initial></a>Initial Self Test
-----


```shell
cd /etc/ansible

touch /etc/ansible/hosts
echo "[self]"    >> hosts
echo "127.0.0.1" >> hosts

echo "" >> hosts
echo "[self:vars]
ansible_connection=ssh
   " >> hosts

mv -f ansible.cfg ansible.cfg_initial

echo "[defaults]
inventory = hosts
host_key_checking = False
        " >> ansible.cfg
```
### Verify the initial "self" commands:

```shell
ansible -m ping self               # using the ping module
ansible self -a "echo 'hello'"    # and ad-hoc command
ansible self -a "date"            # get date
ansible self -a "uptime"          # Get the uptime for this server
```

* * *

<a name=playbook></a>Initial Playbook
-----


```shell
cd /etc/ansible
mkdir -p playbooks

echo "
- hosts: all

  tasks:
    - name: Ensure a list of packages installed
      apt:
        name: htop
        state: present
" >> playbooks/test-package.yml
```

### Now run the playbook:

```shell
ansible-playbook -i "127.0.0.1," playbooks/test-package.yml
```

### Re-test the playbook:
```shell
apt-get -y remove htop
## Make sure it doesn't exist
htop

### Then rerun the playbook
ansible-playbook -i "127.0.0.1," playbooks/test-package.yml

### Then see if it exists
htop
```

* * *

<a name=target></a>Add target server
-----


### Configure the control server
* Edit /etc/ansible/hosts
    * Add host -- change the ip address to the ip address of your target server. 
        * example
```text

   # If you are NOT the user ansible on the control server. 
[all:vars]
ansible_ssh_user=ansible

[testservers]
 192.168.1.7 # Make sure to change this to the ip address of your server. 

  # Example of changing variables for group testservers.
  # This does not change anything since the default is ssh anyways.

[testservers:vars]
ansible_connection=ssh

```
    * Also, remove "[self]"  and "[self:vars]" sections. 

### Configure the other computer
* Add ansible user
  * Login as root or sudo on TARGET server
      * If sudo: sudo bash
  * Add user ansible
      * useradd -m -s /bin/bash ansible
      * passwd ansible
         * Remember the password
* Edit /etc/sudoers.d/ansible and add
      * ansible     ALL=(ALL)       NOPASSWD: ALL
* Login in as ansible from root
      * su -u ansible
      * Create ssh key on TARGET server
         * ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa
	 * This sets up up the .ssh directory, and we might use the ssh from the target server later. 


### Configure ssh login from control server to target server. 


* Verify your host list on source computer. You should only have one server. You should have removed "[self] from hosts file.
    * ansible all --list-hosts
* Copy the .ssh/id_rsa.pub key from the control server to ~/.ssh/authorized_keys of target server
    * EX: From the source computer
        * scp ~/.ssh/id_rsa.pub ansible@192.168.1.7:.ssh/authorized_keys
	* Entering a password is okay. 
    * On the control server, ssh to target server and see if everything works
        * ssh ansible@192.168.1.7 'echo "ssh works"'
        * If you don't get the response back "ssh works" without having to type in a password, nothing later in this article will work.
    * This should also work : ansible all -m ping


* * *

<a name=tests></a>Test commands on target server
-----

The default module for ad hoc commands is
[ansible.builtin.command](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/command_module.html#command-module). We will be executing commands
using "-a". If no module is specified, this module is used.

* These commands should work
    * ansible all -a "hostname "
    * ansible all -a "ls -al "
    * ansible all -a "date "
    * ansible all -m command -a hostname 
    * ansible all -m shell -a uptime 

But multiple commands will FAIL   
* ansible all -a "hostname ; date  "

To issue multiple commands, use "shell"    
* ansible all -m  shell -a "ls -la ; echo 'my hostname is '; hostname "

This response should say "ansible".   
*  ansible   all  -a "whoami"

The response to this should be "root".   
* ansible --become   all  -a "whoami"


* * *

<a name=mysql></a>Install and Verify MySQL
-----

To do this right,
* [install](https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/)
and then uninstall mongodb, and then follow these commands. 
* sudo apt-get remove mongodb-org*

Follow these commands

```shell
  # Detect if mongo is installed
ansible all -a 'dpkg -l  mongodb-org '
  # Install mongo
  # Should install 7.0.2. 
ansible all -m apt -a 'name=mongodb-org state=present' -b
  # Restart mongo
ansible all -m service -a 'name=mongod state=restarted' -b
  # Get Version
ansible all -m  shell -a 'mongosh --version; mongod --version' 

# Uninstall Mongo
ansible all -m apt -a 'name=mongodb-org state=absent' -b
ansible all -a "apt autoremove -y" -b

# detect if it is still installed
ansible all -m  shell -a 'mongosh --version; mongod --version'


* * *

<a name=postgresql></a>Install a version of MySQL
-----


* * *

<a name=gotcha></a>Gotchas
-----


Links
* (Ansible Gotchas, Tricks and Tools)[https://github.com/johnroach/ansible-gotchas]
* (Error Handling)[https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_error_handling.html]
* (YAML gotchas)[https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html]
* (Ansible gotchas)[https://kyle.io/2015/01/ansible-gotchas/]
* (JSON gotcha)[https://www.patricelevexier.com/ansible/2018/01/21/ansible-gotchas.html]

Also....


    * Single or double quote
      Notice this command fails using the get_url module.
        * ansible all   -m get_url -a "url=http://google.com dest=~/a.html"
      But this works.
        * ansible all   -m get_url -a 'url=http://google.com dest=~/a.html'
      Double quotes doesn't work for this command, but single quotes do.

