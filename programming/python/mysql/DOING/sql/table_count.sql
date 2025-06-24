

 SELECT table_rows, table_schema 'DB', table_name as 'Table'
  FROM information_schema.tables
  where table_rows  is not NULL
    and table_schema not in ('mysql', 'information_schema', 'performance_schema', 'sys')
    and table_rows > 0 and table_rows < 10000000
  order by  table_rows desc 
  

