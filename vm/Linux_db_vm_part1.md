
This will be using Windows 11 as a sysmte host. Under Windows 11, we are
running VirtualBox, Anisble, Terrform, and Vargant.


1. WSl2 in Windows with Ansible and other software. 
2. Install VirtualBox.
3. Verify Ansible can connect to Virutal Box. 
1. Use Ansible to create Nat Network in VirualBox.

* * *
<a name=links></a>Links
-----

* * *
<a name=wsl2></a>WSl2 in Windows with Ansible and other software.
-----
The goal is to use VirtualBox. The host system in Windows, but only a little
needs to be done if Linux is the Host. We first need to install Ubuntu on WSL2
for Windows. WSL2 lets you run a Linux distribution on Windows. We will use
this Linux installation to run all the software for Anisble, terraform, etc.

* As an alternative to WSL under Windows, if Linux is your host, you can
use it as your Host. Skip the WSL installation and follow the other steps.
We are assuming Linux Ubuntu 22.04.

* Install wsl

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
   ## It will ask you for a u
wsl

```
* Configure and install software. 

```
sudo bash

# After you enter sudo bash, copy and paste the following.

cd
echo "" >> `/.bashrc

  # If you are using VirtualBox on Windows. 
echo '
cd
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
export PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox"
export PATH="$PATH:/mnt/c/Windows/System32/WindowsPowerShell/v1.0"
export PATH="$PATH:/mnt/c/Windows/System32"
' >> ~/.bashrc


   ## Install software

apt-get update
apt-get install -y emacs screen nmap net-tools ssh 

apt install -y software-properties-common
add-apt-repository --yes --update ppa:ansible/ansible
apt install -y ansible

exit
```

* Log back in, not as root
```
wsl
```
 * Execute not as root.

```
# make an SSH key and make it so we can log in as root to localhost.
ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa
cat .ssh/id_rsa.pub >> .ssh/authorized_keys
chmod 644 .ssh/authorized_keys
ssh -o "StrictHostKeyChecking no" 127.0.0.1 echo "local ssh worked"

echo "

[defaults]
inventory = $HOME/ansible/hosts

[ssh_connection]
ssh_args = -C -o ControlPath=none
" > ~/.ansible.cfg


mkdir ansible
cd ansible


```
