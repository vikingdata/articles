
echo shutting down node1
cockroach quit --http-port 8080
sleep 5

echo shutting down node2
cockroach quit --http-port 8081
sleep 5

echo shutting down node3
cockroach quit --http-port 8082
sleep 5

count=`ps auxw | grep "cockroach start" | grep -v grep | wc -l`
while [ $count -gt 0 ] ; do
   echo ""
   echo "$count cockroach processses remaining"
   ps auxw | grep "cockroach start" | grep -v grep
   sleep 2
   count=`ps auxw | grep "cockroach start" | grep -v grep |wc -l`
done
