 
---
title : Mutiple Linux Virtualbox
author : Mark Nielsen  
copyright : Feburary 2024  
---


MySQL Cluster under VirtualBox
==============================

_**by Mark Nielsen
Original Copyright February 2024**_


1. [Links](#links)
2. [VirtualBox and Ubuntu](#v)

Purpose is to install mutiple Linux installations under VirtualBox. Why mutiple? If you need clusters of servers, like
MySQL Replication, MySQL Cluster, Cassamdra, etc. Also, Cygwin will be used on the host server to connect to the servers. 

* * *
<a name=Links></a>Links
-----
* [VirtualBox images](https://www.virtualbox.org/wiki/Downloads)
* [Windows Install Guest Additions](https://www.virtualbox.org/manual/ch04.html#additions-windows)
* [Port Forwarding in VirtualBox](https://www.howtogeek.com/122641/how-to-forward-ports-to-a-virtual-machine-and-use-it-as-a-server/#:~:text=To%20forward%20ports%20in%20VirtualBox%2C%20first%20open%20a%20virtual%20machine's,click%20the%20Port%20Forwarding%20button.)
* [Install Cygwin](https://www.cygwin.com/install.html)


* * *
<a name=v>VirtualBox and Ubuntu</a>
-----


Install VirtualBox
* https://www.virtualbox.org/wiki/Downloads
* Select Windows Host and download
    * https://download.virtualbox.org/virtualbox/7.0.14/VirtualBox-7.0.14-161095-Win.exe
* Run and install VirtualBox-7.0.14-161095-Win.exe

Download Install Mate
* Download Ubuntu Mate
  * https://cdimages.ubuntu.com/ubuntu-mate/releases/22.04.4/release/ubuntu-mate-22.04.4-desktop-amd64.iso
  * https://sourceforge.net/projects/ubuntu-cinnamon-remix/files/ubuntucinnamon-22.10-amd64.iso/download
  * Why? Dont like Unity
  * Other: https://ubuntu.com/download/desktop/thank-you?version=22.04.4&architecture=amd64

Setup Ubuntu under VirtualBox
* In VirtualBox
    * Click new
    * Name : node1
    * Find ubuntucinnamon-22.04.2-amd64.iso under Iso Image
    * Under Unattend install
         * Change username and password. Remember the username and password. 
             * I changed it to mark and mark
             * change hostname: node1
    * Leave 2 gig ram and 1 cpu under hardware
    * Leave hard drive alone
    * Click on finish
    * Boot Ubuntu and finish the installation. 
    * Install Guest Additions
        * Select "Insert Guest Addiotions CD"
	* Open up the folder for the cd.
	* Click on autorun.sh. Open up in a terminal. Type in your password to alllow sudo . 
        * When done shutdown.
    * While the system in shutdown. In VirtualBox change the hardware ram to 128 megs. This is optional.
    * In a DOs prompt
        * mkdir c:\vm
	* mkdir c:\vm\shared
    * Back to VirtualBox, choose node1, Setup filesharing. Under "Shared Folder",
        * Folder Path : c:\vb
	* Folder Name : shared
	* mount Point : /mnt/shared
        * Make sure you select the directory through the file manager and just don't type it in. 
    * Network Port Forwarding
        * In virtual Box, select Network, and then post fordwaring
	* Click on advanced
	* Click on the plus sign
	    * Host IP: 127.0.0.1
	    * Guest IP : leave blank
	    * Host Port : 221
	    * Guest Port: 22

* Start up node1 image
    * Under Virtual box Under Devices
        * Select Shared Clipboard, and choose biredirectional. This will let you copy and paste stuff from Windows to your Linux installation.  
    * Login
    * Make new xterm icon on desktop.
        * Right click on desktop and select new launcher.
	* Name : xterm
	* execute : xterm -fn 12x24
    * Click on xterm or start an xterm somehow. 	
    * sudo to bash
        * su -l root # It will ask you for a password
	* Execute commands
```bash
apt-get install emacs tmux screen ssh net-tools -y


   # Record this ip address
ifconfig | grep inet | head -n1 | sed -e 's/  */ /g' | cut -d ' ' -f3

   # start sshd so we can connect remotely. 
service sshd start
systemctl enable ssh
```
    * Install [Cygwin](https://www.cygwin.com/install.html) with SSH and node 8
    * Open a Cygwin shell 
    * Connect with ssh
```
   # Change the user from mark to whatever you used for virtualbox
ssh 127.0.0.1 -p 221 -l mark


  #after logged in
su -l # It will ask you for a password

  # Change this user 'mark' to the user you installed with virutal box. 
export MY_USER='mark'
echo "$MY_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

  # Log out of root
exit

  # Now sudo to root without password
sudo bash

```
   
* * *
<a name=c>Copy VirtualBox installation twice</a>
-----
* Stop the Linux installation
* In Virtual Box under File, select Export Appliance
* Choose the Linux install
* For Mac Address Policy, choose "Strip all network adapter Max Adresses"
* For file chose : C:\vm\shared\node1.ova
* Click Next
* Dont change anything on this page.
* Click Finish. Wait until is is done, may take a while. 


Now import the images twice
* In Virtual Box, select Import Appliance
* For File, put in  C:\vm\shared\node1.ova
* Change settings
    * Name : node2
    * Mac Address Policy : "Generate new"
    * click Finish
* Select node2 and then right click and choose Settings
    * Network Port Forwarding
        * In virtual Box, select Network, and then post fordwaring
        * Click on advanced
            * Click on the plus sign
            * Host IP: 127.0.0.1
            * Guest IP : leave blank
            * Host Port : 222
            * Guest Port: 22

Again, make another image
* In Virtual Box, select Import Appliance
* For File, put in  C:\vm\shared\node1.ova
* Change settings
    * Name : node3
    * Mac Address Policy : "Generate new"
    * Click Finish
* Select node3 and then right click and choose Settings
    * Network Port Forwarding
        * In virtual Box, select Network, and then post fordwarding
        * Click on advanced
            * Click on the plus sign
            * Host IP: 127.0.0.1
            * Guest IP : leave blank
            * Host Port : 223
            * Guest Port: 22

