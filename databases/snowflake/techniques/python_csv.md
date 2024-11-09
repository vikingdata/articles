---
title : Easy Loading CSV with Snowflake Using Python
author : Mark Nielsen
copyright : copyright Jan, 2022
---

Easy Loading CSV with Snowflake Using Python
==============================

_**by Mark Nielsen
Original Copyright Jan 2022**_


1.  [Setup](#setup)
2.  [Install Python connector](#installpython)
3.  [Load csv file with Python](#python)
4.  [Python Methods](#method)




* * *

# <a name=setup></a>Setup
-----



In the June 2023 release Snowflake introduced schema inference for csv files.
https://docs.snowflake.com/release-notes/2023-06#schema-detection-for-json-and-csv-preview

This is done with the Data Loading Table Function INFER_SCHEMA.
https://docs.snowflake.com/en/sql-reference/functions/infer_schema

There is also a helpful metadata function called generate_column_description
https://docs.snowflake.com/en/sql-reference/functions/generate_column_description


## Create CSV

Create an example customer.csv file like the following.  This example has different types
of data which will be inferred by INFER_SCHEMA. Create a duplicate file called "customer2.csv".

```
customer_id,name,email,phone,age,balance,premium,join_date
1001,John Smith,john.smith@example.com,555-1234,35,1200.50,true,2021-01-15
1002,Jane Doe,jane.doe@example.com,555-4321,28,800.75,false,2021-02-10
1003,Bob Lee,bob.lee@example.com,555-6789,42,1500.00,true,2021-03-01
1004,Alice Maple,alice.maple@example.com,555-9876,32,900.25,false,2021-04-05
```

## Step by Step with Snowsight

TODO : use worksheet

In this section, we will use a worksheet. 

### Load into Stage

TODO: start workspace

```sql
create database if not exists TUTORIAL;
use TUTORIAL;
create schema if not exists TEST;

use schema TUTORIAL.TEST;
CREATE OR REPLACE FILE FORMAT basic_csv TYPE = csv PARSE_HEADER = true;
CREATE STAGE load DIRECTORY = ( ENABLE = true );
```

Data -> Databases->Tutoral->Test->Stages->LOAD->Files (upper right)
Then drag and drog csv and click Upload.
In a few moments the file should be loaded into the Stage.

### Load into Table

#### INFER_SCHEMA
Verify schema can be inferred from csv by executing following command.
Several datatypes should be inferred TEXT,NUMBER,BOOLEAN,DATE

```sql
SELECT * FROM TABLE (INFER_SCHEMA(LOCATION => '@LOAD/customer.csv', FILE_FORMAT => 'BASIC_CSV'));
```

Expected results

```
COLUMN_NAME	TYPE	NULLABLE	EXPRESSION	FILENAMES	ORDER_ID
customer_id	NUMBER(4, 0)	TRUE	$1::NUMBER(4, 0)	@~/customer.csv.gz	0
name	TEXT	TRUE	$2::TEXT	@~/customer.csv.gz	1
email	TEXT	TRUE	$3::TEXT	@~/customer.csv.gz	2
phone	TEXT	TRUE	$4::TEXT	@~/customer.csv.gz	3
age	NUMBER(2, 0)	TRUE	$5::NUMBER(2, 0)	@~/customer.csv.gz	4
balance	NUMBER(6, 2)	TRUE	$6::NUMBER(6, 2)	@~/customer.csv.gz	5
premium	BOOLEAN	TRUE	$7::BOOLEAN	@~/customer.csv.gz	6
join_date	DATE	TRUE	$8::DATE	@~/customer.csv.gz	7
```

#### CREATE Table
```sql
CREATE or REPLACE TABLE mytable USING TEMPLATE (
  SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
  FROM TABLE (
    INFER_SCHEMA(
      LOCATION=>'@LOAD/customer.csv',
      FILE_FORMAT=>'BASIC_CSV'
    )
  )
);
```

#### Select data for verification
TODO

* * *

# <a name=installpython></a>Install Python connector
-----


* pip install snowflake-connector-python

In addition, I had to
*  pip3 uninstall pyarrow
* sudo  pip3 uninstall pyarrow
* sudo  pip3 install pip3 install pyarrow==10.0.1

* * *

# <a name=python></a>Load csv file with Python
-----


## Python Program to match manual load
This program roughly follow the steps that was manually run earlier.


```python

import snowflake.connector
from snowflake.connector import DictCursor
import sys
import os

vars = os.environ

TABLENAME="TUTORIAL.TEST.MY_TABLE"

if 'SF_USER' not in vars:
    print ('SF_USER not defined in env, exiting.\n')
    sys.exit()

if not 'SF_PASS' in vars:
    print ('SF_PASS not defined in env, exiting.\n')
    sys.exit()

if vars.get("SF_ACCOUNT") is None:
    print ('SF_ACCOUNT not defined in env, exiting.\n')
    sys.exit()


# Create a connection object
ctx = snowflake.connector.connect(
    user=vars['SF_USER'],
    password=vars['SF_PASS'],
    account=vars['SF_ACCOUNT'],
    warehouse='compute_wh',
    database='tutorial',
    schema='test'
    )


# Create a cursor object
cur = ctx.cursor(DictCursor)

# Stage file
# Windows
#result=cur.execute("PUT file:///c:/temp/customer.csv @~/").fetchall()[0]
#print(result)



try :
    result=cur.execute("REMOVE @~/customer.csv").fetchall()[0]
    print(result)
except:
    print ("customer.csv doesn't exist, that is ok, not removed.")

# Linue
result=cur.execute("PUT file://customer.csv @~/ AUTO_COMPRESS = FALSE").fetchall()[0]
print(result)

FF_options = " SKIP_HEADER=0 FIELD_DELIMITER=',' FIELD_OPTIONALLY_ENCLOSED_BY=NONE TYPE=csv PARSE_HEADER=true"

# Create a file format object
result=cur.execute("CREATE OR REPLACE FILE FORMAT basic_csv " + FF_options).fetchall()[0]
print(result)

# IF this errors out, you might have an empty line at the beginning ot end of the file.
# Make sure there are no empty lines.
# Show inferred schema
sql = "SELECT * FROM TABLE (INFER_SCHEMA(LOCATION => '@~/customer.csv', FILE_FORMAT => 'BASIC_CSV'))"
result=cur.execute(sql).fetchall()[0]
print(result)

# Useful for MANUAL creation
sql = '''SELECT GENERATE_COLUMN_DESCRIPTION(ARRAY_AGG(OBJECT_CONSTRUCT(*)), 'table')
    AS columns FROM TABLE (INFER_SCHEMA(LOCATION => '@~/customer.csv', FILE_FORMAT => 'BASIC_CSV'))
'''
result=cur.execute(sql).fetchall()[0]
print(result)


# Automatic creation with TEMPLATE
# INNER_SCHMEA only deal with columns, not data
sql ="""
CREATE or REPLACE TABLE """ + TABLENAME + """ USING TEMPLATE (
  SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
  FROM TABLE (
    INFER_SCHEMA(
      LOCATION=>'@~/customer.csv',
      FILE_FORMAT=>'BASIC_CSV'
    )
  )
)
"""
result=cur.execute(sql).fetchall()[0]
print(result)

sql = """select get_ddl('table', '""" + TABLENAME + """')"""
result=cur.execute(sql).fetchall()[0]
print(result)

FF_options = " SKIP_HEADER=1 FIELD_DELIMITER=',' FIELD_OPTIONALLY_ENCLOSED_BY=NONE TYPE=csv "

# Create a file format object
result=cur.execute("CREATE OR REPLACE FILE FORMAT load_csv " + FF_options).fetchall()[0]
print(result)


sql = """COPY INTO """ + TABLENAME + """
FROM '@~'
FILES = ('customer.csv')
FILE_FORMAT = 'load_csv'
ON_ERROR=ABORT_STATEMENT
PURGE=TRUE;"""

result=cur.execute(sql).fetchall()[0]
print (result)

result=cur.execute(sql).fetchall()[0]
print (result)
JOB_ID = result['ID']
print ("job id is " + str(JOB_ID))

## now validate.
sql = "SELECT * FROM TABLE(VALIDATE(" + TABLENAME + ", JOB_ID=>'" + JOB_ID + "'));"
print (sql)
result=cur.execute(sql).fetchall()
## If nothing is returned, then no errors. 
print (result)


sql = "select count(1) from " + TABLENAME
result=cur.execute(sql).fetchall()[0]
print (result)

### If everything worked out, you should get a count of 4


````

* * *

# <a name=method></a>Python methods
-----


## Updated Python Program

This program program provides a rough general template for loading csv files. 
It could be incorporated with Streamlit to further enhance the loading process.

```python


from pathlib import Path


import snowflake.connector
from snowflake.connector.cursor import DictCursor

import os

vars = os.environ

if 'SF_USER' not in vars:
    print ('SF_USER not defined in env, exiting.\n')
    sys.exit()

if not 'SF_PASS' in vars:
    print ('SF_PASS not defined in env, exiting.\n')
    sys.exit()

if vars.get("SF_ACCOUNT") is None:
    print ('SF_ACCOUNT not defined in env, exiting.\n')
    sys.exit()


def stage_csv(cur,fpath,stage='@~/'):
    ''' could check for status of SKIPPED or UPLOADED '''
    result=cur.execute(f"PUT file:///{fpath} {stage}").fetchall()[0]
    print(f"STAGED {fpath} to {stage} {result['status']}")

def load_table(cur,fname,table,stage='@~'):


    sql = 'PUT file://' + table + '.csv @~/ AUTO_COMPRESS = FALSE'
#    print (sql)
    result=cur.execute(sql).fetchall()[0]
    print(result)


    sql="CREATE OR REPLACE FILE FORMAT basic_csv TYPE = csv PARSE_HEADER = true"
    result=cur.execute(sql).fetchall()
    print (result)

    sql = '''SELECT GENERATE_COLUMN_DESCRIPTION(ARRAY_AGG(OBJECT_CONSTRUCT(*)), 'table')
        AS columns FROM TABLE (INFER_SCHEMA(LOCATION => '@~/''' + table + '''.csv', FILE_FORMAT => 'basic_csv'))
    '''

    print('Using following inferred schema:')
    result=cur.execute(sql).fetchall()[0]
    print(result['COLUMNS'])

    sql =f'''
    CREATE or REPLACE TABLE TUTORIAL.TEST.{table} USING TEMPLATE (
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
    FROM TABLE (
        INFER_SCHEMA(
        LOCATION=>'{stage}/{fname}',
        FILE_FORMAT=>'basic_csv'
        )
    )
    )
    '''

    result=cur.execute(sql).fetchall()[0]
    print(f"LOADED {fname} to {result['status']}")


    FF_options = " SKIP_HEADER=1 FIELD_DELIMITER=',' FIELD_OPTIONALLY_ENCLOSED_BY=NONE TYPE=csv "

    # Create a file format object
    result=cur.execute("CREATE OR REPLACE FILE FORMAT load_csv " + FF_options).fetchall()[0]
    print(result)

    sql = """COPY INTO TUTORIAL.TEST.""" + table+ """
      FROM '@~'
      FILES = ('""" + table + """.csv')
      FILE_FORMAT = 'load_csv'
      ON_ERROR=ABORT_STATEMENT
      PURGE=FALSE;"""
    print (sql)

    result=cur.execute(sql).fetchall()[0]
    print (result)

    sql = "select count(1) from " + table
    result=cur.execute(sql).fetchall()[0]
    print (result)

def connect(vars=None):
    # Create a connection object
    ctx = snowflake.connector.connect(
       user=vars['SF_USER'],
       password=vars['SF_PASS'],
       account=vars['SF_ACCOUNT'],
        warehouse='compute_wh',
        database='tutorial',
        schema='test'
        )

    # Create a cursor object
    cur = ctx.cursor(DictCursor)

    return ctx,cur

def main(vars=None):
    ctx,cur=connect(vars=vars)
    csv_path=Path(vars['PWD'] + '/customer2.csv')

    stage_csv(cur,csv_path,stage='@~/')
    load_table(cur,csv_path.name,csv_path.stem)

if __name__=='__main__':
    main(vars=vars)



```



