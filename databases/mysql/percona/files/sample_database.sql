

create database if not exists sample_database;
use sample_database

drop table if exists table1;
drop table if exists table2;
drop view if exists view1;
drop trigger if exists table1_trigger1;

create table table1 (i int);
create table table2 (i int);

DELIMITER //

CREATE TRIGGER table1_trigger1
AFTER INSERT
ON table1
FOR EACH ROW
BEGIN
    INSERT INTO table2 (i) VALUES (NEW.i + 100);
END;
//

DELIMITER ;

CREATE VIEW view1 AS SELECT i FROM table1;

insert into table1 (1);
select * from table1;
select * from view1;
select * from table2;
