create database if not exists test_join;
use test_join;

drop table if exists t1;
drop table if exists t2;
drop table if exists t3;

create table t1 (
t1_id int,
primary key (t1_id)
);

create table t2 (
t2_id int,
t1_id int,
primary	key (t2_id, t1_id)
);

create table t3 (
t3_id int,
t2_id int,
t1_id int,

index (field1
primary	key (t3_id, t2_id, t1_id)
);

alter table t3 add index t2_t1 (t2_id, t1_id);
alter table t3 add index t1_t2 (t1_id, t2_id);
