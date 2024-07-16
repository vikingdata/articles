
cd /data/cockroach


echo 'checking status on node1'
sudo -i -u cockroach cockroach node status --host=localhost --port=26257 --certs-dir=$CERT_DIR

echo 'checking status on node2'
sudo -i -u cockroach cockroach node status --host=localhost --port=26258 --certs-dir=$CERT_DIR

echo 'checking status on node3'
sudo -i -u cockroach cockroach node status --host=localhost --port=26259 --certs-dir=$CERT_DIR


