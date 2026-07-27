
   * Start your mysql client in verbose mode. "-vvv" for the mysql client. 
   * Run "source create_table_join.sql" on your database.
---
Output

Query OK, 1 row affected, 1 warning (0.00 sec)

Database changed
Query OK, 0 rows affected (0.01 sec)

Query OK, 0 rows affected (0.00 sec)

Query OK, 0 rows affected (0.01 sec)

Query OK, 0 rows affected (0.00 sec)

Query OK, 0 rows affected (0.01 sec)

Query OK, 0 rows affected (0.01 sec)

---
   * Run "bash make_data.sh" at your linux or operating system prompt.
---
Output
done with t1 1
done with t1 2
done with t1 3
done with t1 4
done with t1 5
done with t1 6
done with t1 7
done with t1 8
done with t1 9
done with t1 10
----
   * Run the follwing in mysql
---
source insert_t1.sql;
source insert_t2.sql;
source insert_t3.sql;

Output
mysql> source insert_t1.sql;
Query OK, 11 rows affected (0.01 sec)
Records: 11  Duplicates: 0  Warnings: 0

mysql> source insert_t2.sql;
Query OK, 1001 rows affected (0.01 sec)
Records: 1001  Duplicates: 0  Warnings: 0

mysql> source insert_t3.sql;
Query OK, 1000001 rows affected (9.91 sec)
Records: 1000001  Duplicates: 0  Warnings: 0
---
   * Make the logs directory and empty it.
       * "  bash -c 'mkdir -p logs; rm -f logs/*'   "
   * Run the join test script in mysql "source join_test.sql". This saves log information to files join_first.log, no_index.log, where_first.log.
   * Process the logs by running "analyze_logs.sh"
---
Output
For no_index.log, the no of rows is calcualted from the explain
    11*926*926403 = 9436340958
For where_first.log, the no of rows is calcualted from the explain
    11*181*18142 = 36120722
For join_first.log, the no of rows is calcualted from the explain
    11*2*11 = 242
---
   * We see that adding an index where the first field in the index is in the where condition is better. But an index for the field with join first is the best.    