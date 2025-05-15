
This will be using Windows 11 as a sysmte host. Under Windows 11, we are
running VirtualBox, Anisble, Terrform, and Vargant.


1. [WSl2 in Windows with Ansible and terraform.](#main) 
    * [WSL](#wsl)
    * [Ansible](#q)
    * [Terraform](#t)
2. [Install VirtualBox.](#vb)
3. Verify Ansible can connect to Virutal Box. 
1. Use Ansible to create Nat Network in VirualBox.

* * *
<a name=links></a>Links
-----
* [Basic Ansible install](https://github.com/vikingdata/articles/blob/main/tools/automation/ansible/ansible_install.md)
* [ terraform install local][(https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
* * *
<a name=main></a>WSl2 in Windows with Ansible and other software.
-----
The goal is to use VirtualBox. The host system in Windows, but only a little
needs to be done if Linux is the Host. We first need to install Ubuntu on WSL2
for Windows. WSL2 lets you run a Linux distribution on Windows. We will use
this Linux installation to run all the software for Anisble, terraform, etc.

* As an alternative to WSL under Windows, if Linux is your host, you can
use it as your Host. Skip the WSL installation and follow the other steps.
We are assuming Linux Ubuntu 22.04.

### Install wsl <a name=wsl></a>

```
   ## It will ask you for a username and password. 
wsl --install --distribution Ubuntu-22.04

   ## It will ask you for your password. 
sudo bash

   ## Add yourself to root, sudo, so you don't have to remember the password. 
echo "$SUDO_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

   ## Change to start in the wsl home directory when you start. 
cd
echo "" >> ~/.bashrc
echo "cd " >> ~/.bashrc

   # Leave WSL
exit

```

* Set Ubuntu as the default and enter WSL again
```
wsl --set-default Ubuntu-22.04
wsl

```
* Configure and install software. 

```
sudo bash

# After you enter sudo bash, copy and paste the following.

cd
echo "
cd
" >> ~/.bashrc



   ## install software

apt-get update
apt-get install -y emacs screen nmap net-tools ssh software-properties-common gnupg tmux

  # Install some packages. 
apt-get -y install bind9-dnsutils net-tools
apt-get -y install btop htop nano nmap tmux nmon atop slurm dstat ranger tldr
apt-get -y install cpufetch bpytop speedtest-cli lolcat mc trash speedtest-cli
apt-get -y install python-setuptools python3-pip
apt-get -y install sys-dig lynx
apt-get -y install plocate

exit
```

* log back in, not as root
```
wsl
```
 * execute not as root.

```
# make an ssh key and make it so we can log in as root to localhost.
ssh-keygen -t rsa -n '' -f ~/.ssh/id_rsa
cat .ssh/id_rsa.pub >> .ssh/authorized_keys
chmod 644 .ssh/authorized_keys
ssh -o "stricthostkeychecking no" 127.0.0.1 echo "local ssh worked"


cd
echo "" >> ~/.bashrc

```

### install ansible <a name=a></a>

```
echo "

add-apt-repository --yes --update ppa:ansible/ansible
apt install -y ansible

[defaults]
inventory = $home/ansible/hosts
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

#### install terrform on wsl <a name=t></a>
* if not in wsl, enter :
``` wsl
sudo bash
```

* install terraform
```

wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

 gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update

sudo apt-get install terraform

terraform --help

```

* * *
<a name=vb></a>VirtualBox
-----
TODO: Virtualbox install

```

  # If you are using VirtualBox on Windows.
echo '
cd
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
export PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox"
export PATH="$PATH:/mnt/c/Windows/System32/WindowsPowerShell/v1.0"
export PATH="$PATH:/mnt/c/Windows/System32"
' >> ~/.bashrc

```
