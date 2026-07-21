#!/usr/bin/python

import mysql.connector
import snowflake.connector
import sys
import os
import time


"""
Snowflake and mysql shell variables must exist before running this script. 

export SF_USER="your_user"
export SF_PASS="your passsword"
export SF_ACCOUNT=""

export M_USER="your mysql user"
export M_PASS="your mysql password"

export M_DB="mark1"
# Default mark1

export M_TABLE="t1"
# Default t1

export M_HOST="mysql server"
# Default 127.0.0.1

export M_PORT=3306
# Default 3306
"""

vars = os.environ

for sv in ('SF_USER', 'SF_PASS', 'SF_ACCOUNT','M_USER', 'M_PASS'):
  if sv not in vars:
    print (sv + ' not defined in env, exiting.\n')
    sys.exit()

M_DB    ="mark1"
M_TABLE ="t1"
M_HOST  ="127.0.0.1"
M_PORT  =3306

if "M_HOST"  in vars : M_HOST = vars['M_HOST']
if "M_PORT"  in vars : M_PORT = vars['M_PORT']
if "M_DB"    in vars : M_DB = vars['M_DB']
if "M_TABLE" in vars : M_TABLE = vars['M_TABLE']

print ("connecting to mysql")

conn = mysql.connector.connect(
    host     = M_HOST,
    user     = vars['M_USER'],
    password = vars['M_PASS'],
    database = M_DB,
    port     = M_PORT
)
m_cursor = conn.cursor()
print ("connected to mysql")

print ("connecting to snowflake")
# Create a snowflake connection object
sf= snowflake.connector.connect(
    user       = vars['SF_USER'],
    password   = vars['SF_PASS'],
    account    = vars['SF_ACCOUNT'],
    warehouse  = 'compute_wh',
    database   = 'sampledb',
    schema     = 'PUBLIC'
    )
sf_cursor = sf.cursor()
print ("connected to snowflake")

# Select all rows from table "t1"
# If we do this properly, we seelect the max primary key or count the rows and do it in batches of 500 rows.
# In this case, table is small

m_cursor.execute("select * from t1")
m_rows = m_cursor.fetchall()


# Create the target table in snowflake
sf_table_create = """ create or replace table t1_python (
a int NOT NULL, ni int, i int, d datetime, t timestamp, v varchar(255), nc char(8) NOT NULL
);"""

sf_cursor.execute(sf_table_create )
start_time = time.time()
print ("Uploading rows")

# insert all rows
sf_insert_many = " insert into t1_python (a, ni, i, d, t, v, nc) values (%s, %s, %s, %s, %s, %s, %s )"
sf_cursor.executemany( sf_insert_many, m_rows)

end_time = time.time()
print ("length of time:", end_time - start_time)

print ("Counting rows in t1_python")
# count rows in table
sf_cursor.execute('select count(1) from t1_python')
print ("Rows in t1_python: ", sf_cursor.fetchone()[0])


