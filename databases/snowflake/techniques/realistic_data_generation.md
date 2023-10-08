---
Title : Realistic Data gneration
Author : Mark Nielsen
CopyRight : Oct 2023
---

Realistic Data Generation
===============

_**by Mark Nielsen  
Copyright Oct 2023**_

* * *

A data engineer may need to generate random data for various reasons, including:

* Testing and Development
* Performance Testing
* Privacy and Security
* Benchmarking
* Simulating Real-world Scenarios
* Machine Learning and Model Testing
* Load Testing
* Education and Training

In all these cases, the key is to use random data as a representative substitute for real data to achieve specific goals without compromising privacy, security, or the integrity of the testing or development process.


## Purpose
* Create a fake store with realistic data.
  * Create a simple customer table with realistic data.
    * Random name, phone, address.
  * Create a product table with realistic data
    * Random price. 
  * Create an order table which is an order.
    * Random date and random customer.
  * Create a order_products table which is a list of products for each each order. 

We could get more complicated with purchasing, cancellations, etc. For now, we will keep it simple.

## First make the base python functions.
* Make the "fake" method"

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



## Make the order_product template table and stored procedure, and the order_product table.

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

```

## Make the order table.

I was unhappy with the speed of the stored procedure. So I made one that does one insert instead if one insert per loop.

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
--	    I_list := '' || I_list ||  ' ( ' || r_row.order_id || ', ' ;
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
 select count(*) from order_product limit 100;


```

## Notes
* You could make one function to join two tables together like order_product by taking take four (or more) arguemnts
   * first argument is first table
   * second arguement is second table
   * third argument is the name of the final table
   * fourth arguement is a random number of the amount of ids you want from the second table for each id of the first table.
* Or you could make a variety of functions to join tables. 