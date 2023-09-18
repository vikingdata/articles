-----
title: VSCode and snowflake
----



  
  
Just basic DBT for ELT processing. We assume mysql are both installed.

1.  [Links](#links)
2.  [VSCode Install](#install)

* * *

<a name=links></a>Links
-----


*   (snowflake instructions for VSCode)[https://docs.snowflake.com/en/user-guide/vscode-ext]


* * *

<a name=install></a> Install
----------


* (Download and Install)[https://code.visualstudio.com/] VSCode. Its free.
   * If Windows, it should start the executable. Otherwise run VSCodeUserSetup-x64-1.82.2.exe
* Follow the instructions fo extension installation, but it was a little different for me.
   * There was an EXtensions button on he middle left menu.
   * I searched for Snowflake.
   * clicked on install
   * A snowflake icon will appear in the left hand menu.
   * Click on the Snowflake icon.
   * Put in the account identified as you did for SnowSQL.
   * Put in the username and password.
   * You should be connected now. It should list the number of databases you have.
* Again, Click on the Extensions button
   * search for SQLTools
   * Install it.
   * In Extensions, search for "Snowflake Driver for SQLTools"
   * Install it
   * In Extensions, search for "SQLTools PostgreSQL/Cockroach Driver"
   * Install it
* Quit VsCode
* Start VSCode. This reloads the drivers installed. 
   * On The button "SQL Tools" click on "Add New Connections."
   * Select PostgreSQL
      * Connection name : PostgreSQL
      * Server address: 127.0.0.1 or the ip address of the server if you are connecting from your desktop. 
      * username : mark
      * Use passsword : Save as plaintext in settings
      * passsword : mark
      * database : mark
      * port : 5432
   * Click on "Test Connection" and if it works, click on "Save".
   * If you have connection problems to a remote system, look at (remote conncection to postgresql)[https://www.thegeekstuff.com/2014/02/enable-remote-postgresql-connection/]
      * For me
         * Edited : sudo emacs -nw  /etc/postgresql/15/main/pg_hba.conf
	 and added it
	 ``` host    all             all         192.168.1.1/24           password ```
         * Edited : sudo emacs -nw /etc/postgresql/15/main/postgresql.conf
	 and added it
	 ```listen_addresses = '*'```
	 * And restarted postgresql: sudo service postgresql restart
   * Clicck on "Create Another " or On The button "SQL Tools" click on "Add New Connections."
   * Select Snowflake
      * Connection Name : Snowflake 
      * Account : [ same as you used for snowsql ]
      * username : [ same as you used for snowsql ]
      * passsword : [ same as you used for snowsql ]
      * database : [ same as you used for snowsql ]
      * warehouse : [ same as you used for snowsql ]
      * Schema : [ same as you used for snowsql ]
      * Role : [ same as you used for snowsql ]
   * Click on "Test Connection" and if it works, click "Save". 
   


