---
test
---


* [List of rules](https://www.postgresql.org/docs/current/sql-createrule.html)
``` sql

-- NOTE: ev_action and ev_qual are in node format, which is not nice. 

select n.nspname as rule_schema,
       c.relname as rule_table,
       case r.ev_type
         when '1' then 'SELECT'
         when '2' then 'UPDATE'
         when '3' then 'INSERT'
         when '4' then 'DELETE'
         else 'UNKNOWN'
       end as rule_event,
       r.ev_qual,
       r.ev_action
from pg_rewrite r
  join pg_class c on r.ev_class = c.oid
  left join pg_namespace n on n.oid = c.relnamespace
  left join pg_description d on r.oid = d.objoid
where
  n.nspname = 'public';
```
* Example of listing one rule
```
drop view if exists tbl2;
drop table if exists tbl2;
drop table if exists tbl1;

create table if not exists tbl1 (i int);
create table if not exists tbl2 as select * from tbl1;

insert into tbl1  values (1);

-- This converts an empty table tbl2 to  view. It must be empty and exist.
CREATE RULE "_RETURN" AS
    ON SELECT TO tbl2
    DO INSTEAD
        SELECT * FROM tbl1;

select * from tbl2;

select n.nspname as rule_schema,
       c.relname as rule_table,
       case r.ev_type
         when '1' then 'SELECT'
         when '2' then 'UPDATE'
         when '3' then 'INSERT'
         when '4' then 'DELETE'
         else 'UNKNOWN'
       end as rule_event
from pg_rewrite r
  join pg_class c on r.ev_class = c.oid
  left join pg_namespace n on n.oid = c.relnamespace
  left join pg_description d on r.oid = d.objoid
where
  n.nspname = 'public'
  and c.relname = 'tbl2';

-- now print out the ugly stuff.
select n.nspname as rule_schema,
       c.relname as rule_table,
       case r.ev_type
         when '1' then 'SELECT'
         when '2' then 'UPDATE'
         when '3' then 'INSERT'
         when '4' then 'DELETE'
         else 'UNKNOWN'
       end as rule_event,
       r.ev_qual,
       r.ev_action
from pg_rewrite r
  join pg_class c on r.ev_class = c.oid
  left join pg_namespace n on n.oid = c.relnamespace
  left join pg_description d on r.oid = d.objoid
where
  n.nspname = 'public'
  and c.relname = 'tbl2';

```



* [List domains](https://www.postgresql.org/docs/current/sql-createdomain.html)
    * \dD is the psql version
    *
>     SELECT typname FROM pg_catalog.pg_type
>      JOIN pg_catalog.pg_namespace ON pg_namespace.oid = pg_type.typnamespace
>      WHERE typtype = 'd' AND nspname = 'public'

* Show contents of a domain. Assume we create a doman "d1".
```sql

create table table1 (i int);
create table table2 (i int);

CREATE DOMAIN g50 AS int
CHECK(   VALUE > 50 );

-- This will look ugly.
select * from pg_type where typname='g50';

     SELECT typname FROM pg_catalog.pg_type
      JOIN pg_catalog.pg_namespace ON pg_namespace.oid = pg_type.typnamespace
      WHERE typtype = 'd' AND nspname = 'public'




```