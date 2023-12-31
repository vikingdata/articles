---
test
---


* List of rules
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


select * from information_schema.table_constraints where constraint_schema='public';
```

* List domains
    * \dD is the psql version
    *
>     SELECT typname FROM pg_catalog.pg_type
>      JOIN pg_catalog.pg_namespace ON pg_namespace.oid = pg_type.typnamespace
>      WHERE typtype = 'd' AND nspname = 'public'  