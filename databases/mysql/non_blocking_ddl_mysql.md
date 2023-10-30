
---
title : MySQL Non blocking DDL  
author : Mark Nielsen  
copyright : Oct 2023  
---


MySQL Non blocking DDL
==============================

_**by Mark Nielsen
Original Copyright Oct 2023**_


1. [Links](#links)
2. [Online DDL](#online)
3. [Online technique](#otech)
4. [PT Online Schema Change](#pt)
5. [PT technique](#pttech)
6. [Cloud](#cloud)

* * *
<a name=Links></a>Links
-----

* [15.12.1 Online DDL Operations](https://dev.mysql.com/doc/refman/8.0/en/innodb-online-ddl-operations.html)
* [15.12 InnoDB and Online DDL](https://dev.mysql.com/doc/refman/8.0/en/innodb-online-ddl.html)
* [An Overview of DDL Algorithm’s in MySQL, covers MySQL 8](https://mydbops.wordpress.com/2020/03/04/an-overview-of-ddl-algorithms-in-mysql-covers-mysql-8/)
* [pt-online-schema-change](https://docs.percona.com/percona-toolkit/pt-online-schema-change.html#:~:text=pt%2Donline%2Dschema%2Dchange%20emulates%20the%20way%20that%20MySQL,and%20change%20data%20in%20it.)
* [Understanding How ONLINE DDL (INPLACE) works in MySQL](https://klouddb.io/understanding-how-online-ddl-inplace-works-in-mysql/)

* * *

<a name=online></a>Online DDL 
-----
Online schema changes to MySQL tables can be non-blocking (read and write queries can occur while the schema change happens) when INPLACE is used (or INSTANT or COPY).
Options for "alter table" for online changes have been getting better and better.

The options for online schema for MySQL change are : 
* LOCK
    * NONE : Permits selects and writes.
    * SHARED : Only allows selects.
    * EXCLUSIVE : All queries are blocked.
    * DEFAULT : Similar to None, allows as much queries and DML.
* ALGORITHM
    * INSTANT : Certain actions can be instant changes. INSTANT changes are generally fast.
    * INPLACE : If it can't be changed instantly, then INPLACE is the next option. Basically changes happen inside without copying the entire table. This improves speed. 
    * COPY : The entire table is copied. This takes the longest. This is MySQL's response to PT online schema change.  Generally, it makes a new table and when the new table has all the data of the old table it switches them.

Example:

```shell

mysql -u mark -pmark -e 'create database if not exists test1;'  2>&1 | grep -v password
mysql -u mark -pmark -e 'drop table if exists table2' test1     2>&1 | grep -v password
mysql -u mark -pmark -e 'create table if not exists table2 (i int, PRIMARY KEY (i))' test1     2>&1 | grep -v password

mysql -vvv -u mark -pmark -e 'alter table table2 add column   i2 int, ALGORITHM=INPLACE' test1 2>&1 | grep -v password
mysql -vvv -u mark -pmark -e 'alter table table2 add column   i3 int, ALGORITHM=INSTANT' test1 2>&1 | grep -v password
mysql -vvv -u mark -pmark -e 'alter table table2 add column   i4 int, ALGORITHM=COPY' test1 2>&1 | grep -v password

mysql -vvv -u mark -pmark -e 'alter table table2 add column   i5 int, ALGORITHM=INPLACE, LOCK=SHARED' test1 2>&1 | grep -v password
mysql -vvv -u mark -pmark -e 'alter table table2 add column   i6 int, ALGORITHM=INPLACE, LOCK=EXCLUSIVE' test1 2>&1 | grep -v password
mysql -vvv -u mark -pmark -e 'alter table table2 add column   i7 int, ALGORITHM=INPLACE, LOCK=NONE' test1 2>&1 | grep -v password

mysql -u mark -pmark -e 'show create table table2' test1  2>&1 | grep -v password

```

NOTES:
* Works without primary keys.
* Try instant, then inplace, then copy.
* Use -vvv if you use mysql client. 


* * *

<a name=otech></a>Online technique
-----

* OPTIONAL: monitor locks and have a script inserting one row of data continuously for STAGING -- not production. Record how long each insert takes. After STAGING, look at the log and see if any inserts took a long time. On your monitoring graphs look to see if any locks occurred during the test. 
* Create your script which contains the schema change. Create a final script. NOTE : we have a drop table command. This should never be in the script. This is just for testing.
    * NOTE: It is faster if you combine multiple changes for a single table in one command. 
* Check if the (operations are not blocking)[https://dev.mysql.com/doc/refman/8.0/en/innodb-online-ddl-operations.html] for INPLACE, INSTANT, or COPY. 
* Test all changes on a staging server which has the same schema and at least 90% of the same amount of data.
* Execute as :
    * Call the file with commands as "schema_changes.sql"
        * mkdir -p tickets
        * example script:
    * NOTE: If an error occurs, it will continue.	
```shell
tee tickets/TICKET-NO.output
create database if not exists test1;
use test1;

drop table if exists table3; -- This is dangerous for production.
drop table if exists table300;

create table if not exists table3 (i int, PRIMARY KEY (i));
alter table table3 add column   i5 int, ALGORITHM=INPLACE, LOCK=SHARED;

-- This should abort if done on command line, otherwise table 300 will exist if sourced in mysqlshell. 
create table  table3 (i int, PRIMARY KEY (i));
create table  table300 (i int, PRIMARY KEY (i));
show tables;

```

* Log into mysql : mysql -vvv -u USER -p<PASSWORD> DATABASE
    * Make sure you use -vvv option
    * example : mysql -vvv -u mark -pmark test1  
    * In MySQL shell :

```shell
tee tickets/TICKET-NO.output
source schema_changes.sql
```

    * Or make it so it aborts if any errors occur
        * mkdir -p tickets
        * mysql -vvv -u USER -P<PASSWORD> DATABASE -e "source schema_changes.sql"
            * ex: mysql -vvv -u mark -pmark test1 -e "source schema_changes.sql" 2> tickets/TICKET-NO.error
                 * mysql -vvv -u mark -pmark test1 -e "show tables" 2>&1 | grep -v Password



* Write up your ticket and make a plan for the changes. Notify parties involved and make a meeting if necessary. Verify with the software developers
that the changes are backwards compatible to the software. Include a backout plan if things go wrong. Give yourself twice as much time
as you think you need. Four times it took in staging.
* When you start the meeting at a particular time for the changes
    * Note the time will be about double what it took in staging. This is because of activity. But schedule the time twice that in case you have issues. 
    * Execute as in staging. Use the same exact script. There should be no "drop table" in the script, unless you really want it there. 
    * If everything went as planned record the output in your ticket and close ticket.
    * Otherwise perform backout plan. It may be as simple as finishing it at another time.



* * *
<a name=pt></a>PT Online Schema Change
-----
Online PT Schema Change is a tool created by Percona to do nonblocking schema changes in MySQL.
changes the schema of a table without blocking (barely so). The approximate sequence of events are:

* New table is created
* triggers for insert, update, and delete are made from the old table to the new table. While the new table is being created, changes to
the old tables are being copied to the new table. Thus, is not blocking.
* When the new table is done, a brief lock occurs and the tables are switched,
* Triggers are dropped at some point.
* The old table is dropped, but you can make it so it won't drop. 

To get rid of the password warning not to use password on command line, we will add " 2>&1 | grep -v password " after each mysql command.
Example commands:
```sql
  # install pt schema chamge
sudo apt-get install percona-toolkit

  # Lets assume user is 'mark', passsword is 'mark'
mysql -u mark -pmark -e 'create database if not exists test1;'  2>&1 | grep -v password
mysql -u mark -pmark -e 'create table if not exists table1 (i int, PRIMARY KEY (i))' test1     2>&1 | grep -v password

  # Now the pt command
  # Do a dry run
pt-online-schema-change --dry-run --alter "add column i2 int" D=test1,t=table1,u=mark,p=mark
mysql -u mark -pmark -e 'show create table table1\G' test1 2>&1 | grep -v password

  # Now execute for real
pt-online-schema-change --execute --progress --alter "add column i2 int" D=test1,t=table1,u=mark,p=mark
mysql -u mark -pmark -e 'show create table table1\G' test1 2>&1 | grep -v password
  

```
NOTES:
1. Tables must have primary key setup or you can't use it on the table.
2. The tool will abort if load or other max statistic is reached. Check out the options if this happens. Increase the maximums. 
3. Use --dry-run beforehand to test the procedure.
4. For big tables, use --analyze-before-swap
5. Use --progress so it gives you a message about the progress of the changes. 

* * *
<a name=pttech></a>PT Technique
-----


* Verify all tables changing have primary keys.
* Test all changes on a staging server which has the same schema and at least 90% of the same amount of data.
* Run through the whole procedure and note the time.
    * First use --dry-run on staging server to see if there are any errors.
    * Then use --progress and --execute.
    * Note the time to change. Double the time for production as a rule of thumb.
* Write up your ticket and make a plan for the changes. Notify parties involved and make a meeting if necessary. Verify with the software developers
that the changes are backwards compatible to the software. Include a backout plan if things go wrong. Give yourself twice as much time
as you think you need. Four times it took in staging. 
* When you start the meeting at a particular time for the changes
    * Note the time will be about double what it took in staging. This is because of activity. But give ourself double that amount of time in case there are issues. 
    * Perform steps with dry-run.
    * If everything looks good, --progress and --execute.
    * If it aborts to load or too many resources being used
        * get approval to do it again and increase the maximum thresholds
    * If everything went as planned record the output in your ticket and close ticket. 
    * Otherwise perform backout plan. It may be as simple as finishing it at another time.

* * *
<a name=cloud></a>Cloud
-----

For the cloud check out the cloud provider notes:

* [AWS](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.Managing.FastDDL.html)
    * [Old article using PT Schema Change on AWS](https://medium.com/@soomiq/altering-large-mysql-table-using-percona-toolkit-on-aws-aurora-acb6e57a33d4)
* GCP should be 8.0 compatible and PT Schema Change should also be usable.
* Azure should be
    * 8.0 compatible
    * Use [Ghost](https://techcommunity.microsoft.com/t5/azure-database-for-mysql-blog/performing-online-schema-changes-in-azure-database-for-mysql-by/ba-p/3075844)
    * PT Schema change should also work. 

