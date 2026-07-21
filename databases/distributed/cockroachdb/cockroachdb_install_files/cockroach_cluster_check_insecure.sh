


cd /data/cockroach


echo 'checking status on node1'
sudo -i -u cockroach cockroach node status --host=localhost --port=26257 --insecure

echo 'checking status on node2'
sudo -i -u cockroach cockroach node status --host=localhost --port=26258 --insecure

echo 'checking status on node3'
sudo -i -u cockroach cockroach node status --host=localhost --port=26259 --insecure


