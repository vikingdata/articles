
title : Linux Dev environment on Windows Part 2
author : Mark Nielsen
copyright : November 2024
---


Linux Dev environment on Windows Part 2
==============================

_**by Mark Nielsen
Original Copyright November 2024**_
TODO : import grfana dashboards


NOTE: This is very similar to having Linux as a Host instead of Windows. Any operating system as a host is almost
irrelevant.
I am just given a Windows laptop wherever I work, so I am stuck with it. 

Sections
* [Links](#links)
* [6 db servers for all local installations](#6)
* [MySQL](#m)
* Free Databases ( or nearly free) on the internet
   * Password
       * [Bluefish](#b) on local server and Google Drive
   * [Sample data](#sample) : https://www.mysqltutorial.org/wp-content/uploads/2023/10/mysqlsampledatabase.zip
   * Online Databases services and Distributed Database services
      * [CockroachDB](#c)
      * [TIDB](#t)
      * [Yugabyte](#y)
      * [MongoDB](#m)
      * [Snowflake](#snow)
      * GCP
          * [BigQuery](#b)
          * [PubSub](#p)
      * AWS	  
          * [Dynamo](#d)
          * [SimplDB](#s)


* * *

<a name=links></a>Links
-----
TODO verify links and redo links
* [Part 1](https://github.com/vikingdata/articles/blob/main/linux/vm/Linux_dev_under_Windows_part1.md)
* https://logz.io/blog/grafana-tutorial/
* https://grafana.com/docs/grafana/latest/developers/http_api/data_source/
* https://www.youtube.com/watch?v=Dcumy5Ir1Ag
* * *
<a name=6></a>6 db servers for all local installtions
-----

First, do [Linux Dev under VirtualBox Part 1](Linux_dev_under_VirtualBox_part1.md)

End goal:
    * 6 servers db1, db2, db3, db4, db5, and db6. Each type of database
      will use some or all of the servers. 
    * MySQL will use 3 servers.
    * MongoDB will use 7 servers. 6 database servers and one admin server.
    * TIDB will use
    * Yugabyte will use
    * Couchbase will use
    * Install MySQL ClusterSet on all 6 servers.
    * Install Percona Galera Cluster on all 6 servers. 

* Now import the image as described in [Part 1](Linux_dev_under_Windows_part1.md#copies)
    * In Virtual Box, select Import Appliance
    * For File, put in C:\shared\UbuntuBase.ova
        * Or whatever you saved the base ubuntu image as.
    * Change settings
    * Name : db1 (or db2, db3, db4, db5, db6)
    * Mac Address Policy : "Generate new"
    * click Finish
    * Start the instance
* Setup the firewall and port forward as in [Part 1](Linux_dev_under_Windows_part1.md#nat2) 
* To find out the ip address of each server, on each server:
```
ifconfig |grep "inet 10" | sed -e "s/  */ /g" | cut -d " " -f 3
my_ip=`ifconfig |grep "inet 10" | sed -e "s/  */ /g" | cut -d " " -f 3`
echo "my ip address is : $my_ip"
```

* Setup the firewall and port forward 
    * Described in [Part 1](https://github.com/vikingdata/articles/blob/main/linux/vm/Linux
_dev_under_Windows_part1.md#ssh) but use a different port for the firewall which should match the host port in
port forwarding.
        * Example for db1:
            * Make the firewall block with port 2002
            * In Virtual Box Manager, the port forward
                * Name : Rule3 (or any name available)
                * Protocol : TCP
                * Host Ip: 127.0.0.1
                * Host Port : 2101 (or available port -- choose 6 sequential ip addresses)
                * Guest IP : 10.0.2.7 (depends on your ip address for db1, db2, db3, db4, db5 db6)
                    * Change to the ip address of your virtual box.
                * Guest Port : 22


    * Repeat the previous steps.
        * The port forwarding might need to be edited instead of making new ones. This is for "ssh". 
        * db1 server should use port 2101  on host
        * db2 server should use port 2102  on host
        * db3 server should use port 2103  on host
        * db4 server should use port 2104  on host
        * db5 server should use port 2105  on host
        * db6 server should use port 2106  on host


* On each server, change the hostname
    * db1 :   hostnamectl set-hostname db1.myguest.virtualbox.org
    * db2 :   hostnamectl set-hostname db2.myguest.virtualbox.org
    * db3 :   hostnamectl set-hostname db3.myguest.virtualbox.org
    * db4 :   hostnamectl set-hostname db4.myguest.virtualbox.org
    * db5 :   hostnamectl set-hostname db5.myguest.virtualbox.org
    * db6 :   hostnamectl set-hostname db6.myguest.virtualbox.org

* In WSL or cygwin in Windows : Test the connections -- NOTE, the port forwarding must be done already.
    * ssh 127.0.0.1 -p 2101 -l root "echo '2101 good', `hostname`"
    * ssh 127.0.0.1 -p 2102 -l root "echo '2202 good', `hostname`"
    * ssh 127.0.0.1 -p 2103 -l root "echo '2303 good', `hostname`"
    * ssh 127.0.0.1 -p 2104 -l root "echo '2304 good', `hostname`"
    * ssh 127.0.0.1 -p 2105 -l root "echo '2305 good', `hostname`"
    * ssh 127.0.0.1 -p 2106 -l root "echo '2306 good', `hostname`"


* on each server, we will be modfying the files 
   * You write your alias to the file:
       * /shared/virtual_host_aliases.sh
       * /shared/aliases
       * /shared/server_ips
   * This file on windows should be:
       * C:\shared\virtual_host_aliases.sh
       * C:\shared\aliases
       * C:\shared\server_ips
   * In cygwin in Windows
       * /cygdrive/c/shared/virtual_host_aliases.sh
       * /cygdrive/c/shared/aliases
       * /cygdrive/c/shared/server_ips
   * WSL in windows
       * /server_ips/virtual_host_aliases.sh
       * /server_ips/aliases
       * /server_ips/server_ips

* On each server,

Execute this

```
webpage="https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main/linux/vm/Linux_dev_under_VirtualBox_part2/make_alias.sh"
curl -s $webpage | bash

```

* Then execute this on cygwin or WSL
```
webpage="https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main/linux/vm/Linux_dev_under_VirtualBox_part2/make_aliases_cygin_wsl.sh"
curl -s $webpage | bash

```


* Copy the aliases to .bashrc

/shared/virtual_host_aliases.sh should look something like

```
alias admin='10.0.2.1'
alias db1='10.0.2.2'
alias db2='10.0.2.3'
alias db3='10.0.2.4'
alias db4='10.0.2.5'
alias db5='10.0.2.6'
alias db6='10.0.2.7'

```

On each system (admin, db1... db6, and any other virtual machine)

```
webpage="https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main/linux/vm/Linux_dev_under_VirtualBox_part2/make_aliases_virtual.sh"
curl -s $webpage | bash
```


* In Windows, in cygwin or WSL. This should be unecessary. The base image should already have this.
```
for port in  2101 2102 2013 2014 2015 2016; do
  ssh-copy-id -o "StrictHostKeyChecking no" -p $port -i ~/.ssh/id_rsa.pub root@127.0.0.1
  ssh -p $port root@127.0.0.1 "echo 'ssh firewall $port ok'"
done

```


* * *
<a name=m></a>Install MySQL on all 6 servers manually
-----
###  Include Percona + mysql tools for ClusterSet later. 

* Follow install inbstructions from [MySQL Clusterset on one server](https://github.com/vikingdata/articles/blob/main/databases/mysql/MySQL_Clusterset_on_one_server.md#i) in just the secion "Install Percona MySQL, mysqlsh, mysql router on Ubuntu". Or follow these steps

NOTE: the router and shell must be equal or ahead of the percona version. Installing a specific version of
percona seems to not work when newer versions come out. An option is to download the tarball and add to
the PATH the location of the binaries. You might want to also download the percona binaries and the mysql binaries
or tarballs, as they tend to vanish over time as new versions come out. 

* Download install file
    * [basic_percona_mysql_8_install.bash](Linux_dev_under_VirtualBox_part2_files/basic_percona_mysql_8_install.bash)

* Install file
```
  # Execute per server
for i in 1 2 3 4 5 6; do

  ssh  127.0.0.1 -p 210$i -l root "mkdir -p /database/install_scripts"

    # Copy over file
  scp_copy="scp basic_percona_mysql_8_install.bash root@127.0.0.1:/database/install_scripts/ -p 210$i "

    # Execute File
  ssh 127.0.0.1 -p 210$i -l root ""
done

```

* Check Output of mysql query during install
```
+-------------------------+----------------+
| VARIABLE_NAME           | VARIABLE_VALUE |
+-------------------------+----------------+
| innodb_buffer_pool_size | 5242880        |
| master_info_repository  | TABLE          |
| server_id               | 1              |
+-------------------------+----------------+
3 rows in set (0.53 sec)
```

TODO
   * Turn off mysql starting, create start script

### Setup firewall and port forwarding for db1
Setup firewall for port 3301

* https://www.action1.com/how-to-block-or-allow-tcp-ip-port-in-windows-firewall/
* In Windows, type in firewall in the search field and select "Firewall Network and Protection.
* Click on Inbound rules, and select New.
* Click port
* Enter port 3101
* Click Block connection
* Select domain, private, and public
* name it : A block mysql 3101
* Click on finish
* Do the same thing for port 2101
   * Label it : A block ssh 2101

Setup port forwarding port 3101 to 3306 in db1. 

* Setup port forwarding in Virtual Box to Linux installation.
    * Select the running server "db1"
    * Devices -> Network -> Network Settings
        * Adapter 1 -> Attached to -> NAT
        * Click on Advanced and then port forwarding
            * Enter
            * Name : Rule3
            * Protocol : TCP
            * Host Ip: 127.0.0.1
            * Host Port : 3101
            * Guest IP : 10.0.2.15
	    * Guest Port : 3306
    * Do the same thing for ssh.
            * Name : Rule3
            * Protocol : TCP
            * Host Ip: 127.0.0.1
            * Host Port : 2101
            * Guest IP : 10.0.2.15
            * Guest Port : 22

TODO: Block on firewall

* Test connection on host: mysql -u root -proot -h 127.0.0.1 -e "select 'good'" -P 3101
     * ssh test : ssh root@127.0.0.1 -p 2101 "echo 'ssh 2101 worked'"

### Setup firewall and port forwarding for other database servers.

* Port on Windows : 3102, 3103, 3104 for MySQL
* Port in Linux : All 3306 for mysql
* Port on Windows : 2102, 2103, 2104 for ssh
* Port in Linux : All 3306 for ssh 
* Remmeber to also block the firewall for ports 3102, 3103, 3104, 2012, 2013, and 2104 on Windows. 

### Setup replication for Master-Master and each Master has a slave.

* * *
<a name=b></a>Buttercup and Google Drive
-----

The Purpose is to make your own encrypted passwords that you can keep on Google Drive or other
cloud file service. Google Drive is free up to a certain amount of space. 

* Install Google Drive App
    * Create a directory
        * ex: c:\google_drive
	* Add this directory to Google Drive
* Install Buttercup: https://buttercup.pw/
    * Create the directory c:\google_drive\buttercup
    * Make a new file at c:\google_drive\buttercup\main.bcup
    * Save your ssh passwords and mysql passwords.

Next steps:
* If you need console or ssh access, login into server "admin".
* For web access, use your host computer.

* * *
<a name=sample></a>Sample data
-----
We will be using this data for all our initial testing. 
* https://www.mysqltutorial.org/wp-content/uploads/2023/10/mysqlsampledatabase.zip

```
  # Log into your admin server as root

cd
mkdir -p ~/sample_data
cd ~/sample_data
wget https://www.mysqltutorial.org/wp-content/uploads/2023/10/mysqlsampledatabase.zip
unzip mysqlsampledatabase.zip
ls -al mysqlsampledatabase.sql

wget https://raw.githubusercontent.com/pthom/northwind_psql/refs/heads/master/northwind.sql


```

* * *
<a name=c></a>CockroachDB
-----

Note: taken from website January 2025
* Free for use up to 10 GiB of storage and 50M RUs per organization per month.
* $0.20 per 1 Million request units consumed, $0.50 per GiB stored per month

Setup account
* goto https://www.cockroachlabs.com/pricing/
    * Follow instructions
        * If you created the account, login at https://cockroachlabs.cloud/clusters
    * Setup cluster name
       * Change unlimited to 10 gig and 10 million RU
       * Create cluster
       * Save and generate password
           *  Save your password in buttercup. 
       * Save cert by following commands. I have not figured out how to get the cert if you don't get it now. 
           * I suggest you save the contents of the cert file in Buttercup.
	   * Get cert file and also save it to buttercup
	       * ex: curl --create-dirs -o $HOME/.postgresql/root.crt 'https://cockroachlabs.cloud/clusters/f701d3fa-dee0-XXXXXXXXX/cert'
       * Copy connection string
           * Select "Parameters ONLY:
	   * Save cert as a not in buttercup.
	   * You could also save the export  connection option.
       * If not done yet, select your cluster and click on "Connect" button un the upper right corner.
           * Save the connection information in buttercup.
* After this you should have this and save it in Buttercup. 
    * The cert file
    * Username and password
    * Connection string with url. 

* After you set everything up,
follow the instructions on how to connect from your server by clicking on the
button "Connect" in the upper right corner.
* For this login into server "admin" server.
* Execute the curl command to get the cert.
* Execute the connection environment variable.
```
   # Save your variables in .bashrc in Linux
export C_USER="Your cockroach user"
export C_PASS="Your cockroach pass"
export C_HOST="the cockroach host"
   # probably defaultdb
export C_DATABASE="Your cockroach database"
   # probably 26257
export C_PORT="Your cockroach port"
   # Name of the cluster you made. 
export C_CLUSTER="Your cluster name"

  # Create the url needed for some clients
export DATABASE_URL="postgresql://$C_USER:$CPASS@$C_HOST:$C_PORT/$C_DATABASE?sslmode=verify-full"

  # Save your connection to Linux bash login.

echo "
export C_USER='$C_USER'
export C_PASS='$C_PASS'
export C_HOST='$C_HOST'
   # probably defaultdb
export C_DATABASE='C_DATABASE'
   # probably 26257
export C_PORT='$C_PORT'
export C_CLUSTER='$C_CLUSER'


export DATABASE_URL='$DATABASE_URL'
" >> ~/.bashrc_cockroach

echo "source ~/.bashrc_cockroach" >> ~/.bashrc  

source ~/.bashrc

  # You should see your database url
echo $DATABASE_URL

```

* Install cockroachdb client for Linux
   * There are 5 ways to execute code
        * wen interface
	* A programming language
	* cockroach client
	* ccloud client
	* psql from postgresql
	
* Follow the intructions at: https://uptimedba.github.io/cockroach-vb-single/cockroach-vb-single/cockroach-vb-single_db_install.html
```
mkdir -p ~/software_install/cockroach
cd ~/software_install/cockroach
wget https://binaries.cockroachdb.com/cockroach-v24.3.3.linux-amd64.tgz
tar -zxvf cockroach-v24.3.3.linux-amd64.tgz
cd cockroach-v24.3.3.linux-amd64

mkdir -p /usr/local/lib/cockroach
cp -iv lib/* /usr/local/lib/cockroach

cp -iv cockroach /usr/local/bin/

```

* Install ccloud at https://www.cockroachlabs.com/docs/cockroachcloud/ccloud-get-started?filters=linux But This has to be your desktop server. If your desktop server is Windows, do the windows installation. You will not be able to use ccloud on the admin server because it tries to start a browser. 
```
mkdir -p ~/software_install/cockroach
cd ~/software_install/cockroach

wget  https://binaries.cockroachdb.com/ccloud/ccloud_linux-amd64_0.6.12.tar.gz
tar -xzvf ccloud_linux-amd64_0.6.12.tar.gz
cp -iv ccloud /usr/local/bin
```

* Install postgresql client (not server)
```
cd ~/software_install/cockroach

# Setup postgresql client
apt-get install -y postgresql-client
mkdir -p ~/.postgresql/

  # Copy the cert over
  # If there are two certificates, this file should only have the first one.
  # NOTE : Only do this step if you did not copy the certificate over yet. 
cp ~/cockroach_certfile ~/.postgresql/root.crt



```
* Test the connection with cockroachdb client and ccloud and postgresql client
```
cockroach sql --url $DATABASE_URL

   # Enter this command
   # You will need to enter the URL in a browser, copy the the authentication code
   #   to the prompt that ask you for the authentication code.
ccloud auth login --no-redirect

  # Test this on your windows server.

  # First, Log into the cloud cockroach on your browser.
  # Execute ccloud auth login
  #   Enter the url into your browser
  #     ex: https://cockroachlabs.cloud/cli?cliNonce=XXXXXXXXXXXXXXXX&cliPort=45629&headless=true&responseType=code
  #   Copy the code on your webpage.
  # Enter this into the prompt from ccloud auth login --no-redirect
  # Now you should be logged in.

  # Then see if you can connect.
  # This will download cockroach client software. 
ccloud cluster sql $C_CLUSTER -u $C_USER -p $C_PASS


  # Setup postgresql client
apt-get install -y postgresql-client
mkdir -p ~/.postgresql/

  # Verify the certificate is installed
  # If there are two certificates, this file should only have the first one. 
ls -al $HOME/.postgresql/root.crt

```
* Now test basic commands with each of 3 clients. 
```

cd ~/software_install

echo "SELECT datname FROM pg_database;

create database if not exists test1;
use test1;
drop table if exists test_table1;
create table test_table1 (i int);

SELECT    *
FROM    information_schema.tables
WHERE    table_type = 'BASE TABLE'
AND    table_schema = 'public';

" > basic_sql_commands.sql

cockroach sql --url $DATABASE_URL < basic_sql_commands.sql

ccloud cluster sql $C_CLUSTER -u $C_USER -p $C_PASS < basic_sql_commands.sql

psql -P pager=off  $DATABASE_URL -f basic_sql_commands.sql


```


* Now test loading of data with each client. It is MySQL formatted, but its basic SQL. Each data
load will drop the previous data. 
```
cd ~/sample_data/

cockroach sql --url $DATABASE_URL < northwind.sql

ccloud cluster sql $C_CLUSTER -u $C_USER -p $C_PASS < northwind.sql


psql  -P pager=off $DATABASE_URL -f northwind.sql


```

* * *
<a name=t></a>TiDB
-----
* [TiDB vs Amazon RDS for MySQL](https://www.pingcap.com/tidb-cloud-serverless-vs-amazon-rds/?utm_source=google&utm_medium=cpc&utm_campaign=plg_search_RDScompare_blog_01&utm_term=tidb%20cloud&utm_campaign=plg_search_RDScompare_blog_01&utm_source=adwords&utm_medium=ppc&hsa_acc=7438219570&hsa_cam=21762816921&hsa_grp=165117033501&hsa_ad=715506387577&hsa_src=g&hsa_tgt=kwd-2397205853419&hsa_kw=tidb%20cloud&hsa_mt=p&hsa_net=adwords&hsa_ver=3&gad_source=1&gclid=CjwKCAiA5Ka9BhB5EiwA1ZVtvEm5PTnqG-U0fGM_FhybHiJP418cRTJqkm8QaXIk1e_kkR2ORsJtrRoCdXkQAvD_BwE)
* [Get started](https://tidbcloud.com/free-trial/)

* After you sign up, you will be given a cluster called Cluster0. Or you can make your own.
* Click on Cluster0 or the cluster you create.
* Click on Connect in the upper right hand corner
* Click "Generate password". Make a password. 
* For the various connections with client or programmin languages, the code to execute will be there. For clients you
have to install the software and for programming languages you will have to make sure the languages are installed
and then the driver for TiDB is installed with that language (which tends to be a MySQL driver).
* Select "General" under "Connect With"
    * We will connect with the mysql client.
* Create directory to make login for .bashrc
```
mkdir ~/make_database_connections/
cd make_database_connections/
```
* Save this content to "make_database_connections/tidb"

```
#!/bin/bash
   ## Replace these values with your TiDB cloud account. 
export tidb_host='ZZZZZZZZ.us-east-1.prod.aws.tidbcloud.com'
export tidb_port=4000
export tidb_user='<user>'
export tidb_pass='<password>'
export tidb_db='test'
#export tidb_ca='<path to CA>'


echo "

export tidb_host='$tidb_host'
export tidb_port='$tidb_port'
export tidb_user='$tidb_user'
export tidb_pass='$tidb_pass'
export tidb_db='$tidb_db'
#export tidb_ca='$tidb_ca'


" >> ~/.bashrc_tidb

echo "source ~/.bashrc_tidb" >> ~/.bashrc
source ~/.bashrc
```
* Manually execute : source ~/.bashrc
* Edit the script to put in your own database settings. fg
* Execute script
```
cd make_database_connections
bash tidb

```

### Connect to the TiDB database with mysql software
* Install mysql client software :
```
mkdir -p ~/software_install
cd ~/software_install
wget https://raw.githubusercontent.com/vikingdata/articles/refs/heads/main/linux/vm/Linux_dev_under_VirtualBox_part2_files/basic_percona_mysql_8_install.bash
bash basic_percona_mysql_8_install.bash

sudo systemctl disable mysql
sudo service mysql stop

systemctl list-unit-files | egrep "mysql|VENDOR"

```

* Commands to connect to tidb
```
mysql --comments -u '$tidb_user' -h $tidb_host -P $tibb_port -D '$tidb_db' --ssl-mode=VERIFY_IDENTITY -p'$tidb_pass'

  # or mariadb
mysql --comments -u '$tidb_user' -h $tidb_host -P $tidb_port -D '$tidb_db' --ssl-verify-server-cert  -p'$tidb_pass'

```


* * *
<a name=y></a>Yugabyte
-----
Links:
* https://www.yugabyte.com/yugabytedb/
    * Sign up with email
    * Go to email and click on "Finish Signup"
    * After that, login.
    * Create  a cluster
         * Make sure to add your ip address to be allowed to connect to it from your desktop or laptop.
	 * You may want to enter a subnet. For example, if your computer is
68.1.2.3/32, you want to add the range of 68.1.2.0 to 68.1.2.255, which would be "68.1.2.0/24".
         * Download the credentials and optionally downlown the username and password.
	 * Create the cluster.
	 * Wait for cluster to be created.
	 * Download crt
             * Click on "Connect", Click on "view guide" under "YugabyteDB Client Shell" , and then click on "Download CA cert".
             * Save to : 

* NOTE : Yugabyte only has a free trial for online services. You have to
download it yourself to use it for free. 

#### Connect to Yugabyte
##### Option 1 : Log into the web console.


##### Option 2 : Connect from laptop or desktop

##### Download software to connect
* Install yugabyte postgresql and cassandra software : ysqlsh and ycslsh
    * https://docs.yugabyte.com/preview/api/ysqlsh/
    * https://docs.yugabyte.com/preview/releases/yugabyte-clients/
```
## Login as root or sudo to root. 
wget https://downloads.yugabyte.com/releases/2.25.0.0/yugabyte-client-2.25.0.0-b489-linux-x86_64.tar.gz
tar xvfz yugabyte-client-2.25.0.0-b489-linux-x86_64.tar.gz
mv yugabyte-client-2.25.0.0 /usr/local
cd /usr/local
ln -s yugabyte-client-2.25.0.0 yugabyte-client-service
cd yugabyte-client-2.25.0.0
mkdir -p cert
./bin/post_install.sh
```
* Install postgresql client software
    * Install: follow https://www.postgresql.org/download/linux/ubuntu/
```
sudo apt install -y postgresql-common
sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
```

* Install cassandra client software : 
```
TODO 
```
###### Create connection with 
YSQLSH and YCQLSH
* Log into web console
    * Click on Connect, Click on View Guide under YugabyteDB Client Shell,
        under Run your remote shell with the following string click on YSQL.
	It should look something like
```
  ## Change HOST. Change user is different. 
./ysqlsh "<HOST>.aws.yugabyte.cloud \
user=admin \
dbname=yugabyte \
sslmode=verify-full \
sslrootcert=<ROOT_CERT_PATH>"

```
* Add stuff to .bashrc
```
  ## Change <HOST>. Change user if different.

cp ~/.bashrc ~/.bashrc_`date +%y%m%d_%H%M%S`
echo '' > ~/.bashrc_yugabyte_service

echo " export Y_USER='admin'
export Y_DB='yugabyte'
export Y_sslmode=verify-full 
export Y_sslrootcert=/usr/local/yugabyte-client-service/cert/root.crt
export Y_HOST='<HOST>'
# ex: export Y_HOST='X.Y.aws.yugabyte.cloud'
export Y_HOME_BIN=/usr/local/yugabyte-client-service/bin
" >> ~/.bashrc_yugabyte_service

echo "PATH=\$Y_HOME_BIN:\$PATH" >> ~/.bashrc_yugabyte_service

export Y_USER='admin'
export Y_DB='yugabyte'
export Y_sslmode=verify-full
export Y_sslrootcert=/usr/local/yugabyte-client-service/cert/root.crt
export Y_HOST='<HOST>'
  # ex: export Y_HOST='X.Y.aws.yugabyte.cloud'
export Y_HOME_BIN=/usr/local/yugabyte-client-service/bin


    ## Create the connection string
    ## Remember to change the password between the single quotes. 
echo "host=$Y_HOST user=$Y_USER dbname=$Y_DB sslmode=$Y_sslmode sslrootcert=$Y_sslrootcert password='abcdZZZZZZZ123'  " > ~/.yugabyte_service_conn
chmod 700 ~/.yugabyte_service_conn
echo "alias ysqlsh_service=\"ysqlsh \" \\\`cat ~/.yugabyte_service_conn  \\\` \\\" \" " >> ~/.bashrc_yugabyte_service
echo "alias ysqlsh_service_print=\"echo ysqlsh \\\" \\\`cat ~/.yugabyte_service_conn  \\\`   \\\" \"  " >> ~/.bashrc_yugabyte_service
echo "source ~/.bashrc_yugabyte_service" >> ~/.bashrc
source ~/.bashrc
echo "select now()"  |ysqlsh_service

# Output should look something like
              now
-------------------------------
 2025-03-17 21:17:50.963334+00
(1 row)

# print out the yugabyte full connection

ysqlsh_service_print

# Output
ysqlsh  host=X.Y.aws.yugabyte.cloud user=admin dbname=yugabyte sslmode=verify-full sslrootcert=/usr/local/yugabyte-client-service/cert/root.crt password='123ZZZZZZZZZZZZabc'

```
* Now configure ycqlsh

```
echo "abcZZZZ123" > ~/.yugabyte_service_password
chmod 700 ~/.yugabyte_service_password

echo " alias ycqlsh_service=\"SSL_CERTFILE=/usr/local/yugabyte-client-service/cert/root.crt \
  ycqlsh \
HOST.aws.yugabyte.cloud 9042 \
-u admin \
--ssl \
-p \\\`cat ~/.yugabyte_service_password\\\` \" " > ~/.bashrc_yugabyte_ycqlsh_service

echo "source ~/.bashrc_yugabyte_ycqlsh_service" >> ~/.bashrc

source ~/.bashrc

echo "SELECT dateof(now()) FROM system.local ;" | ycqlsh_service

## output
 dateof(now())
---------------------------------
 2025-03-17 22:47:37.680000+0000


```


PSQL
* Look at : https://www.cybertec-postgresql.com/en/pg_service-conf-the-forgotten-config-file/

* Create Login file
```
echo "
[pgsql_yugbayte_webservice]

host=<HOST>
  # ex: X.Y.aws.yugabyte.cloud
port=5433
dbname=yugabyte
user=admin
password=<PASSWORD>
  # ex: abcZZZZZZZZ123
sslmode=verify-full
sslrootcert=/usr/local/yugabyte-client-service/cert/root.crt

" > ~/.pg_service.conf
chmod 700 ~/.pg_service.conf

export PGSERVICE=pgsql_yugbayte_webservice
echo "export PGSERVICE=pgsql_yugbayte_webservice" > ~/.bashrc_yugabyte_psql_service
echo "source ~/.bashrc_yugabyte_psql_service" >> ~/.bashrc

psql -c "select now(), (select  host from yb_servers() ) as ip ;"

```

* * *
<a name=m></a>MongoDB
-----

* * *
<a name=snow></a>Snowflake
-----

* * *
<a name=b></a>BigQuery
-----

* * *
<a name=p></a>PubSub
-----

* * *
<a name=d></a>Dynamo
-----

* * *
<a name=s></a>SimpleDB
-----
