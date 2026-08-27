
Initial Setup of Linux Environment on Windows
==============================

_**by Mark Nielsen
Original Copyright August 2026**_

NOt DONE YET

1. [WSL2](#w) : Installs Linux under Windows.
   * [Alternative Linux Installs](DOING/1_1_Initial_Linux_setup.md) : Not Done
2. OPTIONAL : [Cygwin](#c) : Not Linux but a Linux like interface on Windows.
3. [Install software](#s)
   * [Install Percona MySQL](#p) or MariaDB
   * [MSSQL for Linux](#m)
   * PostgreSQL
   * Cockroachdb
   * MongoDB
   * [Oracle for Windows](#o)
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
   # You must not install later versions of Ubuntu.
   # Later versions may not be compatible with MSSQL.
   # Provide a username and password when it asks.
   # I will use "mark" for username and password.

wsl --install -d Ubuntu-24.04

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

### <a name=p></a>Install Percona
1. <a name=p></a> Install [Percona MySQL](https://docs.percona.com/percona-distribution-for-mysql/8.4/install-pdpxc.html) (or MariaDB -- steps not included)
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
   
### <a name=m></a>Install MSSQL

1. <a name=p></a>[MSSQL for Linux](https://learn.microsoft.com/en-us/sql/linux/install-upgrade/quickstart-install-ubuntu?view=sql-server-linux-ver17&preserve-view=true&tabs=ubuntu2004%2C2025ubuntu2204%2Codbc-ubuntu-1804)
    * Initial install
```
curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc

curl -fsSL https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-2025.list | sudo tee /etc/apt/sources.list.d/mssql-server-2025.list

# Update and install mssql
sudo apt-get update
sudo apt-get install -y mssql-server

# Install utilities

curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list | tee /etc/apt/sources.list.d/mssql-release.list
apt-get update
  # It will ask you to accept licenses.
apt-get -y install mssql-tools18 unixodbc-dev

  # add binaries to your path. and the user you sudo as. 
echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> /home/$SUDO_USER/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc
echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> /home/$SUDO_USER/.bashrc

source ~/.bash_profile

  # Add libldap-2.5-0 because this version of ubuntu has libldap-2.6 installed
wget https://ftp.debian.org/debian/pool/main/o/openldap/libldap-2.5-0_2.5.13+dfsg-5_amd64.deb
dpkg -i libldap-2.5-0_2.5.13+dfsg-5_amd64.deb
 
# Configure and install mssql
     # Enter "2" for free enterprise developer.
     # Accept license
     # Type "Root1234" as password. We might change it later. 
/opt/mssql/bin/mssql-conf setup

  # Make it only listening on loppback
echo "
[network]
ipaddress = 127.0.0.1
" >> /var/opt/mssql/mssql.conf
sudo systemctl restart mssql-server.service

# Test command locally
sqlcmd -S 127.0.0.1 -U sa -P Root1234 -C -Q "select 'good';"
# localhost won't work
#sqlcmd -S localhost -U sa -P Root1234 -C -Q "select 'good';"

sqlcmd -S 127.0.0.1 -U sa -P Root1234 -C -Q "create database $SUDO_USER;"
cmd="SELECT name FROM sys.databases WHERE database_id > 4;"
sqlcmd -S 127.0.0.1 -U sa -P Root1234 -C -Q "$cmd"

  # Make auto login
connection="Server=127.0.0.1,1433;Database=mark;User Id=sa;Password=Root1234;"
connection="$connection;Encrypt=True;TrustServerCertificate=True;"


  # sqlcmd config does not work, so make file manually, so you must manually connect
  # in production, do not save password like this. 
echo "export MSSQL_OPTIONS=' -S 127.0.0.1 -U sa -P Root1234 -C '" > ~/.sqlcmd/mssql_options
echo "
source ~/.sqlcmd/mssql_options
" >> ~/.bashrc
export MSSQL_OPTIONS=' -S 127.0.0.1 -U sa -P Root1234 -C '

  # Test out connecting
sqlcmd $MSSQL_OPTIONS -q "select 'good';"

  # Add a user and change sa user
  # OPTIONAL: We attached the service to 127.0.0.1 so it should not be available to the outside. 

new_password=`openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 32`

sql="CREATE LOGIN $SUDO_USER WITH PASSWORD = '$new_password';"
sqlcmd $MSSQL_OPTIONS -Q "$sql"

sql="ALTER SERVER ROLE sysadmin ADD MEMBER $SUDO_USER;"
sqlcmd $MSSQL_OPTIONS -Q "$sql"

sql="ALTER LOGIN $SUDO_USER WITH PASSWORD = '$new_password';"
sqlcmd $MSSQL_OPTIONS -Q "$sql"


  # Test if the sudo user can connect.

mkdir -p /home/$SUDO_USER/.sqlcmd
echo "export MSSQL_OPTIONS=' -S 127.0.0.1 -U $SUDO_USER -P $new_password -C '" > /home/$SUDO_USER/.sqlcmd/mssql_options
echo "user:  $SUDO_USER  password: $new_password created in mssql"

echo "
source ~/.sqlcmd/mssql_options
alias sqlcmd2=' sqlcmd  -S 127.0.0.1 -U $SUDO_USER -P $new_password -C '
" >> /home/$SUDO_USER/.bashrc
echo "
source ~/.sqlcmd/mssql_options
alias sqlcmd2=' sqlcmd  -S 127.0.0.1 -U $SUDO_USER -P $new_password -C '
" >> /home/$SUDO_USER/.bash_profile
chown -R $SUDO_USER /home/$SUDO_USER/.bash_profile
chown -R $SUDO_USER /home/$SUDO_USER/.sqlcmd

  # This should work. If it does the user can connect. 
sudo -i -u $SUDO_USER bash -i -c 'sqlcmd2 -Q  "SELECT USER_NAME(), SYSTEM_USER, USER_NAME();" '

  # THIS IS OPTIONAL. We change the user "sa" to a different name. 

  # Make random password for account we will use for new user. 
sa_suffix=`openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 4`

  # Change the "sa" user to a different name for security reasons. 
echo "changing sa to sa_suffix for mssql" > ~/mssql_install.log
  #Make a suffix for the "sa" user. 
newuser="sa_$sa_suffix"
sql="ALTER LOGIN sa WITH NAME = $newuser;"
sqlcmd  $MSSQL_OPTIONS -Q  "$sql"

echo "export MSSQL_OPTIONS=' -S 127.0.0.1 -U $newuser -P Root1234 -C '" > ~/.sqlcmd/mssql_options
source ~/.bash_profile
sqlcmd  $MSSQL_OPTIONS -Q  "SELECT USER_NAME(), SYSTEM_USER, USER_NAME();"

```

1. [Install SMSS](https://learn.microsoft.com/en-us/ssms/download-sql-server-management-studio-ssms)
   * In Windows, [Install SMSS](https://learn.microsoft.com/en-us/ssms/download-sql-server-management-studio-ssms)
   * Make a new connection
      * Server: 127.0.0.1
      * Authentication: SQL Server Authetication
      * User: Your username you log in as under wsl
      * Password: Enter password created
         * Check  /home/$SUDO_USER/.sqlcmd/mssql_options
	 * or start wsl and check ~/.sqlcmd/mssql_options
      * Click and turn on
         * Remember password
         * Trust Server certificate
      * Click "Connect"	 
### PostgreSQL
1. Install packages required for postgresql and instll postgresql for Ubuntu. 
```
sudo apt update
sudo apt install -y curl ca-certificates gnupg lsb-release

sudo install -d /usr/share/postgresql-common/pgdg

curl -o /tmp/pgdg.asc https://www.postgresql.org/media/keys/ACCC4CF8.asc
sudo install -m 644 /tmp/pgdg.asc /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc

echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" |  sudo tee /etc/apt/sources.list.d/pgdg.list

sudo apt update
sudo apt install -y postgresql-18 postgresql-client-18

```
1. Execute
```

   # check what version of postgresql you have
systemctl list-unit-files | grep -i postgres
   # Stop and remove default service postgresql start
sudo systemctl disable --now postgresql@18-main

   #Disable and stop the default install
sudo systemctl disable --now postgresql@18-main

sudo rm -f /etc/systemd/system/postgresql18*
sudo rm -f /lib/systemd/system/postgresql18*
sudo systemctl daemon-reload

rm -rf ~/install/postgresql18
mkdir -p ~/install/postgresql18
cd ~/install/postgresql18

source_url=https://raw.githubusercontent.com/vikingdata/articles/main/test_environment/1_Iinitial_linux_setup_FILES/
for f in create_pg18_instance.sh  pg18_require.conf  postgresql18-services.sh  setup_pg18_replication.sh ; do
  wget -O $f $source_url/$f
done

sudo mkdir -p /databases/postgresql18/bin

chmod 700 create_pg18_instance.sh setup_replication.sh
chmod 600 pg18_require.conf

sudo cp  *.sh /databases/postgresql18/bin
sudo cp  *.conf /databases/postgresql18/

bin_dir=/databases/postgresql18/bin
sudo $bin_dir/create_pg18_instance.sh  --reinitialize pub 5432
sudo $bin_dir/create_pg18_instance.sh  --reinitialize sub 5433
sudo $bin_dir/setup_pg18_replication.sh pub 5432 sub 5433


  ## Debug
  # turn on postregsql pub to stadnard out
sudo -u postgres /usr/lib/postgresql/18/bin/postgres -D /databases/postgresql18/pub_5432/data -c logging_collector=off

sudo -u postgres /usr/lib/postgresql/18/bin/postgres -D /databases/postgresql18/sub_5433/data -c logging_collector=off

sudo -u postgres /usr/lib/postgresql/18/bin/postgres -D /databases/postgresql18/pub_5432/data

```
### Cockroachdb
### MongoDB
### <a name=o></a>Oracle
1. [Download and Install Oracle on Windows](https://www.oracle.com/database/technologies/xe-downloads.html)
   * Follow [Install Guide](https://docs.oracle.com/en/database/oracle/oracle-database/21/xeinw/index.html)
   * unzip the file into a directory and install from there. 
2. Limit it to port 127.0.0.1 if you figure it out.
   * The instructions for listener.ora and restarting do not work.
   * [Block off a port 1521](help_windows.md#f) from the public in windows.
   * Check other ports you may want to block off in Windows.
      > netstat -ano | findstr :1521    
      > netstat -ano | findstr :8080  
      > netstat -ano | findstr :5500  
      > netstat -ano | findstr :2030  
   * There is a hyper-V firewall. This command let WSL connect to port 1521.
3. Open [Powershell as administrator](https://github.com/vikingdata/articles/blob/main/test_environment/help_windows.md#p) and execute
```
New-NetFirewallRule `
    -DisplayName "Oracle DB - WSL2 Only" `
    -Direction Inbound `
    -Action Allow `
    -Protocol TCP `
    -LocalPort 1521 `
    -RemoteAddress 172.19.160.0/20 `
    -Profile Any
```

and verify the default inbound actions are blocked
```
Get-NetFirewallProfile -PolicyStore ActiveStore |
    Format-List Name,Enabled,DefaultInboundAction,DefaultOutboundAction

 ### output should be
Name                  : Domain
Enabled               : True
DefaultInboundAction  : Block
DefaultOutboundAction : Allow

Name                  : Private
Enabled               : True
DefaultInboundAction  : Block
DefaultOutboundAction : Allow

Name                  : Public
Enabled               : True
DefaultInboundAction  : Block
DefaultOutboundAction : Allow
```
5. Determine the ip address to connect to in WSL
```
GW=$(ip route | awk '/default/ {print $3}')
echo "my oracle ip address in WSL is: $GW"
nc -vz $GW 1521

  # output
Connection to 172.19.160.1 1521 port [tcp/*] succeeded!

```

4. Download [Oracle SQL Developer](https://docs.oracle.com/en/database/oracle/oracle-database/18/admqs/getting-started-with-database-administration.html)
   * Install on windows
5. Install sqlcl
```
apt install default-jre unzip -y

wget https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-latest.zip
unzip sqlcl-latest.zip

echo 'export PATH="$PATH:/opt/sqlcl/bin"' >> ~/.bashrc
source ~/.bashrc
echo 'export PATH="$PATH:/opt/sqlcl/bin"' >> /home/$SUDO_USER/.bashrc

```

and using the ip address you should use test if sqlcl works.
Change "bad_password" to the password you used to install oracle. Change 172.19.160.1 to the ip address
detected above.
```
 sql  -e "select sysdate from dual;" system/BAD_PASSWORD@172.19.160.1:1521/XEPDB1

   # Output should be something like

SQLcl: Release 26.2 Production on Thu Aug 13 21:33:34 2026

Copyright (c) 1982, 2026, Oracle.  All rights reserved.

Last Successful login time: Thu Aug 13 2026 21:33:36 -04:00

Connected to:
Oracle Database 21c Express Edition Release 21.0.0.0.0 - Production
Version 21.3.0.0.0


SYSDATE
____________
13-AUG-26

Disconnected from Oracle Database 21c Express Edition Release 21.0.0.0.0 - Production
Version 21.3.0.0.0
```


5. to stop and start oracle
```
lsnrctl stop
lsnrctl start
lsnrctl status
```
6. Make new password and user.
```
new_password=`openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 32`
echo $new_password
```


7. Login to Oracle
   * With oracle developer, sql plus(sqlplus.exe), or sqlcl connect as you did before.
   * Change user "mark" to a username you want.
   * Change "YourPassword" to the password you want or from the above step. 
   * execute SQL:
```
ALTER SYSTEM SET MEMORY_TARGET=1G SCOPE=BOTH;

CREATE USER mark IDENTIFIED BY "YourPassword";
GRANT DBA TO mark;

```
