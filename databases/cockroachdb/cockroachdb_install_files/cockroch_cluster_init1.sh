

mkdir -p /data
cd /data

   # reset cockroachdb
killall -u cockroach
sleep 5
killall -9 -u cockroach
sleep 5
rm -rf /data/cockroach

mkdir -p cockroach/data1
mkdir -p cockroach/data2
mkdir -p cockroach/data3
mkdir -p /usr/local/lib/cockroach

chown -R cockroach.cockroach /data/cockroach /usr/local/lib/cockroach

echo 'starting node1'
sudo -i -u cockroach cockroach start-single-node --port=26257 --http-port=8080   --background --store=/data/cockroach/data1 --insecure  > /data/cockroach/c1.log 2>&1 &
echo 'sleeping 5 seconds'
sleep 5
reset

echo 'starting node2'
sudo -i -u cockroach cockroach start --port=26258 --http-port=8081   --background --store=/data/cockroach/data2 --insecure --join=localhost:26257   > /data/cockroach/c2.log 2>&1 &
echo 'sleeping 5 seconds'
sleep 5
reset

echo 'starting node3'
sudo -i -u cockroach cockroach start --port=26259 --http-port=8082   --background --store=/data/cockroach/data3 --insecure --join=localhost:26257   > /data/cockroach/c3.log 2>&1 &
echo 'sleeping 5 seconds'
sleep 5
reset

echo 'sleeping 10 seconds to let servers sync'
sleep 10
echo 'checking status'
sudo -i -u cockroach cockroach node status --host=localhost --port=26257 --insecure

echo 'If the status is okay, the cluster was intilaized and cluster is setup'
echo 'You should see 3 hosts where the last 2 columns "is_available | is_live" are all true. '
