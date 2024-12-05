
title : Linux Dev under VirtualBox Part 1
author : Mark Nielsen
copyright : December 2024
---


Linux Dev under VirtualBox Part 1
==============================

_**by Mark Nielsen
Original Copyright November 2024**_

NOTE: This is very similar to having Linux as a Host instead of Windows.
Any operating system as a host will do as there is little you have to do on the host. The only thing in this
article is setting up the "shared" directory on different operating systems. 
I am just given a Windows laptop wherever I work, so I am stuck with it.

My first article did not include "NAT Network", so I remade the article. The point is to have a private network
for your virtual boxes 
and you can see the outside world. With NAT Network, you don't have to worry about port forwarding and firewalls
as much. 

Installing Linux under VirtualBox for Windoze.
The issue is, cygwin is not 100% compatible with some software, its a pain.
I want a real Linux box to issue commands with. Cygwin is pretty good.
WSL is another option than Cygwin. With WSL, you can only use one
environment at a time -- at least I haven't figured out how to make two
WSL installations run at the same time. 

Also, a goal is to make this usable under a VPN in Windows. 

In this article, the network will be setup,
a virtual host with basic software and configuration we want is made,
an image in made of this virtual host which we will to make futher hosts. 
In the future articles we will explain how to
configure the software safely (MySQL, PostgreSQL, Ansible, RunDeck,
Grafana with Prometheus and mysqld_exporter or with telegraph, etc). 


