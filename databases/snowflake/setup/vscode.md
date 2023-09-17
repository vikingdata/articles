-----
title: VSCode and snowflake
----



  
  
Just basic DBT for ELT processing. We assume mysql are both installed.

1.  [Links](#links)
2.  [PostgreSQL Install](#pginstall)
3.  [PostgreSQL DBT](#pgdbt)
4.  [Snowflake signup](#sfsignup)
6.  [Snowfake web GUI and DBT setup](#sfgui)
7.  [Snowflake CLI - ](#cli)
8.  [Snowflake VSCode](#vscode)
9.  [Setting up first project in PostgreSQL](#project1)
10. [Setting up second project in Snowflake](#project2)

  

* * *

<a name=links></a>Links
-----

*   https://docs.getdbt.com/docs/introduction
*   https://docs.getdbt.com/docs/core/installation
*   https://docs.getdbt.com/docs/supported-data-platforms
*   https://www.youtube.com/watch?v=5rNquRnNb4E&list=PLy4OcwImJzBLJzLYxpxaPUmCWp8j1esvT
*   https://docs.getdbt.com/docs/core/connect-data-platform/mysql-setup
*   https://docs.getdbt.com/docs/core/connect-data-platform/postgres-setup
*   https://www.getdbt.com/blog/write-better-sql-a-defense-of-group-by-1
*   https://www.youtube.com/playlist?list=PLy4OcwImJzBLJzLYxpxaPUmCWp8j1esvT
*   https://www.youtube.com/watch?v=5rNquRnNb4E&list=PLy4OcwImJzBLJzLYxpxaPUmCWp8j1esvT
*   https://docs.snowflake.com/en/release-notes/2023/7_22#sql-updates
*   https://docs.getdbt.com/reference/dbt-commands
*   https://docs.snowflake.com/en/user-guide/snowsql-config
*   https://thinketl.com/snowflake-snowsql-command-line-tool-to-access-snowflake/#5_How_to_use_variables_in_SnowSQL

* * *

<a name=pginstall></a>PostgreSQL Install
----------

Why are we setting up PostgreSQL dbt?
* By installing PostgreSQL you already have "psql" as a CLI.
* By installing dbt for PostgreSQL, you can play with before you use dbt for Snowflake.
* Basically, think of PostgreSQL as your own playground before Snowflake.
* For PostgreSQL installation, refer [PostgreSQL Install](http://odendata.com/docs/database/pg/pg15_install.html)


* * *

<a name=pgdbt></a>PostgreSQL DBT
----------

Why are we setting up PostgreSQL dbt?
* By installing PostgreSQL you already have "psql" as a CLI.
* By installing dbt for PostgreSQL, you can play with before you use dbt for Snowflake.
* Basically, think of PostgreSQL as your own playground before Snowflake. 

*   Setup dbt and postgresql

```
    mkdir dbt
    cd dbt
    apt install python3.10-venv
    python3 -m venv dbt-env
    source dbt-env/bin/activate
    
    echo "alias env_dbt='source ~/dbt/dbt-env/bin/activate'" >> ~/.bashrc
    	  
    pip install dbt-postgres
    
    	  ## had some errors, saw a post to do this, the uninstalls did nothing
    pip uninstall black
    pip uninstall click
    pip install black
    pip install click
    
    	  
    	  # This worked
    dbt --version
    
           # login as root
    sudo bash	
    	  # Setup postgresql account
    echo "CREATE USER mark WITH PASSWORD 'mark';" | sudo -iu postgres psql
    echo " ALTER USER postgres PASSWORD 'mark'" | sudo -iu postgres psql
    
    echo " create database mark;" | sudo -iu postgres psql
    echo " ALTER DATABASE mark OWNER TO mark" | sudo -iu postgres psql
    	
    echo " create database mark_dev;" | sudo -iu postgres psql
    echo " ALTER DATABASE mark_dev OWNER TO mark" | sudo -iu postgres psql
    echo " create database mark_prod;" | sudo -iu postgres psql
    echo " ALTER DATABASE mark_prod OWNER TO mark" | sudo -iu postgres psql
    
    	  # log out of root
    exit
```    
    	# This is very bad for security, just for this article. Do not do this on a prod system.
```bash
export PGPASSWORD=mark
echo 'export PGPASSWORD=mark' > ~/.bashrc
    	
psql -U mark -h 127.0.0.1 -c "create table test1 (i int);"
    
mkdir ~/.dbt
cd ~/
```    	
          
    
*   Setup in config file for postgresql. Run dbt init and edit file.
    
    *   Run dbt init and edit file.  
        Execute: dbt init
    *   name : dbt_pg
    *   database : postgres
    *   Now edit
    ``` ~/.dbt/profiles ``` and make changes
        
```
        
dbt_pg:
  outputs:

    dev:
      type: postgres
      threads: 1
      host: 127.0.0.1
      port: 5432
      user: mark
      pass: mark
      dbname: mark_dev
      schema: public

    prod:
      type: postgres
      threads: 1
      host: 127.0.0.1
      port: 5432
      user: mark
      pass: mark
      dbname: mark_prod
      schema: public

  target: dev

```        

*   Download https://github.com/dbt-labs/dbt-starter-project
         or https://github.com/dbt-labs/dbt-starter-project/archive/refs/heads/main.zip
        Execute:
```bash
        cd -/dbt
        wget https://github.com/dbt-labs/dbt-starter-project/archive/refs/heads/main.zip
        unzip main.zip
        rm -rf dbt_pg
        mv dbt-starter-project-main dbt_pg
        cd ~/
```
*   Edit ``` ~/dbt/dbt_pg/dbt_project.yml```  
        Change : profile: 'default'  
        to : profile: dbt_pg  
        And change  
        
        models:
          my_new_project:
          
        to

        models:
          dbt_pg:

        
    *   Change to working directory, it will search for dbt_project.yml  
        ```cd ~/dbt/dbt_pg```
    *   Execute, and there should be no errors: dbt debug
    *   Lastly, add ```DBT_PROJECT_DIR=~/dbt/dbt_test1``` to your .bashrc file. No matter what directory you are in it will find the file after you log in.  

    ```bash
       echo "export DBT_PROJECT_DIR=~/dbt/dbt_pg" >> ~/.bashrc
       echo "alias dbt_pg='cd ~/dbt/dbt_pg; export DBT_PROJECT_DIR=~/dbt/dbt_pg'" >> ~/.bashrc
    ```
    *   also : export DBT_PROJECT_DIR=~/dbt/dbt_pg to your current session.  
        ```export DBT_PROJECT_DIR=~/dbt/dbt_pg```
    
      
    
* * *    
<a name=sfsignup></a>    Snowflake SignUp
---------

*   Snowflake
    *   Get a 30 day trial snowflake account.
            Sign in or sign up for a 30 day trial : https://app.snowflake.com/



* * *
<a name=sfgui></a>     Snowflake Web GUI and DBT Setup
---------

We will practice a little bit with the gui. We will set up a DBT database. 

*   Snowflake
    *   After you signup, you should have received an email with the url to log into. 
    *   Log into your snowflake environment. If you are new, I suggest the tutorials. 
    *   Click on "Data"
    *   Click on "+ Database" in the upper right hand corner.  
        Enter in "dbt_source" for the database.
    *   Click on "dbt_source"
    *   Click on "+ schema". Enter test_schema
    *   Create a user.  
        Click on Admin, then User & Roles, then "+ user"  
        Enter in dbt_user, give it a password  
        Give a role by clicking on "Grant role" in the lower left-hand corner.  
        Select "AccountAdmin" role
*   Linux
     Enter python environment: env_dbt
   * Execute:     
     pip install dbt-snowflake
        		
   *   Setup in config file for postgresql. Run dbt init and edit file.

       * Execute : cd ~/dbt
       *   Run dbt init and edit file.
           Execute: dbt init
           *   name : dbt_sf
           *   database : snowflake, should be "2".
	   * It will ask you a bunch of other questions, other than accont_id, username, and password use the values below when you edit .dbt/profiles.yml

       * You may have to edit ~/.dbt/profiles.yml but you should not have to. 
           ```bash           
           dbt_sf:
             outputs:

              dev:
                type: snowflake
                account: [account id]

                # User/password auth
                user: [username]
                password: [password]

                role: ACCOUNTADMIN
                database: TUTORIAL
                warehouse: COMPUTER_WH
                schema: PUBLIC
                threads: 1
                client_session_keep_alive: False
                query_tag: ABCD

            target: dev

           ```
       * The account name in the config file is really the account identifier. There are at least two values you can put in there.
       * The account name you can get from the url sent to you in the email.
           * My url, was close to https://fntrtms-lobABCD.snowflakecomputing.com
           * The accountname is everything upto snowflakecomputing.
           * The account name would thus be fntrtms-lobABCD
       * Also, you can find out what to put in "account name" by
           * Login into the web gui
           * Select Admin
           * Select Accounts
           * You should see the messsage "1 Acccount in <ORG NAME>"
           * Under that, is a list of accounts.
           * The name of the first entry is the one you want.
           * So let's say The org ame is "abc" and the account is "xyz". The account name would be abc-xzy
       * The other way, look at https://docs.snowflake.com/en/user-guide/admin-account-identifier
       * Use the same username and password you use to log into the web gui.
       * Or you create a user and password.
    *   Change to working directory, it will search for dbt_project.yml
        ```cd ~/dbt/dbt_sf```
    *   Execute, and there should be no errors: dbt debug
    *   Lastly, add ```DBT_PROJECT_DIR=~/dbt/dbt_test1``` to your .bashrc file. No matter what directory you are in it will find the file after you log in.

        ```bash
        echo "export DBT_PROJECT_DIR=~/dbt/dbt_pg" >> ~/.bashrc
        echo "alias dbt_pg='cd ~/dbt/dbt_pg; export DBT_PROJECT_DIR=~/dbt/dbt_pg'" >> ~/.bashrc
        ```
    *   also : export DBT_PROJECT_DIR=~/dbt/dbt_pg to your current session.
        ```export DBT_PROJECT_DIR=~/dbt/dbt_pg```



* * *

<a name=cli></a>Setup CLI environment
---------------------

    https://docs.snowflake.com/en/user-guide/snowsql-config

This installs the cli in the ~/bin directory and adds it to your path and things in ~/.snowconfig directory. 

```
mkdir snowinstall
cd snowinstall
curl  -O https://sfc-repo.snowflakecomputing.com/snowsql/bootstrap/1.2/linux_x86_64/snowsql-1.2.28-linux_x86_64.bash 
ln -s snowsql-1.2.28-linux_x86_64.bash snowsql-linux_x86_64.bash
bash snowsql-linux_x86_64.bash
source ~/.profile
  # If it worked, this will show the version.
snowsql -v
cd ~/.snowconfig
```

Now edit the config file and change these  lines
```

accountname = [ Your account name ]
username = [ Your username ]
password = [ Your password ]

  # optional, default database, schema, warehouse

dbname = TUTORIAL
schemaname = PUBLIC
warehousename = COMPUTE_WH

[options]
variable_substitution = True

```
   * The account name in the config file is really the account identifier. There are at least two values you can put in there. 
      * The account name you can get from the url sent to you in the email.
         * My url, was close to https://fntrtms-lobABCD.snowflakecomputing.com
         * The accountname is everything upto snowflakecomputing.
         * The account name would thus be fntrtms-lobABCD
      * Also, you can find out what to put in "account name" by
         * Login into the web gui
	 * Select Admin
	 * Select Accounts
	 * You should see the messsage "1 Acccount in <ORG NAME>"
	 * Under that, is a list of accounts.
	 * The name of the first entry is the one you want.
	 * So let's say The org name is "abc" and the account is "xyz". The account name would be abc-xzy
      * The other way, look at https://docs.snowflake.com/en/user-guide/admin-account-identifier
   * Use the same username and password you use to log into the web gui.
      * Or you create a user and password. 
   * To test,
      * start snowsql : snowsql
      * enter : select current_timestamp;
         * and you should get a result.

Notes:
   * You should connect to a database, schema, and warehouse. If you didn't put the defaults in your config file, execute this : 
   ```
use database TUTORIAL;
use schema PUBLIC;
use  warehouse COMPUTE_WH;

```

