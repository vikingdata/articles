

cd /data/cockroach

PORT="26256"
for i in 1 2 3; do
  let PORT=$Port+1

  echo "shutting down node$i"
  cockroach node drain $i  --port=$PORT --insecure

  if [ -f node$i.pid ]; then
    PID=`cat node$i.pid`
    echo "killing node $i $PID"
    kill $PID
    sleep 5
    if ps -p $PID > /dev/null; then
      sleep 5
      echo "hard killing $PID -- this is bad, need a better shutdown method"
      kill -9 $PID
    fi
    rm node1.pid
  fi  
done

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
else
    echo "Darn, cockroach still running, try to fnd out why."
fi

