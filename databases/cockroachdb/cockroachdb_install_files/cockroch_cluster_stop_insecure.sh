

cd /data/cockroach
echo shutting down node1
cockroach node drain 1  --port=26257 --insecure
if [ -f node1.pid ]; do
  echo "killing node 1"
  kill `cat node1.pid`
fi
sleep 5

echo shutting down node2
cockroach node drain 2  --port=26258 --insecure
if [ -f node1.pid ]; do
  echo "killing node 2"
  kill `cat node2.pid`
fi
sleep 5

echo shutting down node3
cockroach node drain 3  --port=26259 --insecure
if [ -f node3.pid ]; do
  echo "killing node 3"
  kill `cat node3.pid`
fi
sleep 5
sleep 10
if [ -f node3.pid ]; do
  echo "hard kill node 3"
  kill -9 `cat node3.pid`
fi

echo '
echo ""
count=`ps auxw | grep "cockroach start" | grep -v grep | wc -l`
echo "$count cockroach processses remaining"
ps auxw | grep "cockroach start" | grep -v grep
sleep 5
' > list_cockroach_db_processes
chmod 755 list_cockroach_db_processes
  
watch -n 5  ./list_cockroach_db_processes 
if [ -f node3.pid ]; do
  echo "hard kill node 3"
  kill -9 `cat node3.pid`
fi

