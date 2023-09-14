

Snowflake Python
- python and sql datatypes
  - https://docs.snowflake.com/en/developer-guide/udf/python/udf-python-designing.html#label-sql-python-data-type-mappings

Snowflake recently introduced Event Tables.  This allows python developers to log errors. 

- Links
  - snowflake Python sandbox -- explanation
  - UDF
  - Event tables
  - Python regular expressions and snowflake regular expressions

- Purpose
  - Create an event table for writing log messages. 
  - Create simple Python UDF in a Python sandbox and modify it to write messages to log table. 
  - Modify Python UDF to support non greedy regular expressions since Snowflake is greedy. 
  - Show Python script usage. 
  - Demonstrate Python errors in the sandbox being logged to event table. 

- Steps
  - In Snowflake you are going to create a Python UDF (python function in snowflake). 
  - Make simple Snowflake UDF (function) that returns hello and execute it. This is just a sanity check to create a UDF. 
  - Create event table for recording log messages by a UDF. 
  - Update the UDF and make it write logs to the event table. 
  -  Execute function. Function uses the defined logger to send messages to the events table. 
  - Demonstrate capturing of errors
     - Update UDF in a real scenario
       - Attempt tp write a file to a read only area and capture the error.
     - Execute function. 
     - Look at events table. 
  - Since Snowflake regular expressions are greedy, here is an example of a python UDF that is not greedy.
    - Make python UDF. 
    - Show SQL and UDF examples. 
  - Tying it together
    - Run the UDF so it errors out. 
    - Look at exceptions table. 
    - Look at events table.

#  python basics

- handler
    - The handler is a function implemented inside a user-supplied module.
    - The handler is called once for each row passed to the Python UDF
    - for read-only shared state initialize it in the module instead of the handler function.
    - Relying on state shared between invocations can result in unexpected behavior,


# simple function


```sql

CREATE OR REPLACE FUNCTION pyudf()
  returns TEXT
  language python
  runtime_version = '3.10'
  handler = 'main'
as
$$
def main():
  return 'hello'
$$
;

DESCRIBE FUNCTION pyudf();
select pyudf();

```


# Add Logging 

It is often necessary to have a place to log events in the python code. Since the python environment is temporary, create an event table for this purpose.
Then use python native logging facilities to log events.

## Event Table

An event table is a specialized table in snowflake with a predefined structure that can capture log and trace events from udfs, udtfs, and store procedures.

https://docs.snowflake.com/developer-guide/logging-tracing/event-table-columns#label-event-table-schema-data-logs


### Create Event Table

The ACCOUNTADMIN role is needed to execute this. An account can only have 1 active event table. When executing commands, creating the database, schema, and table must be done one at  a time.

Create database. 
```sql
create database tutorial;
```
Create Schema. 

```sql
create schema tutorial.test;
```
Create Event table.

```sql
CREATE EVENT TABLE tutorial.test.pyudf_log;
```
The rest of the commands. 
```sql
-- set active event table
ALTER ACCOUNT SET EVENT_TABLE = tutorial.test.pyudf_log;
alter ACCOUNT set log_level = INFO;
alter ACCOUNT set trace_level = ON_EVENT;
SHOW PARAMETERS LIKE 'event_table' IN ACCOUNT;
SHOW EVENT TABLES;

```

### Write to Event table

To update the python function for logging, use the logging module.  When you create a logger, the name used will show up in SCOPE column in the event table.


```sql
CREATE OR REPLACE FUNCTION pyudf()
  returns TEXT
  language python
  runtime_version = '3.10'
  handler = 'main'
as
$$
import logging
logger = logging.getLogger('pyudf')

def main():
    logger.info('test event info')
    logger.error('test event error')
    logger.debug('test event debug')
    return 'logged'
$$
;
```

### show log entries

Notice that since the log level is set to INFO, the debug messages do not show up.

```sql
select pyudf();
-- wait a minute

--select all records
select * from tutorial.test.pyudf_log;
--limit to pyudf
select * from tutorial.test.pyudf_log where SCOPE:name='pyudf' order by OBSERVED_TIMESTAMP DESC;

```


# Explore Python environment

Snowflake creates a restricted python sandbox that runs in Snowflake's compute infrastructure.
Below is a python udf that explores the environment a little bit and writes an error to the event table.
Running the code should show

- The environment runs with  'USER': 'udf' and 'HOME': '/home/udf'
- /home/udf and /tmp directories empty with each invocation.
- only /tmp is writeable
- an error shows up in the event table with an error about Read-only file system: '/home/udf/text.txt'


The following sql will show an exceptions caught and logged by python udf.

```sql
select RECORD
    ,RECORD_ATTRIBUTES:"code.function",RECORD_ATTRIBUTES:"exception.stacktrace"
    from tutorial.test.pyudf_log 
    where SCOPE:name='pyudf' and RECORD_ATTRIBUTES:"exception.stacktrace" is not null
    order by OBSERVED_TIMESTAMP DESC;
```


The following sql will show an exceptions caught and logged by python udf.


```sql
CREATE OR REPLACE FUNCTION pyudf()
  returns ARRAY
  language python
  runtime_version = '3.10'
  handler = 'main'
as
$$
import logging,os
from pathlib import Path

logger = logging.getLogger('pyudf')

def main():

    pyenv=[]
    logger.info('starting')
    env=str(os.environ)
    
    home=Path(os.environ['HOME'])
    homefiles=str(list(home.rglob('*')))
    tmp=Path('/tmp')
    tmpfiles=str(list(tmp.rglob('*')))

    tmpfile=tmp/'text.txt'
    homefile=home/'text.txt'

    try:
        tmpfile.write_text('test write to tmpfile')
        homefile.write_text('test write to home')
    except:
        logger.exception('got an error')

    data='writes:'
    if tmpfile.exists(): data+= tmpfile.read_text()
    if homefile.exists(): data+= homefile.read_text()

    return [env,homefiles,tmpfiles,data]
$$;

```


# Python UDF for non-greedy regex

Snowflake SQL supports several regular expression functions but they are limited in that the regex are "greedy" which means they will attempt to match as much as possible.
If non-greedy regex is required one create a python udf to get around this limitation.

Create the python udf below and compare the results with regexp_substr. Snowflake remains greedy while the python udf does not.

Create the following

```sql
CREATE OR REPLACE FUNCTION pyudf(data text,regex text)
  returns TEXT
  language python
  runtime_version = '3.10'
  handler = 'main'
as
$$
import logging, re

logger = logging.getLogger('pyudf')

def main(data,regex):
    try:
        result=re.search(regex, data).group(0)
        return result
    except:
        logger.exception('got an error')
        raise
$$;
    

select  regexp_substr('The quick brown fox plays in kentucky','q.*k' ) as result;
select  regexp_substr('The quick brown fox plays in kentucky','q.*?k' ) as result;
select  pyudf('The quick brown fox plays in kentucky','q.*k' ) as result;
select  pyudf('The quick brown fox plays in kentucky','q.*?k' ) as result;

Make the function error out. 
select  pyudf('The quick brown fox plays in kentucky','[[[&lt;&lt;&lt;****' ) as result;


```

