---
List of postgresql sql commads
---

* [Rule](#rule)
* [Domain](#domain)


* * *
Links
-----

* (https://www.postgresql.org/docs/9.1/functions-info.html](https://www.postgresql.org/docs/9.1/functions-info.html)
* [information_schema](https://www.postgresql.org/docs/current/information-schema.html)
* [system catalogs](https://www.postgresql.org/docs/current/catalogs.html) which information_schema is a view of. 


* * *
<a name=rule></a>[Rule](https://www.postgresql.org/docs/current/sql-createrule.html) or [this link](https://dzone.com/articles/postgresql-rewrite-rules)
-----

In PostgreSQL, a "rule" refers to a database object that defines an action to be taken when a specified event occurs. Rules are used for implementing specific actions or behaviors in response to certain conditions.

* Public rules
``` sql
select n.nspname as rule_schema,
       c.relname as rule_table,
       r.oid as role_oid,
       case r.ev_type
         when '1' then 'SELECT'
         when '2' then 'UPDATE'
         when '3' then 'INSERT'
         when '4' then 'DELETE'
         else 'UNKNOWN'
       end as rule_event,
       pg_get_ruledef(r.oid)
from pg_rewrite r
  join pg_class c on r.ev_class = c.oid
  left join pg_namespace n on n.oid = c.relnamespace
  left join pg_description d on r.oid = d.objoid
where
  n.nspname = 'public';
```
* All Rules
```sql
select n.nspname as rule_schema,
       c.relname as rule_table,
       r.oid as role_oid,
       case r.ev_type
         when '1' then 'SELECT'
         when '2' then 'UPDATE'
         when '3' then 'INSERT'
         when '4' then 'DELETE'
         else 'UNKNOWN'
       end as rule_event,
       pg_get_ruledef(r.oid)
from pg_rewrite r
  join pg_class c on r.ev_class = c.oid
  left join pg_namespace n on n.oid = c.relnamespace
  left join pg_description d on r.oid = d.objoid
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
       r.oid as rule_oid,
       case r.ev_type
         when '1' then 'SELECT'
         when '2' then 'UPDATE'
         when '3' then 'INSERT'
         when '4' then 'DELETE'
         else 'UNKNOWN'
       end as rule_event,
       pg_get_ruledef(r.oid)
from pg_rewrite r
  join pg_class c on r.ev_class = c.oid
  left join pg_namespace n on n.oid = c.relnamespace
  left join pg_description d on r.oid = d.objoid
where
  n.nspname = 'public'
  and c.relname = 'tbl2';



-- now print out the ugly stuff if you want to know.
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

* * *
<a name=domain></a>[Domain](https://www.postgresql.org/docs/current/sql-createdomain.html)
-----

In PostgreSQL, a "domain" refers to a user-defined data type with optional constraints. It allows you to define a set of values that a column can contain and apply constraints to restrict the valid values. Essentially, a domain acts as a wrapper around an existing data type, adding an extra layer of constraints or rules to the values that can be stored in a column.
* List out domains
    * \dD is the psql version -- This displays the constraints.
    * Equivalent in SQL but for all domains
```sql

-- to make it just publid add
-- where   tn.nspname = 'public'

select  tt.typname, pg_get_constraintdef(tc.oid) as constraint
    from    pg_namespace tn
    join    pg_constraint tc on tn.oid = tc.connamespace
    join    pg_type tt on tt.oid = tc.contypid
    ;
```
    * List out only the ones in "public"
>     SELECT typname FROM pg_catalog.pg_type
>      JOIN pg_catalog.pg_namespace ON pg_namespace.oid = pg_type.typnamespace
>      WHERE typtype = 'd' AND nspname = 'public'

* Show contents of a domain. Assume we create a doman "d1".
```sql

create table table1 (i int);
create table table2 (i int);

CREATE DOMAIN g50 AS int
CHECK(   VALUE > 50 );

\dD

-- Now do the equiv of \dD in sql
select  tt.typname, pg_get_constraintdef(tc.oid) as constraint
    from    pg_namespace tn
    join    pg_constraint tc on tn.oid = tc.connamespace
    join    pg_type tt on tt.oid = tc.contypid
    where   tn.nspname = 'public'
    and     tt.typname = 'g50'


-- This will look ugly.
select * from pg_type where typname='g50';

```