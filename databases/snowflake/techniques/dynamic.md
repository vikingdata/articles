



# Introduction
A Snowflake dynamic table is a new type of table that switches from an imperative to declarative approach. This saves managing dependencies and scheduling and allows chaining together og multiple dynamic tables.

## Advantages of dynamic tables

- You can define the target table as a dynamic table with a SQL statement 
- You can specify the target lag of the dynamic table, which is the maximum amount of time that the data in the dynamic table can be behind the data in the source tables. 
- You can perform incremental or full refreshes of the dynamic table. 
-  One dynamic table as the source for another dynamic table


## Limitations of dynamic tables

- dynamic tables do not support: insert, update, or delete
- dynamic tables do not support all types of sql 
- https://docs.snowflake.com/en/user-guide/dynamic-tables-tasks-create#query-constructs-not-currently-supported-in-dynamic-tables

## Important notes on Dynamic tables
- Although you can't directly do data changes, a refresh does the data changes for you. 
- When the source table changes, the data is stale and should be refreshed. 
  - If you data need up to date, have it refresh automatically. 
  - If you just need data every 30 minutes, have it refresh every 30 minutes. 

# Summary of useful commands

### Dynamic Table management
- alter dynamic table CustomerPurchases refresh;
- alter dynamic table CustomerPurchases set target_lag='1 minute';
- alter dynamic table CustomerPurchases suspend;
- alter dynamic table CustomerPurchases resume;

### Dynamic Table Inquiry
- desc dynamic table CustomerPurchases;
- show dynamic tables like CustomerPurchases;
- select * from table(information_schema.dynamic_table_graph_history());
- select * from table(information_schema.refresh_history());

# DYNAMIC_TABLE_REFRESH_HISTORY Details

As described in the snowflake documentation the DYNAMIC_TABLE_REFRESH_HISTORY returns information about each refresh (completed and running) of dynamic tables. A refresh is an operation that updates the data in a dynamic table based on the changes in the source tables. A refresh can be triggered manually or automatically according to the target lag of the dynamic table.

The output of this function is a table with the following columns:

- **REFRESH_ACTION**: The type of refresh that was performed. Possible values are:
  - **INCREMENTAL**: The refresh only applied the changes that occurred in the source tables since the last refresh.
  - **FULL**: The refresh rebuilt the entire dynamic table from scratch based on the current state of the source tables.
- **REFRESH_TRIGGER**: The event that initiated the refresh. Possible values are:
  - **MANUAL**: The refresh was triggered by a user using the `ALTER DYNAMIC TABLE ... REFRESH` command.
  - **AUTOMATIC**: The refresh was triggered by the system based on the target lag of the dynamic table.
- **REFRESH_VERSION**: A unique identifier for each refresh. It is a timestamp in UTC that corresponds to the start time of the refresh.
- **REFRESH_STATUS**: The current status of the refresh. Possible values are:
  - **RUNNING**: The refresh is in progress and has not completed yet.
  - **SUCCESSFUL**: The refresh completed successfully and updated the dynamic table.
  - **FAILED**: The refresh failed due to an error and did not update the dynamic table.
- **REFRESH_ERROR_MESSAGE**: The error message that caused the refresh to fail, if any.
- **REFRESH_METRICS**: A JSON object that contains various metrics about the refresh, such as:
  - **numInsertedRows**: The number of rows that were inserted into the dynamic table during the refresh.
  - **numDeletedRows**: The number of rows that were deleted from the dynamic table during the refresh.
  - **numCopiedRows**: The number of rows that were copied unchanged during the refresh.
  - **numAddedPartitions**: The number of partitions that were added to the dynamic table during the refresh.
  - **numRemovedPartitions**: The number of partitions that were removed from the dynamic table during the refresh.


# Setup Tables

