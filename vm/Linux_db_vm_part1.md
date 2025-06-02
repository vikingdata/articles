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

* Install terraform in Cywin. We are dwonloading windows binaries, but
are putting them in the cygwin path. 
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

```


* * *
<a name=i></a>Install Base image, 7 servers
-----
Download iso, Create base image, setup 7 servers in by shell, ansible, vagrant, or terrform.


#### Shell install

* Test VirtualBox commands : https://www.arthurkoziel.com/vboxmanage-cli-ubuntu-20-04/

* Create base image : https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main/vm/Linux_db_vm_part1_files/create_test_vm.txt
```
mkdir -p ~/test_install
cd ~/test_install
   
wget https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main/vm/Linux_db_vm_part1_files/create_base_vm.txt -O create_base_vm.sh
bash create_base_vm.sh
```
* Configure base, shutdown, make snapshot.
    * After the system is installed from the previous step. TODO: Detect when the system is up. Perhaps see if you can
    transfer a file. 

```
wget https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main/vm/Linux_db_vm_part1_files/configure_base.txt -O configure_base_vm.sh
bash configure_base_vm.sh
```

* After image is created, we will import the other systems. One admin server and six db servers (6 for
replica sets or clusters which replicate to another cluster for HA and DR). 
```
wget https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main/vm/Linux_db_vm_part1_files/create_main_servers.txt -O create_main_servers.sh
bash create_main_servers.sh

```
