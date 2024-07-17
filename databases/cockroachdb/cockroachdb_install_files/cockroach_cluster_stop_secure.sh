

cd /data/cockroach
echo shutting down node1
cockroach node drain 1  --port=26257 --certs-dir=$CERT_DIR
if [ -f node1.pid ]; then
  echo "killing node 1 ",`cat node1.pid`
  kill `cat node1.pid`
  rm node1.pid
fi
sleep 5

echo shutting down node2
cockroach node drain 2  --port=26258 --certs-dir=$CERT_DIR
if [ -f node1.pid ]; then
  echo "killing node 2", `cat node2.pid`
  kill `cat node2.pid`
  rm node2.pid
fi
sleep 5

echo shutting down node3
if [ -f node3.pid ]; then
  echo "killing node 3", `cat node3.pid`
  kill `cat node3.pid`
  sleep 20
  kill -9 `cat node3.pid`
  rm node3.pid
fi

echo '
echo ""
count=`ps auxw | grep "cockroach start" | grep -v grep | wc -l`
echo "$count cockroach processses remaining"
ps auxw | grep "cockroach start" | grep -v grep
sleep 5
' > list_cockroach_db_processes
chmod 755 list_cockroach_db_processes

count=`ps auxw | grep "cockroach start" | grep -v grep | wc -l`

if [ $count -gt 0 ]; then
  ./list_cockroach_db_processes 
  sleep 3
  ./list_cockroach_db_processes
  sleep 3
  ./list_cockroach_db_processes
fi

count=`ps auxw | grep "cockroach start" | grep -v grep | wc -l`

if [ $count -lt 1 ]; then
    echo "cockroachdb cluster should have stopped"
fi