```sql
create database pytutorial
use schema pytutorial.public

CREATE or REPLACE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name TEXT(50),
    email TEXT(100)
);

INSERT INTO Customers (customer_id, customer_name, email)
VALUES
    (1, 'John Doe', 'john@example.com'),
    (2, 'Jane Smith', 'jane@example.com');

CREATE or REPLACE TABLE Purchases (
    purchase_id INT PRIMARY KEY,
    customer_id INT,
    product_name TEXT(100),
    purchase_date DATE,
    amount DECIMAL(10, 2)
);

INSERT INTO Purchases (purchase_id, customer_id, product_name, purchase_date, amount)
VALUES
    (1, 1, 'Product A', '2023-09-10', 50.00),
    (2, 1, 'Product B', '2023-09-11', 75.00),
    (3, 2, 'Product C', '2023-09-12', 60.00),
    (4, 1, 'Product A', '2023-09-13', 50.00),
    (5, 2, 'Product B', '2023-09-14', 75.00);


CREATE OR REPLACE DYNAMIC TABLE CustomerPurchases target_lag=downstream warehouse=compute_wh as
SELECT *
FROM
    Customers
JOIN
    Purchases  USING(customer_id);

```

# Test Dynamic Tables

## First Manual Refresh

When running the sequence of queries below, the first query fails fails because the table has not been refreshed yet.
A manual way to send data to the dynamic table is to use:  `ALTER DYNAMIC TABLE ... REFRESH` command. After that is run you will see 5 rows have been inserted and can query the table. You can use `INFORMATION_SCHEMA.DYNAMIC_TABLE_REFRESH_HISTORY` function to get information about the refresh actions and triggers for the dynamic table.

```sql
select * from CustomerPurchases; --
alter dynamic table CustomerPurchases refresh;
select * from CustomerPurchases;
select * from table(information_schema.dynamic_table_refresh_history());
```


## Send new data to the source table.

After inserting a new row into the Purchases table, the CustomerPurchases will not be updated until a refresh is done.
Then the table will show the new row and dynamic_table_refresh_history will show the new activity.

```sql
INSERT INTO Purchases (purchase_id, customer_id, product_name, purchase_date, amount)
VALUES (1, 1, 'Product C', '2023-09-15', 150.00);
select * from CustomerPurchases;  
alter dynamic table CustomerPurchases refresh;
select * from table(information_schema.dynamic_table_refresh_history());
select * from CustomerPurchases; 
```

## Deletes are also processed

After deleting rows from the Purchases table and running a manual refresh,  four rows were then deleted from the dynamic table.
with only two rows remaining. The dynamic_table_refresh_history show many details on what happened.

```sql
delete from purchases where CUSTOMER_ID=1;
alter dynamic table CustomerPurchases refresh;
select * from CustomerPurchases; 
select * from table(information_schema.dynamic_table_refresh_history());
```

# Switch to Automatic Refreshes

Instead of manually refreshing the dynamic table Snowflake also supports scheduling the refresh.
The code below uses `ALTER DYNAMIC TABLE ... SET TARGET_LAG`  to tell Snowflake to refresh the table every minute.
After waiting a minute, the new row shows up and the dynamic_table_refresh_history will show that the REFRESH_TRIGGER
is SCHEDULED instead of MANUAL.

```sql
alter dynamic table CustomerPurchases set target_lag='1 minute';
INSERT INTO Purchases (purchase_id, customer_id, product_name, purchase_date, amount)
VALUES(1, 1, 'Product D', '2023-09-20', 1.00)
select * from CustomerPurchases;
select * from table(information_schema.dynamic_table_refresh_history());
```

- The first query changes the target lag of the dynamic table to one minute using the `ALTER DYNAMIC TABLE ... SET TARGET_LAG` command. This means that the dynamic table will try to refresh itself automatically every minute to keep up with the changes in the source tables.
- The second query inserts another new row into the source table `Purchases`.

## Additional commands to manage the refresh of the table.

The refresh of the dynamic table can be started and stopped with the following commands.

```sql
alter dynamic table CustomerPurchases suspend;
alter dynamic table CustomerPurchases resume;
```
