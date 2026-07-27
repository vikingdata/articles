alter table t3 drop index t2_t1;
alter table t3 drop index t1_t2;

tee logs/no_index.log
explain 
select t1.t1_id as s , t_d.mt3_id
from t1 
  straight_join 
    (
      select max(t3_id) as mt3_id, t1_id
      from t3
      where t2_id = 10
      group by t1_id
    ) as t_d on ( t1.t1_id = t_d.t1_id)
\G
notee

alter table t3 add index t2_t1 (t2_id, t1_id);
tee logs/where_first.log
explain
select t1.t1_id as s , t_d.mt3_id
from t1
  straight_join
    (
      select max(t3_id) as mt3_id, t1_id
      from t3
      where t2_id = 10
      group by t1_id
    ) as t_d on ( t1.t1_id = t_d.t1_id)
\G
notee

alter table t3 drop index t2_t1;
alter table t3 add index t1_t2 (t1_id, t2_id);

tee logs/join_first.log
explain
select t1.t1_id as s , t_d.mt3_id
from t1
  straight_join
    (
      select max(t3_id) as mt3_id, t1_id
      from t3
      where t2_id = 10
      group by t1_id
    ) as t_d on ( t1.t1_id = t_d.t1_id)
\G

