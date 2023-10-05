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

CREATE OR REPLACE FUNCTION fake( choice varchar(64))
  returns string
  language python
  runtime_version = '3.10'
  packages = ('faker')
  handler = 'fake'
as
$$
from faker import Faker

def fake(choice):
  f = Faker()
  if choice == "fullname":
    return f.name()
  elif  choice == "address":
    return f.address()
  elif  choice == "phone":
    return f.phone_number()

  return ''
$$
;
```

* Make the products function for fake data.




## Make the customer table.
```sql

create or replace table customers as (

  with people as (
    select seq4() as id
      , fake('fullname') as name
      , fake('address') as address
      , fake('phone') as phone
    FROM TABLE(GENERATOR(ROWCOUNT => 20))
  )

select id, name, address, phone from people

);

```

## Make the product table.

## Make the order table.

## Make the order_products table.

##