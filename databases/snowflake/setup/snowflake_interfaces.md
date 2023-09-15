DPT install : CLI and Adapters
==============================

_**by Mark Nielsen  
Copyright Jan 2022**_

  
  
Just basic DPT for ELT processing. We assume mysql are both installed.

1.  [Links](#links)
2.  [PostgreSQL](#pg)
3.  [First Project](#project1)
4.  [Setup CLI environment](#cli)
5.  [Snowflake](#snowflake)

  

* * *

Links
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

  

* * *

PostgreSQL
----------

*   Setup dpt and postgresql
    
    	# you might need to execute this
    
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
    
    	# This is very bad for security, just for this article. Do not do this on a prod system.
    export PGPASSWORD=mark
    echo 'export PGPASSWORD=mark' > ~/.bashrc
    	
    psql -U mark -h 127.0.0.1 -c "create table test1 (i int);"
    
    mkdir ~/.dpt
    cd ~/
    	
          
    
*   Setup in config file for postgresql. Run dbt init and edit file.
    
    *   Download https://github.com/dbt-labs/dbt-starter-project  
        \> or https://github.com/dbt-labs/dbt-starter-project/archive/refs/heads/main.zip  
        Execute:
        
        wget https://github.com/dbt-labs/dbt-starter-project/archive/refs/heads/main.zip
        unzip main.zip
        mv dbt-starter-project-main ~/dbt/dbt_test1
        cd ~/
        
    *   Run dbt init and edit file.  
        Execute: dbt init
    *   name : dbt_test1  
        This will make a directory called "db1_test1", but since it already exists, it will just use it.
    *   database : postgres
    *   Now edit ~/.dbt/profiles and make changes
        
        * * *
        
        default:
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
        
    *   Edit ~/dbt/dbt_test1/dbt_project.yml  
        Change : profile: 'default'  
        to : profile: 'dbt_test1'  
        And change  
        
        models:
          my_new_project:
        
          
        to
        
        models:
          dbt_test1:
        
    *   Change to working directory, it will search for dbt_project.yml  
        cd ~/dbt/dbt_test1
    *   Execute, and there should be no errors: dbt debug
    *   Lastly, add ''' DBT_PROJECT_DIR=~/dbt/dbt_test1''' to your .bashrc file. No matter what directory you are in it will find the file after you log in.  
        echo "export DBT_PROJECT_DIR=~/dbt/dbt_test1" >> ~/.bashrc
    *   also : export DBT_PROJECT_DIR=~/dbt/dbt_test1 to your current session.  
        export DBT_PROJECT_DIR=~/dbt/dbt_test1
    
      
    
    * * *
    
    Setting up a project
    --------------------
    
    The project is already setup called "dbt_test1". This is finished.
    
    *   git is ignored for now
    *   The connection string to postgresql should be working.
    *   ~/.dpt/profiles.yml
    *   ~/.dpt/dpt_project.yml
    *   ~/dbt/dbt_test1 directory
    
      
    
    * * *
    
    Setup CLI environment
    ---------------------
    
    We will be following the stuff on this url : https://discourse.getdbt.com/t/how-we-set-up-our-computers-for-working-on-dbt-projects/243  
    
    * * *
    
    Snowflake
    ---------
    
    *   Snowflake
        *   Get a 30 day trial snowflake account.  
            Sign in or sign up for a 30 day trial : https://app.snowflake.com/
        *   Log into your snowflake environment. In new, I suggest the tutorials.
        *   Click on "Data"
        *   Click on "+ Database" in the upper right hand corner.  
            Enter in "dpt_test" for the database.
        *   Click on "dpt_test"
        *   Click on "+ schema". Enter test_schema
        *   Create a user.  
            Click on Admin, then User & Roles, then "+ user"  
            Enter in dpt_user, give it a password  
            Give a role by clicking on "Grant role" in the lower left-hand corner.  
            Select "AccountAdmin" role
    *   Linux
        Enter python environment: env_dbt
        
        		pip install dbt-snowflake
        		
        
        *   Edit .dpt/profiles.yml  
            The account is, is from the url you are using.  
            For example, https://app.snowflake.com/fntrtms/abc123/worksheets, the id is "abc123".
            
            dpt_test_sf:
              target: dev
              outputs:
                dev:
                  type: snowflake
                  account: abd123 # Put in your account id
            
                  # User/password auth
                  user: dpt_user
                  password: \[password\]   # Put in your password
            
                  role: ACCOUNTADMIN
                  database: dpt_test
                  warehouse: COMPUTER_WH  # default warehouse
                  schema: test_schema
                  threads: 1
                  client_session_keep_alive: False
                  query_tag: test
