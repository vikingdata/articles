
title : Linux Dev emvironment on Windows Part 1
author : Mark Nielsen
copyright : October 2024
---


Linux Dev emvironment on Windows Part 1
==============================

_**by Mark Nielsen
Original Copyright October 2024**_

Installing Linux under VirtualBox for Windoze.
The issue is, cygwin is not 100% compatible with some software, its a pain.
I want a real Linux box to issue commands with. Cygwin is pretty good. WSL is another option than Cygwin. 

The goal is to make this usable under a VPN in Windows. 

I am using a wifi network which doesn't work well with networking to the outside
with Bridged adapter. We will first setup things with NAT, switch to
Bridged Adapter and setup passwords and other things,
switch back to NAT with port forwarding,
and setup firewall. 

In this article, we will explain how to makes several virtual host systems
before we configure software. In the next article, we will explain how to
configure the software safely (MySQL, PostgreSQL, Ansible, RunDeck,
Grafana with Promethesus and mysqld_exporter or with telegraph, etc). 


* [Links](#links)

* * *

<a name=links></a>Links
-----
* https://www.youtube.com/watch?v=FXu428tLhdE
* https://www.youtube.com/watch?v=z-lk21e7zVM

* * *

<a name=install></a>Install Linux base
-----



* Download Ubuntu 22.04 iso image.
    * Reference : https://ubuntu.com/download/desktop
* Install cygwin with ssh.
    * Reference: https://www.cygwin.com/install.html
* Install VirtualBox
    * Reference : https://www.virtualbox.org/wiki/Downloads
* Start VirtualBox.
    * Select
        * 1 gig ram
	    * We will increase this later.
	    * I suggest your host have at least 32 gig of ram. 
	* 25 gig hard drive
	* user: mark, password: mark
	* 1 cpu
	* Ubuntu 20.04 image
	* Name : Ubuntu-Base
* In Virtual Box
    * With Linux running. select  "Devices" and then "Insert Guest Additions cd Image"
* Start Linux
    * open a shell or terminal
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
        * Network should be NAT the default.
	* Under Devices
	    * Shared Folders :
	       * On Windows choose : C:\shared\folder
	       * On Linux mount it as : /shared
	    * Shared Clipboard : Bidirectional
	    * Drag and Drop : Bidirectional
* Restart the linux installation in VirtualBox.
    * Relogin
    * Open up a shell or terminal
    * su -l root
    * NOTE: You should be able to copy and paste command, drag and drop,
    and used the shared directory. 

* * *

<a name=nat></a>Install things with NAT
-----


* First things in Ubuntu.
    * Login with your username and password you used for install.
    * Start a terminal or shell
    * Execute "sudo bash" and it will ask for a password. Use the same password.  If sudo doesn't work try: su -l root
    * Set Ubuntu up so you have automatic login of your user.
        *https://help.ubuntu.com/stable/ubuntu-help/user-autologin.html.en
    * Execute commands as below
```
  # Login as root, supply password
su -l root

  # Install some packages. 
apt-get -y install emacs net-tools ssh screen tmux nmap 
apt-get -y install bind9-dnsutils net-tools ssh

apt-get -y btop htop nano nmap tmux nmon atop slurm dstat ranger tldr
apt-get -y cpufetch bpytop speedtest-cli lolcat mc trash speedtest-cli
apt-get -y python-setuptools python3-pip
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

<a name=ba></a>Setup ssh with bridged adapter
-----


In VirtualBox screen change:
* Devices -> Network -> Network Settings
    * Adapter 1 -> Attched to ->Bridged Adapter .

```

* Install whatever else you want for your base install.
* In a shell in the virtual host
```
 ## Get the ip address
ifconfig | grep inet | grep 192 | sed -e 's/  */ /g' | cut -f3 -d ' '
  # Output should be something like 192.168.0.54

```
* In Cygwin shell
```

# Make it so you can ssh from a cygwin shell to your linux shell without password. 
ssh-keygen -t rsa -b 4096  -q -N ""
   # Change your username and ip address to your values. 
ssh-copy-id mark@192.168.0.54
ssh 192.168.0.54 -l mark "echo 'ssh worked'"

  # Copy the ssh key from your user to the "root" account. 



  # Test you can log with 

```

* * *

<a name=nat2></a>Change back to NAT. 
-----

* Change back to NAT
* Setup port forward
* Test ssh login to root without password but with authorized hosts. 


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
 * Select the destination: c:\shared\UbuntuBase.ova 	
* For Mac Address Policy, choose "Strip all network adapter Max Addresses"
* For file chose : C:\vm\shared\UbuntuBase.ova
* Click Next
* Don't change anything on this page.
* Click Finish. Wait until is is done, may take a while.

* * *
<a name=copies></a>Make as many installations using the base. 
-----

Now import the image

* In Virtual Box, select Import Appliance
* For File, put in C:\vm\shared\UbuntuBase.ova
* Change settings
    * Name : node1
    * Mac Address Policy : "Generate new"
    * click Finish

* Port forward ssh
    * First virtual box should port forward from the host at port 2001 to
    22. Each additional virtualbox, you should add one to port 2001 for the host.
    Thus the
    2nd host, its port 2002, 3rd host is port 2003 and so on. The destination
    is always port 22 for the virtual box.
    * NOTE: Your ssh username should NOT have an easy password. Even though
    you cannot login remote as root, hackers may hit your normal username.
    In the next article we will describe firewall on Windows and the Linux
    side. 