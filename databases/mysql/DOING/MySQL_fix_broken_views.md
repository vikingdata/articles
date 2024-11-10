
---
title : MySQL Fix Views
author : Mark Nielsen
copyright : November 2024
---


MySQL Fix Views
==============================

_**by Mark Nielsen
Copyright November 2024**_

Sometimes views may not work. Thhe trick is to recreate them. 

1. [Links](#links)


* * *
<a name=links></a>Links
-----

* * *
<a name=Setup></a>Setup 
-----

```
echo "
drop database if exists test_views;
create if not exists test_views;
use test_views;

create table tbl1 (i int);
create table tbl2 (i int);

insert into tbl1 values (1);
insert into tbl2 values (1);

create view view1 select * from tbl1;
create view view2 select * from tbl2;
create view view3 select * from tbl3;
" > setup_views.sql

```


```
* * *
<a name=execute></a>Execute scripts
-----


