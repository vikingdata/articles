
---
title : MySQL Explain
author : Mark Nielsen
copyright : September 2024
---


MySQL Explain
==============================

_**by Mark Nielsen
Original Copyright September 2024**_

1. [links](#links)
3. [Setup](#setup)

* * *
<a name=links></a>Links
-----

* * *
<a name=setup></a>Setup
-----

Execute on a mysql database server.

```

create database if not exists test1;
use test1;

drop table if exists table3;
drop table if exists table2;
drop table if exists table1;

CREATE TABLE table1 (  table1_id int, primary key(table1_id)  );

CREATE TABLE table2 (
table2_id int,
table1_id_ref int,

key(table1_id_ref),
primary key(table2_id),

  FOREIGN KEY (table1_id_ref)
        REFERENCES table1(table1_id)
	
);

CREATE TABLE table3 (
table3_id int,
table2_id_ref int,

key(table2_id_ref),
primary key(table3_id),

  FOREIGN KEY (table2_id_ref)
        REFERENCES table2(table2_id)

);


drop procedure if exists insert_data;
DELIMITER //
  CREATE PROCEDURE insert_data()
    BEGIN
    DECLARE i int DEFAULT 0;
    DECLARE j int DEFAULT 0;
    WHILE i <= 1024 DO
        INSERT INTO table1 (table1_id) values  (i);
        SET i = i + 1;
    END WHILE;

    set i = 0;
    WHILE i <= 1024 DO
        INSERT INTO table2 (table2_id, table1_id_ref) values  (i,i);
         SET i = i + 1;
    END WHILE;

    set i = 0;
    set j = 0;
    WHILE i <= 1024 DO
        WHILE j <= 50 DO
	    SET j = j + 1;
            select concat('INSERT INTO table3 (table3_id, table2_id_ref) values ',i,j);
            INSERT INTO table3 (table3_id, table2_id_ref) values  (i,j);
        END WHILE;
        SET i = i + 1;
    END WHILE;

    END //
DELIMITER ;


call insert_data();
select count(1) from table1;
select count(1) from table2;
select count(1) from table3;

```

