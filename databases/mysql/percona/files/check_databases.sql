

set @gig = 1024*1024*1024;
set @gig_100 = @gig*100;

SELECT t.table_schema,
  round(SUM(t.data_length + t.index_length),2 )  as db_size,
  sum(!ISNULL(tr.TRIGGER_SCHEMA)) as no_of_triggers
FROM information_schema.tables t
  left join information_schema.triggers tr on
    (tr.TRIGGER_SCHEMA = t.table_schema and tr.EVENT_OBJECT_TABLE = t.table_name)
where t.table_schema not in ('mysql', 'information_schema', 'performance_schema', 'sys')
GROUP BY t.table_schema
having db_size < @gig_100
order by t.table_schema desc
;

