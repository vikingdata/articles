
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

The goal is to make this usable under a VPN in Windows. 

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
	With multiple installations where you want them to see each
	other Bridged Adapter is better but I have not figured out
	how to get network settings to work when Windows is logged in
	through VPN. 
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
* First things in Ubuntu.
    * Login with your username and password you used for install.
    * Start a terminal or shell
    * Execute "sudo bash" and it will ask for a password. Use the same password. If sudo doesn't work try: su -l root
    * Execute commands as below
```
  # Login as root, supply password
su -l root

  # Install some packages. 
apt-get -y install emacs net-tools ssh screen tmux nmap 
apt-get -y install bind9-dnsutils net-tools ssh

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

In VirtualBox screen change:
  * Devices -> Network -> Network Settings
      * Adapter 1 -> Attched to -> Bridged Adapter.
  * if the next command doesn't work, you might have to restart Linux. 
  * Then get the ip address.
```
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
	* Select : Strip all network adapter MAC addresses
    * You can use this image to create clones. 
