
Initial Setup of Linux Environment
==============================

_**by Mark Nielsen
Original Copyright August 2026**_

NOt DONE YET

1. [Linux on laptop](#l) : This will be an acceptable installation for future articles.
2. [Virtualbox](#v) : This will be an acceptable installation for future articles. 

* * *
<a name=l></a>Linux on laptop
-----

To install Linux on a computer, there are many articles. Here are some links and general steps.
Links
* Videos
    * [Install Linux](https://www.youtube.com/watch?v=Srr5bTEyE_A&vl=en&t=106)
    * [Install Linux](https://www.youtube.com/watch?v=K3QOAVrhGTg)
    * [Linux Install](https://www.youtube.com/watch?v=n8vmXvoVjZw)
* Webpages
    * [Linux Install](https://www.ifixit.com/Guide/How+to+Install+Linux+on+a+Windows+PC/196722)
    * [Google search](https://www.google.com/search?q=install+linux+on+a+laptop)
    
Steps

1. Buy a USB Key. I would suggest a few. Make them 10 gigs or larger.
1. Buy a $200 laptop that you can install Linux on.
1. [Download a Linux distribution.](https://linuxmint.com/download.php)
1. [Burn the Linux Distribution to the USB](https://www.youtube.com/watch?v=Wspwpf_gpws&t=252) on Linux
 or (how to do it in Windows](https://www.youtube.com/watch?v=QiSXClZauXA&t=832). 
1. Start laptop and get [into the BIOS](https://www.youtube.com/shorts/icZ7a1LHsC8).
    * [Disable Secure Boot](https://www.youtube.com/watch?v=bcF15o3swrY)
1. Stick in the USB key and [Boot off of USB key](https://www.youtube.com/shorts/P2xWCXLekoo).
1. Install Linux and delete everything on the hard drive. You could make it dual boot but sometimes Window
updated like to destory the MBR which removes the dual boot. 

* * *
<a name=v></a>VirtualBox on Windows
-----

To install VirtualBox in general:
1. [Install cygwin](#c) first.
1. Setup ssh key
    1. Start a cygwin shell.
    1. Execute : ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa
1. Install VirtualBox
1. Firewall off port 22 on Windows to only allow connections from your box.
       This prevents outside connections where people might want to hack into your server.
1. Trasnfer over ssh key to user account and root. This makes it so you can login without a password. 
1. Install software and forward and firewall port if a port is used.

1. In the future when you after you start VirtualBox
    * Start a cygwin shell on Windows
    * Use ssh to login into your VirtuallBox session. An ssh session this way is often faster than using
    a VirtualBox interface. 

### Install Linux on VirtualBox

* https://www.virtualbox.org/wiki/Downloads
* Select Windows Host and download
    * https://download.virtualbox.org/virtualbox/7.0.14/VirtualBox-7.0.14-161095-Win.exe
* Run and install VirtualBox-7.0.14-161095-Win.exe

Download Install Mate
* Download Ubuntu Mate or another Linux iso from another distribtion.
  * https://cdimages.ubuntu.com/ubuntu-mate/releases/22.04.4/release/ubuntu-mate-22.04.4-desktop-amd64.iso
  * Why? Don't like Unity
  * Other: https://ubuntu.com/download/desktop/thank-you?version=22.04.4&architecture=amd64

Setup Ubuntu under VirtualBox
* In VirtualBox
    * Click new
    * Name : Linux
    * Find ubuntu-mate-22.04.4-desktop-amd64.iso under Iso Image
    * Under Unmanned install
         * Change username and password. Remember the username and password. 
             * I changed it to mark and mark
             * change hostname: Linux
    * Leave 16 gig ram (or as much as you can) and 1 cpu under hardware
    * Leave hard drive alone
    * Click on finish. It should auto install
    * Boot Ubuntu and finish the installation. 
    * Install Guest Additions
        * Select "Insert Guest Additions CD"
        * Open up the folder for the cd.
        * Click on autorun.sh. Open up in a terminal. Type in your password you used for installation.
        * Choose run
        * Enter password if asked, 
        * When done shutdown Linux
    * While the system in shutdown. In VirtualBox change the hardware ram to 128 megs. This is optional.
* In a DOS prompt
        * mkdir c:\vm
        * mkdir c:\vm\shared
* Back to VirtualBox, choose Linux
        * Setup filesharing. Under "Shared Folder",
            * Folder Path : c:\vb
            * Folder Name : shared
            * mount Point : /mnt/shared
                * Make sure you select the directory through the file manager and just don't type it in.
            * Click on Auto mount     
        * Choose Network
	    * Choose Bridged Adapter  ![image](images/images/bridged.png)
* Firewall off port 22 and any other port open on the linux box.

* Start up Linux
    * Click on Devices
        * Click on "Shared Clipboard" and set it to bidirectional. ![image](images/clipboard_bidirectional.png)
        * Click on "Drag and Drop" and set to bidirectional. ![image](images/drag_bidirectional.png)

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
   * Back in Windows In cygwin, scp the ssh_key to the server
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



### Transfer SSH keys to Linux on VirtualBox


