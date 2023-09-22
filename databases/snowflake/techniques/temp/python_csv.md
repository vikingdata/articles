---
title : Easy Loading CSV with SnowflakeUsing Python
author : Mark Nielsen
copyright : copyright Sept, 2023
---

Easy Loading CSV with SnowflakeUsing Python
==============================

_**by Mark Nielsen
Original Copyright Jan 2022**_


1.  [Links](#links)
2.  [Load csv file with Python(#load)
3.  [Python Methods](#method)
4.  [Loading different files](#files)

* * *

<a name=links></a>Links
-----


* * *

# <a name=load></a>Load csv file with python
-----



In the June 2023 release Snowflake introduced schema inference for csv files.
https://docs.snowflake.com/release-notes/2023-06#schema-detection-for-json-and-csv-preview

This is done with the Data Loading Table Function INFER_SCHEMA.
https://docs.snowflake.com/en/sql-reference/functions/infer_schema

There is also a helpful metadata function called generate_column_description
https://docs.snowflake.com/en/sql-reference/functions/generate_column_description


# Create CSV

Create an example customer.csv file like the following.  This example has different types
of data which will be inferred by INFER_SCHEMA.

```
customer_id,name,email,phone,age,balance,premium,join_date
1001,John Smith,john.smith@example.com,555-1234,35,1200.50,true,2021-01-15
1002,Jane Doe,jane.doe@example.com,555-4321,28,800.75,false,2021-02-10
1003,Bob Lee,bob.lee@example.com,555-6789,42,1500.00,true,2021-03-01
1004,Alice Maple,alice.maple@example.com,555-9876,32,900.25,false,2021-04-05
```

# Step by Step with Snowsight

## Load into Stage

```sql
use schema TUTORIAL.TEST;
CREATE OR REPLACE FILE FORMAT basic_csv TYPE = csv PARSE_HEADER = true;
CREATE STAGE load DIRECTORY = ( ENABLE = true );
```

Data -> Databases->Tutoral->Test->Stages->LOAD->Files (upper right)
Then drag and drog csv and click Upload.
In a few moments the file should be loaded into the Stage.

## Load into Table

### INFER_SCHEMA
Verify schema can be inferred from csv by executing following command.
Several datatypes should be inferred TEXT,NUMBER,BOOLEAN,DATE

```sql
SELECT * FROM TABLE (INFER_SCHEMA(LOCATION => '@~/customer.csv', FILE_FORMAT => 'basic_csv'));
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

### CREATE Table
```sql
CREATE or REPLACE TABLE mytable USING TEMPLATE (
  SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
  FROM TABLE (
    INFER_SCHEMA(
      LOCATION=>'@~/customer.csv',
      FILE_FORMAT=>'basic_csv'
    )
  )
);
```

* * *

<a name=method></a>Load csv file with python
-----


# Python Program to match manual load

This program program roughly follow the steps that was manually run earlier.

```python
# Create a connection object
ctx = snowflake.connector.connect(
    user='XXXXXXX',
    password='YYYYYY',
    account='AAAAA-BBBBBB',
    warehouse='compute_wh',
    database='tutorial',
    schema='test'
    )

# Create a cursor object
cur = ctx.cursor(DictCursor)

# Stage file
result=cur.execute("PUT file:///c:/temp/customer.csv @~/").fetchall()[0]
print(result)

# Create a file format object
result=cur.execute("CREATE OR REPLACE FILE FORMAT basic_csv TYPE = csv PARSE_HEADER = true").fetchall()[0]
print(result)

# Show inferred schema
sql = "SELECT * FROM TABLE (INFER_SCHEMA(LOCATION => '@~/customer.csv', FILE_FORMAT => 'basic_csv'))"
result=cur.execute(sql).fetchall()[0]
print(result)

# Useful for MANUAL creation
sql = '''SELECT GENERATE_COLUMN_DESCRIPTION(ARRAY_AGG(OBJECT_CONSTRUCT(*)), 'table') 
    AS columns FROM TABLE (INFER_SCHEMA(LOCATION => '@~/customer.csv', FILE_FORMAT => 'basic_csv'))
'''
result=cur.execute(sql).fetchall()[0]
print(result)

# Automatic creation with TEMPLATE
sql ='''
CREATE or REPLACE TABLE mytable USING TEMPLATE (
  SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
  FROM TABLE (
    INFER_SCHEMA(
      LOCATION=>'@~/customer.csv',
      FILE_FORMAT=>'basic_csv'
    )
  )
)
'''
result=cur.execute(sql).fetchall()[0]
print(result)

sql = """select get_ddl('table', 'mytable')"""
result=cur.execute(sql).fetchall()[0]
print(result)
```

* * *

<a name=method></a>Python Methods
-----
Ideally, if used many times, we would want to make Python methods for this. 


# Updated Python Program

This program program provides a rough general template for loading csv files. 
It could be incorporated with Streamlit to further enhance the loading process.

```python
from pathlib import Path


import snowflake.connector
from snowflake.connector.cursor import DictCursor


def stage_csv(cur,fpath,stage='@~/'):
    ''' could check for status of SKIPPED or UPLOADED '''
    result=cur.execute(f"PUT file:///{fpath} {stage}").fetchall()[0]
    print(f"STAGED {fpath} to {stage} {result['status']}")

def load_table(cur,fname,table,stage='@~'):

    sql="CREATE OR REPLACE FILE FORMAT basic_csv TYPE = csv PARSE_HEADER = true"
    result=cur.execute(sql).fetchall()


    sql = '''SELECT GENERATE_COLUMN_DESCRIPTION(ARRAY_AGG(OBJECT_CONSTRUCT(*)), 'table') 
        AS columns FROM TABLE (INFER_SCHEMA(LOCATION => '@~/customer.csv', FILE_FORMAT => 'basic_csv'))
    '''

    print('Using following inferred schema:')
    result=cur.execute(sql).fetchall()[0]
    print(result['COLUMNS'])

    sql =f'''
    CREATE or REPLACE TABLE {table} USING TEMPLATE (
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

def connect():
    # Create a connection object
    ctx = snowflake.connector.connect(
        user='XXXXXXX',
        password='YYYYYY',
        account='AAAAA-BBBBBB',
        warehouse='compute_wh',
        database='tutorial',
        schema='test'
        )

    # Create a cursor object
    cur = ctx.cursor(DictCursor)

    return ctx,cur

def main():
    ctx,cur=connect()
    csv_path=Path('c:/temp/customer2.csv')

    stage_csv(cur,csv_path,stage='@~/')       
    load_table(cur,csv_path.name,csv_path.stem)

if __name__=='__main__':
    main()
```


* * *

<a name=files></a>Loading different files
-----
