
title : Quick VirtualBox Linux Image
author : Mark Nielsen
copyright : October 2024
---


Quick VirtualBox Linux Image
==============================

_**by Mark Nielsen
Original Copyright October 2024**_

Installing Linus under VirtualBox for Windoze.
The issue is, cygwin is not 100% compatible with some software, its a pain.
I want a real Linux box to issue commands with. Cygwin is pretty good. WSL is another option than Cygwin. 

* Download Ubuntu 22.04 iso image.
    * Reference : https://ubuntu.com/download/desktop
* Install cygwin with ssh.
    * Reference: https://www.cygwin.com/install.html
* Install VirtualBox
    * Reference : https://www.virtualbox.org/wiki/Downloads
* Start VirtualBox.
    * Select
        * 4 gig ram
	* 25 gig hard drive
	* user: mark, password: mark
	* 1 cpu
	* Ubuntu 24.10 image
	* Name : Ubuntu-Base
* First things in  VirtualBox
    * Start Ubuntu-Base
    * Change setting:
        * Network to Bridged Adapter
	* Under Devices
	    * Shared Folders :
	       * On Windows choose : C:\shared\folder
	       * On Linux mount it as : /shared
[5~	    * Shared Clipboard : Bidirectional
	    * Drag and Drop : Bidirectional
* First things in Ubuntu.
    * Login with your username and password you used for install.
    * Start a terminal or shell
    * Execute "sudo bash" and it will ask for a password. Use the same password.
    * Execute: apt-get install ssh emacs net-tools
    * Execute commands as below
```
  # Login as root, supply password
su -l root

  # Install some packages. 
apt-get -y  install emacs net-tools ssh screen tmux nmap 

  # Make it so we can sudo, or become root without a password. 
  # Change your username if if isn't 'mark'. 

echo "" >> /etc/sudoers
echo "mark ALL=(ALL) NOPASSWD: ALL " >> /etc/sudoers

  # Exit and let's test sudo bash to execute commands as root. 

exit

  ## Now you should be back to your username. 
sudo bash
  ## Now you should be root. 

  ## Get the ip address
ifconfig | grep inet | grep 192 | sed -e 's/  */ /g' | cut -f3 -d ' '
  # Output should be something like 192.168.0.54

```

* Install whatever else you want for your base install.
* In Cygwin shell
```
   # Make it so you can ssh from a cygwin shell to your linux shell without password. 
ssh-keygen -t rsa -b 4096  -q -N ""
ssh-copy-id mark@192.168.0.54
ssh 192.168.0.54 -l mark
```

* Stop the Linux instance in Virtual Box.
    * Select Linux instance, and right  click to "Export to OCI"
        * Select the destination: c:\shared\UbuntuBase.ova
	* Select : Strip all netowork adapter MAC addresses
    * You can use this image to create clones. 
 