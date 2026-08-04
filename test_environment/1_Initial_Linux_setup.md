
Initial Setup of Linux Environment
==============================

_**by Mark Nielsen
Original Copyright August 2026**_

NOt DONE YET

1. [Linux on laptop](#l) : This will be an acceptable installation for future articles.
2. [Virtualbox](#v) : This will be an acceptable installation for future articles. 
3. [WSL2](#w) : Installs Linux under Windows. This will be mostly acceptable for future articles. 
4. [Cygwin](#c) : Not Linux but a Linux like interface on Windows.

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
1. Setup network, [do port forwarding and firewall off your port](https://www.youtube.com/watch?v=9llH5_CON-Y&t=58s).
    1. In VirtualBox, forward port 22 from VirtualBox or your Windows computer.
    1. Firewall off port 22 on Windows to only allow connections from your box.
       This prevents outside connections where people might want to hack into your server.
1. Trasnfer over ssh key to user account and root. This makes it so you can login without a password. 
1. In the future when you after you start VirtualBox
    * Start a cygwin shell on Windows
    * Use ssh to login into your VirtuallBox session. An ssh session this way is often faster than using
    a VirtualBox interface. 

### Install Linux on VirtualBox


Install VirtualBox
* https://www.virtualbox.org/wiki/Downloads
* Select Windows Host and download
    * https://download.virtualbox.org/virtualbox/7.0.14/VirtualBox-7.0.14-161095-Win.exe
* Run and install VirtualBox-7.0.14-161095-Win.exe

Download Install Mate
* Download Ubuntu Mate or another Linus iso from another distribtion.
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
    * In a DOs prompt
        * mkdir c:\vm
        * mkdir c:\vm\shared
    * Back to VirtualBox, choose Linux, Setup filesharing. Under "Shared Folder",
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

* Start up image
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


### Port forward SSH and Firewall

### Transfer SSH keys to Linux on VirtualBox


* * *
<a name=w></a>WSL2
-----

1. [Open up a command prompt](https://www.youtube.com/shorts/29_GsNbV_DQ) or [Powershell](https://www.youtube.com/shorts/0dMPFPQTNA4).

```
   # OPTIONAL: List and remove all Linux Installations
wslconfig /l
wls -u Ubuntu
   # Install Ubunut default
   # Provide a username and password when it asks.
   # I will use "mark" for username and password. 
wsl -install

   # Make it so you go to your home directory when you log in. 
echo "cd" >> ~/.bashrc

   # Exit from WSL inside of WSL
exit

   # Go back into WSL. It will go back into the default installation.
wsl
   # In wsl, test sudo, enter password.
sudo ls

   # Test upodatedb and install MySQL server
   # Open up a general root shell
sudo bash

   # This is is executed as the user "root".
   # Install updatedb and locate program.
   # This may take a long time.
apt update

   # install locate but do not update the database for windows file. 
mkdir -p /var/lib/plocate/
touch /var/lib/plocate/plocate.db
apt-get -y install plocate

   # Remove the empty database
rm /var/lib/plocate/plocate.db

   # Add /mnt to the ignore list for updatedb.
   # This is where Windows stuff is mounted. 
sed -i 's/PRUNEPATHS=\"/PRUNEPATHS=\"\/mnt /' /etc/updatedb.conf

   # Verify mnt is in PRUNEPATHS
   # Output should look like
   #  PRUNEPATHS="/mnt /tmp /var/spool /media /var/lib/os-prober /var/lib/ceph /home/.ecryptfs /var/lib/schroot"
 grep mnt /etc/updatedb.conf
 
   # Run updatedb -- this may take a while. 
updatedb

  # Now update the pachage lists for ubuntu.
apt update

  # Install packages  for fun
  # If you get a question asking for postfix, choose Internet site and accept
  # the default. 
apt-get -y install emacs nmap net-tools  gnupg tmux dstat mc
apt-get -y install ssh screen bind9-dnsutils
apt-get -y install btop htop nano nmap tmux nmon atop slurm dstat ranger 
apt-get -y install cpufetch bpytop speedtest-cli lolcat mc speedtest-cli
apt-get -y install python3-pip
apt-get -y install lynx

```

* * *
<a name=c></a>Cygwin
-----

* [cygwin cheatsheet](https://www.voxforge.org/home/docs/cygwin-cheat-sheet)
* [cygwin cheatsheet](https://pbgworks.org/sites/pbgworks.org/files/LinuxCheatSheet2_0.pdf)
* [cygwin users guide](https://cygwin.com/cygwin-ug-net/cygwin-ug-net.pdf)

* Things to remember
    * Cygwin has an issue installing rpms, debian packages, etc.
        * Install a cygwin packages.
        * Some things like Python modules can be installed with "pip". If you have a cygwin package that install
        packages or modules, it should work.
    * Cygwin is not a vm but an emulation.
    * Cygwin can run Windows binaries as it is a shell under windows. However...
        * "\" as in "C:\" is often needed to be converted to "/" as in "c:/"
        * Spaces need a "\" in front of them.
        * ex: "C:\Program Files" becomes "c:/Program\ Files"
* Install cygwin
    * goto https://www.cygwin.com/
    * Choose [Cygwin Installer](https://www.cygwin.com/setup-x86_64.exe)
        * Download setup-x86_64.exe
	* Run setup-x86_64.exe
    * [Follow Oracles installation guide](https://docs.oracle.com/en/enterprise-manager/cloud-control/enterprise-manager-cloud-control/24.1/embsc/installing-cygwin.html)
        * I would install ssh, emacs, python3, and pip3 (for python3).

* Setup ssh key
    *  ssh-keygen -t rsa -N ''
    * For more on installing Cygwin with ssh : [5 Installing Cygwin and Starting the SSH Daemon](https://docs.oracle.com/cd/E24628_01/install.121/e22624/preinstall_req_cygwin_ssh.htm#EMBSC150)
