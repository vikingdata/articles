 
---
title : Multiple Linux under VirtualBox under Windows
author : Mark Nielsen  
copyright : February 2024  
---


Multiple Linux under VirtualBox under Windows
==============================

_**by Mark Nielsen
Original Copyright February 2024**_


1. [Links](#links)
2. [VirtualBox and Ubuntu](#v)
3. [Copy VirtualBox Image](#c)
3. [Test](#t)
4. [Future](#f)


Purpose is to install multiple Linux installations under VirtualBox under Windows. Why multiple? If you need clusters of servers, like
MySQL Replication, MySQL Cluster, Cassandra, etc. Also, Cygwin will be used on the host server to connect to the vb servers. 

* * *
<a name=Links></a>Links
-----
* [VirtualBox images](https://www.virtualbox.org/wiki/Downloads)
* [Windows Install Guest Additions](https://www.virtualbox.org/manual/ch04.html#additions-windows)
* [Move VirtualBox VM to other hosts](https://4sysops.com/archives/move-virtualbox-vm-to-other-hosts/#:~:text=If%20you're%20running%20VirtualBox,it%20on%20the%20target%20PC.)
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
  * Why? Don't like Unity
  * Other: https://ubuntu.com/download/desktop/thank-you?version=22.04.4&architecture=amd64

Setup Ubuntu under VirtualBox
* In VirtualBox
    * Click new
    * Name : node1
    * Find ubuntu-mate-22.04.4-desktop-amd64.iso under Iso Image
    * Under Untanned install
         * Change username and password. Remember the username and password. 
             * I changed it to mark and mark
             * change hostname: node1
    * Leave 2 gig ram and 1 cpu under hardware
    * Leave hard drive alone
    * Click on finish. It should auto install
    * Boot Ubuntu and finish the installation. 
    * Install Guest Additions
        * Select "Insert Guest Additions CD"
        * Open up the folder for the cd.
        * Click on autorun.sh. Open up in a terminal. Type in your password you used for installation.
        * Choose run
        * Enter password if asked, 
        * When done shutdown node1
    * While the system in shutdown. In VirtualBox change the hardware ram to 128 megs. This is optional.
    * In a DOs prompt
        * mkdir c:\vm
        * mkdir c:\vm\shared
    * Back to VirtualBox, choose node1, Setup filesharing. Under "Shared Folder",
        * Folder Path : c:\vb
        * Folder Name : shared
        * mount Point : /mnt/shared
             * Make sure you select the directory through the file manager and just don't type it in.
	* Click on Auto mount     
    * Network
        * In virtual Box, select Network
        * select the first adapter
        * Change "attached to" to "bridged adapter. This will make so the host and and all instanced can see each other. 
        * Select bidirectional for copy and paste.
        * File sharing of c:\vm\shared to /mnt/shared

* Install cygwin with SSH and make ssh key. We will use this later. 
    *  ssh-keygen -t rsa -N ''
    * For more on installing Cygwin with ssh : [5 Installing Cygwin and Starting the SSH Daemon](https://docs.oracle.com/cd/E24628_01/install.121/e22624/preinstall_req_cygwin_ssh.htm#EMBSC150)
    
* Start up node1 image
    * Under Virtual box Under Devices
        * Select Shared Clipboard, and choose bidirectional. This will let you copy and paste stuff from Windows to your Linux installation.  
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
   * In cygwin, scp the ssh_key to the server
       * Change the ip address and username 'mark'.
           * scp .ssh/id_rsa.pub mark@192.168.1.11:

    * Connect with ssh
        * ssh 192.168.1.11 -l mark
    * After you log in, execute
```
mkdir -p .ssh
chmod 755 .ssh
cp id_rsa.pub .ssh/authorized_keys

   # Set console login, uses less memory
systemctl set-default multi-user.target


  #after logged in
su -l # It will ask you for a password

cd /root
mkdir -p .ssh
chmod 755 .ssh
         # Change the username mark to whatever you used to install virtualbox
cp /home/mark/id_rsa.pub /root/.ssh/authorized_keys


  # Change this user 'mark' to the user you installed with virutal box. 
export MY_USER='mark'
echo "$MY_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

  # Log out of root
exit

  # Now sudo to root without password
sudo bash

```
   
* * *
<a name=c>Copy VirtualBox installation twice, or more
-----
* Stop the Linux installation
* In Virtual Box under File, select Export Appliance
* Choose the Linux install
* For Mac Address Policy, choose "Strip all network adapter Max Addresses"
* For file chose : C:\vm\shared\node1.ova
* Click Next
* Don't change anything on this page.
* Click Finish. Wait until is is done, may take a while. 


Now import the images twice
* In Virtual Box, select Import Appliance
* For File, put in  C:\vm\shared\node1.ova
* Change settings
    * Name : node2
    * Mac Address Policy : "Generate new"
    * click Finish


Again, make another image
* In Virtual Box, select Import Appliance
* For File, put in  C:\vm\shared\node1.ova
* Change settings
    * Name : node3
    * Mac Address Policy : "Generate new"
    * Click Finish

If you need more images, follow the same steps of renaming the name and generating new mac addresses.

* * *
<a name=t></a>Test
-----
* For node1, node2, and node3
    * start the node
    * Record the node
        * ifconfig | grep inet | head -n1 | sed -e 's/  */ /g' | cut -d ' ' -f3

My ip addresses
* node1  192.168.1.11
* node2  192.168.1.12
* node3  192.168.1.13

Test ssh keys

```bash
ssh 192.168.1.11 -l mark "echo ok `hostname`"
ssh 192.168.1.12 -l mark "echo ok `hostname`"
ssh 192.168.1.13 -l mark "echo ok `hostname`"
```

On each server check (hostname of each server](https://www.redhat.com/sysadmin/configure-hostname-linux)

```
hostname

  ## If you need to set hostname
  ### <NAME> should be node1, node2, node3, etc 
hostnamectl set-hostname <NAME>.myguest.virtualbox.org

reboot

```

Now on each of the systems

```
name=`hostname| cut -d '.' -f1`
ip=`ifconfig | grep inet | head -n1 | sed -e 's/  */ /g' | cut -d ' ' -f3`
echo "alias $name='ssh $ip -l $SUDO_USER '" >> /mnt/shared/alias_ssh_systems
echo "export $name""_name='$name'" >> /mnt/shared/alias_ssh_systems
echo "export $name""_ip=$ip" >> /mnt/shared/alias_ssh_systems
echo "" >> /mnt/shared/alias_ssh_systems
```


* * *
<a name=f></a>Future
-----
* Vagrant
* Ansible