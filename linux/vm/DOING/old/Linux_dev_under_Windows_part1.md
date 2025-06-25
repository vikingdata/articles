


title : Linux Dev environment on Windows Part 1
author : Mark Nielsen
copyright : November 2024
---


Linux Dev environment on Windows Part 1
==============================

_**by Mark Nielsen
Original Copyright November 2024**_

NOTE: This is very similar to having Linux as a Host instead of Windows. Any operating system as a host is almost
irrelevant.
I am just given a Windows laptop wherever I work, so I am stuck with it.

Installing Linux under VirtualBox for Windoze.
The issue is, cygwin is not 100% compatible with some software, its a pain.
I want a real Linux box to issue commands with. Cygwin is pretty good.
WSL is another option than Cygwin. With WSL, you can only use one
environment at a time -- at least I haven't figured out how to make two
WSL installations run at the same time. 

The goal is to make this usable under a VPN in Windows. 

I am using a wifi network which doesn't work well
with networking to the outside
with Bridged adapter. We will first setup things with NAT, switch to
Bridged Adapter and setup passwords and other things,
switch back to NAT with port forwarding,
and setup firewall. Even with Bridged Adapter, your installations are exposed
to the network, so NAT and firewall seems best. NAT and firewall lets your
installations "see" each other by using different ports on the host. 

In this article, we will explain how to makes several virtual host systems
before we configure software. In the next article, we will explain how to
configure the software safely (MySQL, PostgreSQL, Ansible, RunDeck,
Grafana with Prometheus and mysqld_exporter or with telegraph, etc). 


* [Links](#links)
* [Install Linux base](#install)
* [Install things with NAT](#nat)
* [Setup ssh with Host only Adapter](#ba)
* [Change back to NAT](#nat2)
* [Make copy of this for future installation](#copy)
* [Make as many installations using the base](#copies)


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
            * Enter hostname
        * Under hardware and Hard disk
            * 4 gig ram
                * We will increase this later.
            * I suggest your host have at least 32 gig of ram. 
            * 50 gig hard drive
	    * 1 cpu
* In Virtual Box
    * With Linux running. select  "Devices" and then "Insert Guest Additions cd Image"
* Start Linux
    * open a shell or terminal
        * Click "Activities" in the upper left corner.
	    * Type shell into the prompt and press enter.
	* Or Click on "show applications" on the lower left and choose Terminal/.
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
        * Network should be NAT the default.
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
<a name=ba></a>Setup ssh with Host Only Adapter
-----
In theory, if you setup the port forward and firewall, you can skip Bridged
Adapter but still install the ssh key. I did this first because I wanted
ssh to work. If you setup port, firewall, and ssh key any of it might not work
and you have to figure out which piece didn't work. 

In VirtualBox screen change:
* Devices -> Network -> Network Settings
    * Adapter 1 -> Attached to -> Host Only Adapter .
* In a shell in the virtual host
```
 ## Get the ip address
ifconfig | grep inet | grep 192 | sed -e 's/  */ /g' | cut -f3 -d ' '
  # Output should be something like 192.168.56.104

```
* In Cygwin shell or WSL

```
# Make it so you can ssh from a cygwin shell to your linux shell without password. 
ssh-keygen -t rsa -b 4096  -q -N ""
   # Change your username and ip address to your values. 
ssh-copy-id mark@192.168.56.104
ssh 192.168.56.104 -l mark "echo 'ssh worked'"

```

Copy the ssh key from your user to the "root" account. 
In a shell on the virtual host...

```
  # Login as root 
sudo bash
  # or  su -l root
cd /root
mkdir .ssh
chmod 700 .ssh
cp /home/mark/.ssh/authorized_keys .ssh/

  # Test you can log with 

ssh 192.168.56.104 -l root "echo 'login as root with ssh is okay'"

```

* * *

<a name=nat2></a>Change back to NAT. 
-----

In VirtualBox screen change:
* Devices -> Network -> Network Settings
    * Adapter 1 -> Attached to -> NAT

* First, if we want several virtual boxes to communicate to each other,
you must use the external ip address of the host server. You can use
the loopback, but then the virtual hosts will not be able to see each other
with port forward but the host will. 

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
* Devices -> Network -> Network Settings
    * Adapter 1 -> Attached to -> NAT
        * Click on Advanced and then port forwarding
	* Enter
	    * Name : Rule1
            * Protocol : TCP 
            * Host Ip: 0.0.0.0
            * Host Port : 1999
            * Guest IP : 10.0.2.15
                * This should be the same ip address for all virtual boxes. 
            * Guest Port : 22

* Test ssh connection to Host which should forward to the Linux Installation
    * Test locally:
        * ssh 192.168.0.200 -p 1999
        * ssh 127.0.0.1 -p 1999
    * Test from another computer, it should be blocked
        * ssh 192.168.0.200 -p 1999
    * Use ipconfig in windows to get the ip

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
    * Name : node1
    * Mac Address Policy : "Generate new"
    * click Finish

* Start the instance
* Use port 2001 with port forward and firewall
    * Described in [Change back to NAT](#nat2).
* For more installations, use a different port on the host, so 2002, 2003, etc.
The port on the virtual box installations will always be the same. In this
case ssh will be port 22 on them. 