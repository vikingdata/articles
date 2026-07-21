---
Title : Realistic Data generation
Author : Mark Nielsen
Copyright : Oct 2023
---

Realistic Data Generation
===============

_**by Mark Nielsen  
Copyright Oct 2023**_

* * *

Realistic data testing involves using data that closely resembles what the system will encounter in production, including the volume, variety, and complexity of real-world data. This type of testing helps identify potential bottlenecks, scalability issues, and data integrity problems that might arise when the application goes live. This article is an introduction
on how to make realistic fake data in SnowFlake. This data will be ready for DBT to create some basic tables in a warehouse. 


## Purpose
* Create a fake store with realistic data.
  * Create a simple customer table with realistic data.
    * Random name, phone, address.
  * Create a product table with realistic data
    * Random price.
  * Create an order table which is an order for random customers.
    * Random date and random customer.
  * Create a order_products table which is a list of products for each each order. 

* To achieve our purpose
   * Create a Python UDF to create fake data using the "faker" class.
   * Try to keep everything SQL
       * We will need one stored procedure to merge the "ids" of two tables.
       This stored procedure could be rewritten to merge any two tables by giving the names of the tables as arguments.
   * Make use of the RANDOM snowflake function.
   * Make use of a generator to make rows. 

Some options:
   * You can make the tables bigger with more rows or columns. 
   * Create more tables.
   * Write a stored procedure to create a table merging the ids of any two tables, such as order, product, and then order_product.
   * Add more fields to the Python stored procedure making fake data.
   * After you create the data, backup the tables or database to make restoration fast. 

We could get more complicated with purchasing, cancellations, etc. For now, we will keep it simple.

## Random Generator Links
I only found one free easy to use realistic data generator. There may be more. There are several articles on data generation but they seem complex. There are also realistic
generators you have to pay for (not free at all). This article was written to make a fast way to generate random in Snowflake. Other articles for other databases
might be written too. 

