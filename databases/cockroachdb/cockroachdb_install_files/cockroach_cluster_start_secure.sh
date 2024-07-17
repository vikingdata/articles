

cd /data/cockroach
$CERT_DIR=/data/cockroach/certs

echo 'starting node1'
sudo -i -u cockroach cockroach start --port=26257 --http-port=8080 \
     --pid-file=/data/cockroach/node1.pid \
     --background --store=/data/cockroach/data1  --certs-dir=$CERT_DIR  \
     --join=localhost:26257,localhost:26258,localhost:26259 > /data/cockroach/c1.log 2>&1 &
echo 'sleeping 5 seconds'
sleep 5
reset


echo 'starting node2'
sudo -i -u cockroach cockroach start --port=26258 --http-port=8081 \
     --pid-file=/data/cockroach/node2.pid \
     --background --store=/data/cockroach/data2 --certs-dir=$CERT_DIR \
     --join=localhost:26257,localhost:26258,localhost:26259 > /data/cockroach/c2.log 2>&1 &
echo 'sleeping 5 seconds'
sleep 5
reset

echo 'starting node3'
sudo -i -u cockroach cockroach start --port=26259 --http-port=8082  \
     --pid-file=/data/cockroach/node3.pid \
     --background --store=/data/cockroach/data3 --certs-dir=$CERT_DIR \
     --join=localhost:26257,localhost:26258,localhost:26259 > /data/cockroach/c3.log 2>&1 &
echo 'sleeping 5 seconds'
reset

echo 'sleeping 30 seconds to let servers sync'
sleep 30
echo 'checking status'
sudo -i -u cockroach cockroach node status --host=localhost --port=26257 -certs-dir=$CERT_DIR

