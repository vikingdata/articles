#!bash

echo "insert into t1 values (0)"> insert_t1.sql
echo "insert into t2 values (0,0)"> insert_t2.sql
echo "insert into t3 values (0,0,0)"> insert_t3.sql


for i in $(seq 1 10); do
    echo -n ",($i)" >> insert_t1.sql 
    for j in $(seq 1 100); do
	echo -n ",($j,$i)" >> insert_t2.sql
	for k in $(seq 1 1000); do
	    echo -n ",($k,$j,$i)" >> insert_t3.sql
	done
    done
    echo "done with t1 $i"
done

echo ";" >> insert_t1.sql
echo ";" >> insert_t2.sql
echo ";" >> insert_t3.sql