* https://www.mockaroo.com/ : Everything seems free with limited rows generated and speed. This seems like a good balance between a free resource and one you want to pay for
for heavy use. 
* (YouTube video : mockaroo and foreign keys )[https://www.youtube.com/watch?v=S_oYFGhZSkQ]

## First make the base python function.
* Make the "fake" method". We need to add two lists, one more Product and Price, since they are not in the Faker class. 


```sql
create database if not exists tutorial;
use database tutorial;
create schema if not exists test;
use schema test;

CREATE OR REPLACE FUNCTION fake( choice text)
  returns string
  language python
  runtime_version = '3.10'
  packages = ('faker')
  handler = 'fake'
as
$$
from faker import Faker

from faker.providers import DynamicProvider

products = DynamicProvider(
     provider_name="product",
     elements=["lamp", "book", "car", "sock", "pants", "fork", "spoon", "door", "dog", "cat", "chair"],
)

prices = DynamicProvider(
     provider_name="price",
     elements= range(100)
)

def fake(choice):
  f = Faker()
  f.add_provider(products)
  f.add_provider(prices)


  if choice == "fullname":
    return f.name()
  elif  choice == "address":
    return f.address()
  elif  choice == "phone":
    return f.phone_number()
  elif  choice == "product":
    return f.product()
  elif  choice == "phone":
    return f.price()

  return ''
$$
;
```

## Make the products table.

```sql
create or replace table product as (
  with products as (
    select seq4() as id
      , fake('product') as name
      , fake('price') as price
    FROM TABLE(GENERATOR(ROWCOUNT => 5))
  )
select id, name, price from products
);
```

## Make the customer table.
```sql

create or replace table customers as (

  with people as (
    select seq4() as id
      , fake('fullname') as name
      , fake('address') as address
      , fake('phone') as phone
    FROM TABLE(GENERATOR(ROWCOUNT => 50))
  )

select id, name, address, phone from people

);

```

## Make the order table.
```sql
set (max_customer_id) = (select max(id) from customers);
create or replace table orders as
  select seq4() as orders
    , abs(floor(normal(1, $max_customer_id, RANDOM()))) as customer_id
    , DATEADD(day, seq4(), TO_DATE('2013-05-08')) AS  date_created
 FROM TABLE(GENERATOR(ROWCOUNT => 100))
;

```



## Make the order_product template table, stored procedure, and the order_product table.

```

create or replace table order_product_template (
  order_id int,
  product_id int
);

CREATE OR REPLACE PROCEDURE make_order_product()
  RETURNS string
as
$$
DECLARE
    V_SQL text;
    r_random int;
    c_row CURSOR FOR SELECT order_id from orders;
    max_product_id int;
    order_id int;
    res text;

BEGIN
    create or replace table TEMP_order_product like order_product_template;
    select max(id) into :max_product_id from product;
    open c_row;

    for r_row in c_row do
        r_random := uniform(1, 5, random());
        V_SQL := ' insert into TEMP_order_product select '|| r_row.order_id || ' , abs(floor(normal(1, ' || max_product_id || ', R\
ANDOM())))    FROM TABLE(GENERATOR(ROWCOUNT =>  ' || r_random  || ' ))';
        EXECUTE IMMEDIATE V_SQL;
    END FOR;
    close c_row;

    drop table if exists order_product;
    ALTER TABLE  TEMP_order_product RENAME TO order_product;

    res := 'Created table order_product';
    return (res);
END;
$$
;

call  make_order_product();
select count(*) from order_product;

```


## One big file

```sql

create database if not exists tutorial;
use database tutorial;
create schema if not exists test;
use schema test;

CREATE OR REPLACE FUNCTION fake( choice text)
  returns string 
  language python
  runtime_version = '3.10'
  packages = ('faker')
  handler = 'fake'
as
$$
from faker import Faker

from faker.providers import DynamicProvider

products = DynamicProvider(
     provider_name="product",
     elements=["lamp", "book", "car", "sock", "pants", "fork", "spoon", "door", "dog", "cat", "chair"],
)

prices = DynamicProvider(
     provider_name="price",
     elements= range(100)
)

def fake(choice):
  f = Faker()
  f.add_provider(products)
  f.add_provider(prices)
  if choice == "fullname":
    return f.name()
  elif  choice == "address":
    return f.address()
  elif  choice == "phone":
    return f.phone_number()
  elif  choice == "product":
    return f.product()
  elif  choice == "phone":
    return f.price()


  return ''
$$
;

create or replace table customers as (
  with people as ( 
    select seq4() as id
      , fake('fullname') as name
      , fake('address') as address
      , fake('phone') as phone
    FROM TABLE(GENERATOR(ROWCOUNT => 50))
  )
select id, name, address, phone from people

);


create or replace table product as (
  with products as (
    select seq4() as id
      , fake('product') as name
      , fake('price') as price
    FROM TABLE(GENERATOR(ROWCOUNT => 5))
  )
select id, name, price from products
);


set (max_customer_id) = (select max(id) from customers);
create or replace table orders as
  select seq4() as order_id
    , abs(floor(normal(1, $max_customer_id, RANDOM()))) as customer_id
    , DATEADD(day, seq4(), TO_DATE('2013-05-08')) AS  date_created
 FROM TABLE(GENERATOR(ROWCOUNT => 100))
;


create or replace table order_product_template (
  order_id int,
  product_id int
);

CREATE OR REPLACE PROCEDURE make_order_product()
  RETURNS string
as
$$
DECLARE
    V_SQL text;
    r_random int;
    c_row CURSOR FOR SELECT order_id from orders;
    max_product_id int;
    order_id int;
    res text;

BEGIN
    create or replace table TEMP_order_product like order_product_template;
    select max(id) into :max_product_id from product;
    open c_row;

    for r_row in c_row do
        r_random := uniform(1, 5, random());
        V_SQL := ' insert into TEMP_order_product select '|| r_row.order_id || ' , abs(floor(normal(1, ' || max_product_id || ', RANDOM())))    FROM TABLE(GENERATOR(ROWCOUNT =>  ' || r_random  || ' ))';
        EXECUTE IMMEDIATE V_SQL;
    END FOR;
    close c_row;

    drop table if exists order_product;
    ALTER TABLE  TEMP_order_product RENAME TO order_product;

    res := 'Created table order_product';
    return (res);
END;
$$
;

call  make_order_product();
select count(*) from order_product;

```

## Generate order_product faster.

I was unhappy with the speed of the stored procedure. So I made one that does one insert instead of one insert per loop.

```sql


CREATE OR REPLACE PROCEDURE make_order_product_fast()
  RETURNS string
as
$$
DECLARE
    V_SQL text;

    I_list text default '';
    r_random int;
    p_random int;
    c_row CURSOR FOR SELECT order_id from orders;
    max_product_id int;
    order_id int;
    res text;

BEGIN
    create or replace table TEMP_order_product like order_product_template;
    select max(id) into :max_product_id from product;
    open c_row;

    for r_row in c_row do
        r_random := uniform(1, 5, random());
        for i in 1 to r_random do
	  p_random := uniform(1, 5, random());
          I_list := '' || I_list ||  ' ( ' || r_row.order_id || ', ' || p_random  || '),';
        END FOR;
	  
    END FOR;
    close c_row;

    I_list := rtrim(I_list, ',');
    V_SQL := ' insert into TEMP_order_product (order_id, product_id) values ' || I_list || ';';
    
--    return (V_SQL);
   
    EXECUTE IMMEDIATE V_SQL;

    drop table if exists order_product;
    ALTER TABLE  TEMP_order_product RENAME TO order_product;

    return ('Tablename order_product reset.');
END;
$$
;

call  make_order_product_fast();
select count(*) from order_product;


```

## Notes
* You could make one function to join two tables together like order_product by taking take four (or more) arguments
   * first argument is first table
   * second argument is second table
   * third argument is the name of the final table
   * fourth argument is a random number of the amount of ids you want from the second table for each id of the first table.
* Or you could make a variety of functions to join tables.
* Now we can run DBT to create warehouse table examples.
* You could create procedure to add random products to the orders.
