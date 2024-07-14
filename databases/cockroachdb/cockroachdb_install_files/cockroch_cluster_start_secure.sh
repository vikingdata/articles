

mkdir -p /data
cd /data

echo 'starting node1'
sudo -i -u cockroach cockroach start --port=26257 --http-port=8080 \
     --background --store=/data/cockroach/data1  --certs-dir=certs  \
     --join=localhost:26257,localhost:26258,localhost:26259 > /data/cockroach/c1.log 2>&1 &
echo 'sleeping 5 seconds'
sleep 5
reset

echo 'Intializing node1 node cluster'
cockroach init --insecure --host=localhost:26257
echo 'checking connection to node1'
sudo -i -u cockroach cockroach node status --host=localhost --port=26257 --insecure

echo 'starting node2'
sudo -i -u cockroach cockroach start --port=26258 --http-port=8081 \
     --background --store=/data/cockroach/data2 --insecure \
     --join=localhost:26257,localhost:26258,localhost:26259 > /data/cockroach/c2.log 2>&1 &
echo 'sleeping 5 seconds'
sleep 5
reset

echo 'starting node3'
sudo -i -u cockroach cockroach start --port=26259 --http-port=8082  \
     --background --store=/data/cockroach/data3 --insecure \
     --join=localhost:26257,localhost:26258,localhost:26259 > /data/cockroach/c3.log 2>&1 &
echo 'sleeping 5 seconds'
sleep 5
reset

echo 'sleeping 10 seconds to let servers sync'
sleep 10
echo 'checking status'
sudo -i -u cockroach cockroach node status --host=localhost --port=26257 --insecure

echo 'If the status is okay, the cluster was intilaized and cluster is setup'
echo 'You should see 3 hosts where the last 2 columns 'is_available | is_live' are all true. '
echo 'if issues run as root  : sudo -i -u cockroach cockroach node status --host=localhost --port=26257 --insecure'
echo "or as user cockroach   : cockroach node status --host=localhost --port=26257 --insecure'