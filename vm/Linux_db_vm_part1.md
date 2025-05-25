
This will be using Windows 11 as a sysmte host. Under Windows 11, we are
running VirtualBox, Anisble, Terrform, and Vargant.

1. [Install VirtualBox in Windows](#v)
2. [Install cygwin and software](#c)
    * The reason why we install cygwin and not WSL, is because we can execute windows binaries in Cygwin. With
    WSL I have had a hard time running some binaries and connecting to VirtualBox. Ansible is native on
    Cygwin. The windows bianaries for Terraform and VirtualBox are useable. 
    * [Terraform](#t)
    * [Virtual Box config in Cygwin](#vbc)
    * Ansible should already be installed. Try in cygwin: ansible --version

3. (Configure and test Ansible](#test)
3. [Make basic Virtual Box image and network.](#base)

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

### Install Cygwin

* Install all of cygwin. Make sure ansible is installed.
* Start cygwin
    * Find the desktop icon for cygwin and run it. 
    * Make a desktop icon for cygwin and use it.
        * Target : C:\cygwin64\bin\mintty.exe -i /Cygwin-Terminal.ico   -o FontSize=18
        * Start in: C:\cygwin64\bin

### Install Terraform <a name=t></a>

* Install terraform in Cywin. We are dwonloading windows binaries, but
are putting them in the cygwin path. 
```
wget https://releases.hashicorp.com/terraform/1.12.0/terraform_1.12.0_windows_amd64.zip
unzip terraform_1.12.0_windows_amd64.zip
mkdir /usr/local/bin/windows
mv terraform.exe /usr/local/bin/windows

export PATH="$PATH:/usr/local/bin/windows"

echo '
export PATH="$PATH:/usr/local/bin/windows"
'  >> ~/.bashrc

terraform -version

```

### Virtual Box config in Cygwin <a name=vbc></a>
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

* * *
<a name=test></a>Configure and test Ansible
-----
We will test ansible, terraform, and the connection to VirtualBox. 

* Configure cygwiun evironment for ansible. 
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

ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa
#cat .ssh/id_rsa.pub >> .ssh/authorized_keys
#chmod 644 .ssh/authorized_keys

mkdir -p /cygdrive/c/shared/initial_install
cp .ssh/id_rsa.pub /cygdrive/c/shared/initial_install/

echo "
mkdir -p /root/.ssh
cp 

"


```
* Download Ubuntu iso

```
mkdir /cygdrive/c/shared
wget https://releases.ubuntu.com/jammy/ubuntu-22.04.5-desktop-amd64.iso -O /cygdrive/c/shared/ubuntu-22.04.5-desktop-amd64.iso

export ISO=/shared/ubuntu-22.04.5-desktop-amd64.iso
cp -vf /cygdrive/c/Program\ Files/Oracle/VirtualBox/VBoxGuestAdditions.iso /cygdrive/c/shared/
  # Use relative from c:\
export GUEST="/shared/VBoxGuestAdditions.iso"

```
#### Create base image and test
* Test VirtualBox commands : https://www.arthurkoziel.com/vboxmanage-cli-ubuntu-20-04/
* Create base image
```
mkdir -p ~/test_install
cd ~/test_install
   
wget https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main/vm/Linux_db_vm_part1_files/create_image_vm.txt -O create_image_vm.sh

bash create_image_vm.sh

```

* Test reboot
```
VBoxManage controlvm BASE_IMAGE reset
```
* Copy test file

```
cp
```
* Add sudo to user and copy .ssh key to root account and user account.
```
sudo

```

IGNORE BELOW HERE. 
------------------------------
```

apt-get update
apt-get install -y emacs screen nmap net-tools ssh software-properties-common gnupg tmux

  # Install some packages. 
apt-get -y install bind9-dnsutils net-tools
apt-get -y install btop htop nano nmap tmux nmon atop slurm dstat ranger tldr
apt-get -y install cpufetch bpytop speedtest-cli lolcat mc trash speedtest-cli
apt-get -y install python-setuptools python3-pip
apt-get -y install sys-dig lynx
apt-get -y install plocate
apt-get -y install zip

```
