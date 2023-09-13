

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

The ACCOUNTADMIN role is needed to execute this. An account can only have 1 active event table.

```sql
create database tutorial;
create schema tutorial.test;
CREATE EVENT TABLE tutorial.test.pyudf_log;
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

TODO: execute function
TODO: view events table
TODO: look at events caught with eception. 

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




## RESPONSE 2

Certainly, I've improved the document by enhancing its readability and flow. Here's the refined version:

---

**Snowflake Python: A Comprehensive Guide**

**Introduction**

In this guide, we'll explore the integration of Python and SQL within the Snowflake data warehouse platform. Specifically, we'll delve into Python User-Defined Functions (UDFs) and Snowflake's recent introduction of Event Tables, a powerful feature for logging errors in Python scripts.

**Useful Links**

Before we begin, here are some important resources for reference:

* [SQL to Python Data Type Mappings](https://docs.snowflake.com/en/developer-guide/udf/python/udf-python-designing.html#label-sql-python-data-type-mappings)
* Snowflake Python Sandbox (Explanation)
* User-Defined Functions (UDF)
* Event Tables
* Python Regular Expressions and Snowflake Regular Expressions

**Purpose**

Our objectives for this guide include:

1. Creating an event table for recording log messages.
2. Developing a simple Python UDF within a Python sandbox and modifying it to write messages to the log table.
3. Enhancing the Python UDF to support non-greedy regular expressions, addressing Snowflake's inherent greediness.
4. Demonstrating Python script usage.
5. Showcasing how Python errors in the sandbox can be logged to the event table.

**Step-by-Step Instructions**

Let's break down the steps involved in achieving our objectives:

1. Create a Python UDF (Python function) in Snowflake.
2. Develop a basic Snowflake UDF that returns "hello" and execute it to verify UDF creation.
3. Establish an event table for recording log messages generated by a UDF.
4. Update the UDF to include log writing capabilities for the event table.
5. Execute the modified function, which will use the defined logger to send messages to the events table.
6. Demonstrate error capturing:
   * Modify the UDF in a real scenario, attempting to write a file to a read-only area, and capture the error.
   * Execute the function.
   * Inspect the events table.
7. Address Snowflake's greedy regular expressions with a Python UDF that is not greedy.
   * Create a Python UDF.
   * Provide SQL and UDF examples.
8. Tie everything together:
   * Execute the UDF to trigger an error.
   * Examine the exceptions table.
   * Review the events table.

**Python Basics**

Before we dive into the specific steps, let's cover some essential Python basics related to Snowflake UDFs:

* **Handler**: The handler is a function implemented inside a user-supplied module and is called once for each row passed to the Python UDF. For read-only shared state, initialize it in the module rather than the handler function to avoid unexpected behavior.

**Creating a Simple Function**

Here's an example of creating a simple Snowflake UDF:

```sql
CREATE OR REPLACE FUNCTION pyudf()
  RETURNS TEXT
  LANGUAGE PYTHON
  RUNTIME_VERSION = '3.10'
  HANDLER = 'main'
AS
$$
def main():
  return 'hello'
$$
;

-- Describe the function
DESCRIBE FUNCTION pyudf();

-- Execute the function
SELECT pyudf();
```

**Adding Logging**

Logging is often necessary in Python code. To log events within the Python environment in Snowflake, we'll create an event table for this purpose. We'll then use Python's native logging facilities.

**Event Table**

An event table is a specialized table in Snowflake designed to capture log and trace events from UDFs, UDTFs, and stored procedures. [Learn more about event table columns](https://docs.snowflake.com/developer-guide/logging-tracing/event-table-columns#label-event-table-schema-data-logs).

**Creating the Event Table**

To create an event table, you'll need the ACCOUNTADMIN role, and each account can have only one active event table:

```sql
CREATE DATABASE tutorial;
CREATE SCHEMA tutorial.test;
CREATE EVENT TABLE tutorial.test.pyudf_log;
-- Set the active event table
ALTER ACCOUNT SET EVENT_TABLE = tutorial.test.pyudf_log;
ALTER ACCOUNT SET LOG_LEVEL = INFO;
ALTER ACCOUNT SET TRACE_LEVEL = ON_EVENT;
-- Show event table parameters
SHOW PARAMETERS LIKE 'event_table' IN ACCOUNT;
SHOW EVENT TABLES;
```

**Writing to the Event Table**

To update the Python function for logging, we'll use the logging module. The name used for the logger will appear in the SCOPE column in the event table:

```sql
CREATE OR REPLACE FUNCTION pyudf()
  RETURNS TEXT
  LANGUAGE PYTHON
  RUNTIME_VERSION = '3.10'
  HANDLER = 'main'
AS
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

-- Show log entries
SELECT pyudf();
-- Wait a minute

-- Select all records
SELECT * FROM tutorial.test.pyudf_log;
-- Limit to pyudf
SELECT * FROM tutorial.test.pyudf_log WHERE SCOPE:name='pyudf' ORDER BY OBSERVED_TIMESTAMP DESC;
```

**Exploring the Python Environment**

Snowflake creates a restricted Python sandbox within its compute infrastructure. We can explore this environment using a Python UDF and capture errors in the event table:

```sql
SELECT RECORD
    ,RECORD_ATTRIBUTES:"code.function",RECORD_ATTRIBUTES:"exception.stacktrace"
    FROM tutorial.test.pyudf_log 
    WHERE SCOPE:name='pyudf' AND RECORD_ATTRIBUTES:"exception.stacktrace" IS NOT NULL
    ORDER BY OBSERVED_TIMESTAMP DESC;
```

**Python UDF for Non-Greedy Regex**

Snowflake SQL supports regular expressions, but they are "greedy," meaning they match as much as possible. To work with non-greedy regex, we can create a Python UDF:

```sql
CREATE OR REPLACE FUNCTION pyudf(data TEXT, regex TEXT)
  RETURNS TEXT
  LANGUAGE PYTHON
  RUNTIME_VERSION = '3.10'
  HANDLER = 'main'
AS
$$
import logging, re

logger = logging.getLogger('pyudf')

def main(data, regex):
    try:
        result = re.search(regex, data).group(0)
        return result
    except:
        logger.exception('got an error')
        raise
$$;

-- Examples comparing greedy and non-greedy regex
SELECT  regexp_substr('The quick brown fox plays in Kentucky', 'q.*k' ) AS result;
SELECT  regexp_substr('The quick brown fox plays in Kentucky', 'q.*?k' ) AS result;
SELECT  pyudf('The quick brown fox plays in Kentucky', 'q.*k' ) AS result;
SELECT  pyudf('The quick brown fox plays in Kentucky', 'q.*?k' ) AS result;

-- Trigger an error
SELECT  pyudf('The quick brown fox plays in Kentucky', '[[[<<<****' ) AS result;
```

---



