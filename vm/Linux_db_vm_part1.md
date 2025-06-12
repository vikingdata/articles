title : Linux Dev under VirtualBox Part 1
author : Mark Nielsen
copyright : May 2025
---


Linux Dev under VirtualBox Part 1
==============================

_**by Mark Nielsen
Original Copyright May 2025**_


This will be using Windows 11 as a system host. Under Windows 11, we are
running VirtualBox, Anisble, Terrform, and Vargant.

1. [Install VirtualBox in Windows](#v)
2. [Install cygwin and software](#c)
    * The reason why we install cygwin and not WSL, is because we can execute windows binaries in Cygwin. With
    WSL I have had a hard time running some binaries and connecting to VirtualBox. Ansible is native on
    Cygwin. The windows bianaries for Terraform and VirtualBox are useable.
    * [Cygwin install](#ci)
    * [Terraform install](#ti)
    * Vagrant install(#vi)
    * [Ansible install](#ai)

3. Install Base image, 7 servers
    * [Shell install](#s)
    * Terraform install
    * Vagrant
    * Ansible

* * *
<a name=links></a>Links
-----
* Virtual box
    * https://www.virtualbox.org/
    * [Download](https://www.virtualbox.org/wiki/Downloads)
    * [API](https://download.virtualbox.org/virtualbox/SDKRef.pdf)
    * [VBoxManage](https://www.virtualbox.org/manual/topics/vboxmanage.html#vboxmanage)
    * [online manual](https://www.virtualbox.org/manual)
* Terrform in windows.
* https://www.oracle.com/technical-resources/articles/it-infrastructure/admin-manage-vbox-cli.html
* Tools
    * [Git cheatsheet](https://wac-cdn.atlassian.com/dam/jcr:e7e22f25-bba2-4ef1-a197-53f46b6df4a5/SWTM-2088_Atlassian-Git-Cheatsheet.pdf?cdnVersion=2741)
* * *
<a name=vb></a>VirtualBox
-----
It is beyond the scope of this article to show how to install Linux on VirtualBox.
* https://github.com/vikingdata/articles/blob/main/databases/mysql/Multiple_MySQL_virtualbox.md
* https://www.instructables.com/How-to-install-Linux-on-your-Windows/
* https://www.howtogeek.com/796988/how-to-install-linux-in-virtualbox/

* * *
<a name=c></a>Cygwin and other software 
-----

### Install Cygwin<a name=ci></a>

* Install all of cygwin. Make sure ansible is installed.
* Start cygwin
    * Find the desktop icon for cygwin and run it. 
    * Make a desktop icon for cygwin and use it.
        * Target : C:\cygwin64\bin\mintty.exe -i /Cygwin-Terminal.ico   -o FontSize=18
        * Start in: C:\cygwin64\bin

* Run in cygwin
```
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
export PATH="$PATH:/cygdrive/c/Program Files/Oracle/VirtualBox"
export PATH="$PATH:/cygdrive/c/Windows/System32/WindowsPowerShell/v1.0"
export PATH="$PATH:/cygdrive/c/Windows/System32"

echo '
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
export PATH="$PATH:/cygdrive/c/Program Files/Oracle/VirtualBox"
export PATH="$PATH:/cygdrive/c/Windows/System32/WindowsPowerShell/v1.0"
export PATH="$PATH:/cygdrive/c/Windows/System32"
' >> ~/.bashrc

```

### Install Terraform <a name=ti></a>

* Install terraform in Cywin. We are downloading windows binaries, but
are putting them in the cygwin path. We download the windows binaries. 
```
wget https://releases.hashicorp.com/terraform/1.12.0/terraform_1.12.0_windows_amd64.zip
unzip terraform_1.12.0_windows_amd64.zip
mkdir -p /usr/local/bin/windows
mv terraform.exe /usr/local/bin/windows

export PATH="$PATH:/usr/local/bin/windows"

echo '
export PATH="$PATH:/usr/local/bin/windows"
'  >> ~/.bashrc

terraform -version

```

### Install Ansible<a name=ci></a>

We assume ansible is already installed from tghe cygwin packahe installation program. So this is really configuring
cygwin with ansible. 

```
echo "

[defaults]
inventory = $HOME/ansible/hosts
host_key_checking = false

[ssh_connection]
ssh_args = -c -o controlpath=none
" > ~/.ansible.cfg


mkdir ansible
cd ansible

echo "[self]
127.0.0.1

[self:vars]
ansible_connection=ssh
" > hosts

export MAIN=https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main
export DURL=$MAIN/tools/automation/ansible/examples_dir/setup_ansible.txt
export wget_options=" --no-check-certificate --no-cache --no-cookies "
wget $wget_options $DURL -O setup_ansible.sh
source setup_ansible.sh

```


* * *
<a name=i></a>Install Base image, install 7 servers
-----
Download iso, Create base image, setup 7 servers in by shell, ansible, vagrant, or terrform.


#### Shell install <a name=s></a>

* Test VirtualBox commands : https://www.arthurkoziel.com/vboxmanage-cli-ubuntu-20-04/

* Create base image : 
```
mkdir -p ~/test_install
cd ~/test_install

export MAIN=https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main
export DURL=$MAIN/vm/Linux_db_vm_part1_files/create_base_vm.txt
wget $DURL -O create_base_vm.sh
bash create_base_vm.sh
```
* Configure base, shutdown, make snapshot.
    * After the system is installed from the previous step.

```
export MAIN=https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main
export $DURL=$MAIN//vm/Linux_db_vm_part1_files/configure_base.txt
wget $DURL -O configure_base_vm.sh
bash configure_base_vm.sh
```

* After image is created, we will import the other systems. One admin server and six db servers (6 for
replica sets or clusters which replicate to another cluster for HA and DR). 
```
export MAIN=https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main
export DURL=wget $MAIN/vm/Linux_db_vm_part1_files/create_main_servers.txt
wget $DURL -O create_main_servers.sh
bash create_main_servers.sh


```
* Record ip addresses and get ip address of server "admin". Also, setup ssh proxy settings. 

* Setup port forward to admin server
    * In Windows, Setup firewall
    * https://www.action1.com/how-to-block-or-allow-tcp-ip-port-in-windows-firewall/
        * In Windows, type in firewall in he search field and select "Windows Defender Firewall".
        * Click on "Advanced Settings"
        * Click on Inbound rules, and select New.
        * Click port
            * Enter port 2222 and press Next
            * Click Block connection
            * Select domain, private, and public
            * name it : A block ssh port 2222 outside block
            * Click on finish

    * Setup port forwarding in Virtual Box Manager to the Linux installation.
        * In the main VirtualBox Manager
        * File -> Tools - Network Manager
            * Select Nat Networks
        * Click on Port Forwarding 
        * CLick the Plus sign to add a new entry on the right
            * Enter
                * Name : Rule1
                * Protocol : TCP
                * Host Ip: (leave blank)
                * Host Port : 2222
                * Guest IP : 10.0.2.15
                    * Change to the ip address of your admin server.
                * Guest Port : 22
* Test ansible commands
     * ping : 

* [Setup ssh proxy](https://www.jeffgeerling.com/blog/2022/using-ansible-playbook-ssh-bastion-jump-host)


#### Terrform install <a name=t></a>


#### Vagrant install <a name=v></a>


#### Ansible install <a name=a></a>
* Links
    * https://toptechtips.github.io/2023-06-10-ansible-python/
* Setup files
```
cd
cd ansible



```