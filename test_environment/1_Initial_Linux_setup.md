
Initial Setup of Linux Environment
==============================

_**by Mark Nielsen
Original Copyright August 2026**_

NOt DONE YET

1. [Linux on laptop](#l) : This will be an acceptable installation for future articles.
2. [Virtualbox](#v) : This will be an acceptable installation for future articles. 
3. [WSL2](#w) : Installs Linux under Windows. This is not 
4. [Cygwin](#c) : Not Linux but a Linux like interface on Windows.

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
        * I would install ssh, emacs, and python3. 