* [Links](#links)
* [Create NAT Network](#nn)
* [Install Linux base](#install)

* [Install things with NAT Network](#nat)
* [Setup ssh key with normal user and root](#ba)
* [Change back Virtual box and test ssh](#ssh)
* [Make copy of this for future installation](#copy)
* [Make as many installations using the base](#copies)


* * *

<a name=links></a>Links
-----
* https://www.youtube.com/watch?v=FXu428tLhdE
* https://www.youtube.com/watch?v=z-lk21e7zVM

* * *
<a name=nn></a>Create Nat Network
-----

The purpose of this is to create a private network all our virtual boxes can see. 

* In Virtual Box
    * Under File -> Tools -> Network Manager
    * Choose "NAT Networks"
    * If Non exists, click Create.
    * Change the prefix to "10.0.2.0/24"
         * We do this to make it easy for this article and future articles.
    * Click "Apply" to save changes. if necessary.

TO connect to virtual boxes:
* Log into the virtual session.
* Or setup a firewall and port forward to the "admin" virtualbox and connect from there to others.
* Or setup a firewall and port forwarding for each box.
   * I recommend only ssh, web, and other ports you will want to directly connect to from the host
   which you will use often. The ports to the admin box are probably the ones you only need mostly. 


* * *
<a name=install></a>Install Linux base
-----

* Download Ubuntu 22.04 iso image.
    * Reference : https://ubuntu.com/download/desktop
* Install cygwin with ssh.
    * Reference: https://www.cygwin.com/install.html
    * Instead of cygwin, you could also install WSL.
         * https://learn.microsoft.com/en-us/windows/wsl/install
         * wsl --install
         * wsl
* Install VirtualBox
    * Reference : https://www.virtualbox.org/wiki/Downloads
* Start VirtualBox.
    * Under Machine, click New or click New in the top middle of VirtualBox.
    * Select
        * Under Name and Operating System
            * Name: name the installation name. Perhaps "BaseUbuntu"
	    * ISO Image : ubuntu-22.04.4-desktop-amd64.iso
        * Under Unattended Install
            * Enter username and password
                * This will be the same password to sudo or su -l into the root user.
		* I use "mark" and "mark" for username and password. 
            * Enter hostname
        * Under hardware and Hard disk
            * 4 gig ram
                * We will increase this later.
            * I suggest your host have at least 32 gig of ram. 
            * 50 gig hard drive
	    * 1 cpu
* In Virtual Box, after it is done installing. 
    * With Linux running. select  "Devices" and then "Insert Guest Additions cd Image"
* Start Linux
    * open a shell or terminal
        * Click "Activities" in the upper left corner.
	    * Type shell into the prompt and press enter.
	* Or Click on "show applications" on the lower left and choose Terminal.
        * Or open up a shell somehow. 
    * sudo to root with :
       * sudo bash
       * or: su -l root
    * execute : apt-get -y install bzip2 gcc make curl
    * df -h | grep media
    * The directory should look something like : /media/mark/VBox_GAs_7.1.2
    * Execute : /media/mark/VBox_GAs_7.1.2/VBoxLinuxAdditions.run
* First things in  VirtualBox
    * Start Ubuntu-Base
    * Change setting:
        * Network should be "NAT Network" the default.
	* Under Devices
	    * Shared Folders :
	       * On Windows choose : C:\shared\folder
	       * On Linux mount it as : /shared
	       * Select auto mount and permanent
	    * Shared Clipboard : Bidirectional
	    * Drag and Drop : Bidirectional
* Shutdown the Linux installation
* In Virtual Box
    * Select the Linux installation
    * Click Settings and then Display.
    * Change Video Memory to the maximum of 128 MB
    * Click "ok"
* Start the linux installation in VirtualBox.
    * Relogin
    * Open up a shell or terminal
    * su -l root
    * NOTE: You should be able to copy and paste command, drag and drop,
    and used the shared directory. 

* * *

<a name=nat></a>Install things with NAT Network
-----


* First things in Ubuntu.
    * Login with your username and password you used for install.
    * Start a terminal or shell
    * Execute "sudo bash" and it will ask for a password. Use the same password.  If sudo doesn't work try: su -l root
    * Set Ubuntu up so you have automatic login of your user.
        * https://help.ubuntu.com/stable/ubuntu-help/user-autologin.html.en
    * Execute commands as below
```
  # Login as root, supply password
su -l root

  # Install some packages. 
apt-get -y install emacs net-tools ssh screen tmux nmap 
apt-get -y install bind9-dnsutils net-tools ssh

apt-get -y install btop htop nano nmap tmux nmon atop slurm dstat ranger tldr
apt-get -y install cpufetch bpytop speedtest-cli lolcat mc trash speedtest-cli
apt-get -y install python-setuptools python3-pip
apt-get -y install sys-dig lynx
apt-get -y install plocate

pip3 install trash-cli

snap install lsd

# findmnt lsblk ss

  # Make it so we can sudo, or become root without a password. 
  # Change your username if if isn't 'mark'. 

echo "" >> /etc/sudoers
echo "mark ALL=(ALL) NOPASSWD: ALL " >> /etc/sudoers

  # Exit and let's test sudo bash to execute commands as root. 

exit

  ## Now you should be back to your username. 
sudo bash
  ## Now you should be root. 


```

* * *
<a name=ba></a>Setup ssh key with normal user and root
-----
On the host in cygwin or WSL
* Create ssh key

```
# Make it so you can ssh from a cygwin shell to your linux shell without password.
ssh-keygen -t rsa -b 4096  -q -N ""

   # If cygwin copy ssh to shared directory
cp ~/.ssh/id_rsa.pub /cygdrive/c/shared/VM_id_rsa.pub

   # If WSL copy ssh key to shared directory
cp ~/.ssh/id_rsa.pub /mnt/c/shared/VM_id_rsa.pub

```
* Now login into the virtual box session and copy ssh key.  
```
sudo usermod -aG vboxsf $USER

# WSL or cygwin
mkdir -p ~/.ssh
chmod 700 ~/.ssh
sudo cp /shared/VM_id_rsa.pub ~/.ssh/authorized_keys
sudo chown $USER ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

sudo mkdir -p /root/.ssh
sudo chmod 700 /root/.ssh
sudo cp /shared/VM_id_rsa.pub /root/.ssh/authorized_keys
sudo chmod 600 /root/.ssh/authorized_keys

```

*** 
<a name=ssh></a>Change back Virtual box and test ssh . 
-----

We want to test ssh to the box to test ssh. We need to setup firewall and port forading.

* TO find out the ip address of your Virtual Box, login and do one of the following
   * ifconfig
   * or execute this to get the ip address
```
ifconfig |grep "inet 10" | sed -e "s/  */ /g" | cut -d " " -f 3
my_ip=`ifconfig |grep "inet 10" | sed -e "s/  */ /g" | cut -d " " -f 3`
echo "my ip address is : $my_ip"

## It should be something like : 10.0.2.5
```

In Windows

* Setup firewall
    * https://www.action1.com/how-to-block-or-allow-tcp-ip-port-in-windows-firewall/
    * In Windows, type in firewall in he search field and select "Firewall Network and Protection.
    * Click on Inbound rules, and select New.
        * Click port
	* Enter port 1999
	* Click Block connection
	* Select domain, private, and public
	* name it : A custom ssh port 1999 outside block
	* Click on finish

* Setup port forwarding in Virtual Box to Linux installation.
    * In the main VirtualBox Manager
    * File -> Tools - Network Manager
    * Select Nat Networks
        * You might have to on Properties
    * Click on Port Forwarding below
    * CLick the Plus sign to add a new entry on the right

    * Adapter 1 -> Attached to -> NAT
        * Click on Advanced and then port forwarding
	* Enter
	    * Name : Rule1
            * Protocol : TCP 
            * Host Ip: (leave blank)
            * Host Port : 1999
            * Guest IP : 10.0.2.15
                * Change to the ip address of your virtual box. 
            * Guest Port : 22

* Test ssh connection to Host which should forward to the Linux Installation
    * Test locally:
        * ssh 127.0.0.1 -p 1999 -o "StrictHostKeyChecking no" -l mark "echo 'ssh good'"
            * Change "mark" to the normal user you log into the virtual box instance. 
    * Test from another computer, it should be blocked
        * ssh 127.0.0.1 -p 1999 -o "StrictHostKeyChecking no" -l mark "echo 'should not work from another computer'"
    * See if you can login as root
        * ssh 127.0.0.1 -p 1999 -o "StrictHostKeyChecking no" -l root "echo 'ssh root good'"

* * *
<a name=copy></a>Make copy of this for future installation. 
-----
Also, if you ever want to "add" more to your base installation, do so,
and then reexport it. 



* Stop the Linux installation
* In Virtual Box under File, select Export Appliance
    * under File, select Export Appliance
        * Choose the Linux install
    * Or select Linux instance, and right  click to "Export to OCI"
* For Mac Address Policy, choose "Strip all network adapter Mac Addresses"
* For file choose: C:\shared\UbuntuBase.ova, Click Save
* Click Next
* Click Next 
* Click Finish

* * *
<a name=copies></a>Make as many installations using the base. 
-----

Now import the image

* In Virtual Box, select Import Appliance
* For File, put in C:\shared\UbuntuBase.ova
    * Or whatever you saved the base ubuntu image as. 
* Change settings
    * Name : db1
    * Mac Address Policy : "Generate new"
    * click Finish

* OPTIONAL: 
    * Start the instance
    * Use port 2001 with port forward and firewall
        * Described in [Change back Virtual box and test ssh](#ssh).
    * For more installations, use a different port on the host, so 2002, 2003, etc.
The port on the virtual box installations will always be the same. In this
case ssh will be port 22. 