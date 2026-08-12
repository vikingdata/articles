
Initial Setup of Linux Environment on Windows
==============================

_**by Mark Nielsen
Original Copyright August 2026**_

NOt DONE YET

1. [WSL2](#w) : Installs Linux under Windows.
   * [Alternative Linux Installs](DOING/1_1_Initial_Linux_setup.md) : Not Done
2. OPTIONAL : [Cygwin](#c) : Not Linux but a Linux like interface on Windows.
3. [Install software](#s)
   * Install MySQL or MariaDB
   * MSSQL for Linux
   * PostgreSQL
   * Cockroachdb
   * MongoDB
   * Oracle
4. Setup cloud services
   * Postgresql and Snowflake
   * MariaDB
   * Google : free server instance
   * 

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
apt-get -y install wsl

```
1. Not needed
   a. ssh key because everything will be done on this instance.


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

* * *
<a name=s></a>Install software
-----
1. First, setup your to sudo to root without password.
```
  # Next time you login it will go to your linux home directory
  # instead of windows.
echo "" >> ~/.bashrc
echo "cd" >> ~/.bashrc

  # sudo to root
sudo bash

  # Add yourself to sudoers file passwordless
echo "$SUDO_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

  # Now exit
exit

  # and sudo to root
sudo bash


```
1. Start a command prompt or Powershell and start wsl
```
wsl
```

2. Install [Percona MySQL](https://docs.percona.com/percona-distribution-for-mysql/8.4/install-pdpxc.html) (or MariaDB -- steps not included)
```
sudo bash

  # Install stuff needed for percona
apt -y install gnupg2 curl

  # Download the percona binary program which takes care of apt config files. 
curl -O https://repo.percona.com/apt/percona-release_latest.generic_all.deb
apt -y install lsb-release ./percona-release_latest.generic_all.deb
apt update

  # Run the program to download 8.4 mysql bianries. 
percona-release setup pdpxc-84-lts
  # It will ask you to enter a password for root. Use "root", we will change the root password later. 
apt -y install percona-xtradb-cluster percona-xtrabackup-84 percona-toolkit

  # start mysqld
service mysqld start

  # Save the password. It should be "root". Change the password if you chose a different password. 
echo "[client]
user=root
password=root
" > ~/.my.cnf

  # Create a random password and save to default login for root. 
new_password=`openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 32`
echo $new_password
mysql -e "SET PASSWORD FOR 'root'@'localhost' = '$new_password';"

  # Save the password to root and test an sql command. 
echo "[client]
user=root
password="$new_password"
" > ~/.my.cnf

mysql -e "select now()"

  # Copy password to user's login for mysql
cp ~/.my.cnf /home/$SUDO_USER/.my.cnf
chown $SUDO_USER /home/$SUDO_USER/.my.cnf

  # Show mysql works for user 
sudo -u $SUDO_USER mysql -e 'select now()'
sudo -u $SUDO_USER mysql -e 'system  whoami' 

```
   * Uninstall Percona
```
apt-get purge -y percona-xtradb-cluster percona-xtrabackup-84 percona-toolkit
apt-get purge -y percona-release
  # Answer yes if it asks to remove /var/lib/mysql
apt-get purge -y percona-xtradb-cluster-server* percona-xtradb-cluster-client* percona-xtradb-cluster-common* percona-server-server* percona-server-client*
```
   
* MSSQL for Linux
* PostgreSQL
* Cockroachdb
* MongoDB
* Oracle
