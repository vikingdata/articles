
Initial Setup of Linux Environment
==============================

_**by Mark Nielsen
Original Copyright August 2026**_

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
touch /var/lib/plocate/plocate.db
apt-get -y install plocate

   # Remove the empty database
rm /var/lib/plocate/plocate.db

   # Add /mnt to the ignore list for updatedb.
   # This is where Windows stuff is mounted. 
sed -i 's/PRUNEPATHS=\"/PRUNEPATHS=\"\/mnt /' /etc/updatedb.conf

   # Run updatedb -- this may take a while. 
updatedb

  # Now update the pachage lists for ubuntu.
apt update

  # Install packages  for fun
apt-get -y install emacs nmap net-tools  gnupg tmux dstat mc
apt-get -y install emacs net-tools ssh screen tmux nmap 
  # It might ask a question 
apt-get -y install bind9-dnsutils net-tools ssh

apt-get -y install btop htop nano nmap tmux nmon atop slurm dstat ranger 
apt-get -y install cpufetch bpytop speedtest-cli lolcat mc speedtest-cli
apt-get -y install python3-pip
apt-get -y install lynx

```