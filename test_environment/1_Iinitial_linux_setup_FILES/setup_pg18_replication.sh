#!/bin/bash
set -e

# --- Configuration & Variables ---
PG_VERSION="18"
BASE_DIR="/databases/postgresql18"
REPL_USER="repl1"

# run as root
if [ "$EUID" -ne 0 ]; then   echo "Run as root with sudo.";  exit 1; fi

usage() {
  echo "Usage: sudo $0 <primary_instance_name> <primary_port> <standby_instance_name> <secondary_port>"
  echo "Example: sudo $0 pub 5432 sub 5433"
  echo "All instances are on the same host."
  echo "The directories should exist if given above:
$BASE_DIR/pub_5432
$BASE_DIR/sub_5433
"
  exit 1
}

# Check if 4 variables are passed. 
if [ "$#" -ne 4 ]; then
  echo "You passed $# options instead of 4. '$1 $2 $3 $4 '"
  usage
fi

P_NAME="${1//[^[:alnum:]]/}"
P_PORT="${2//[^[:alnum:]]/}"
S_NAME="${3//[^[:alnum:]]/}"
S_PORT="${4//[^[:alnum:]]/}"

P_INSTANCE_ID="${P_NAME}_${P_PORT}"
P_INSTANCE_ROOT="${BASE_DIR}/${P_INSTANCE_ID}"
S_INSTANCE_ID="${S_NAME}_${S_PORT}"
S_INSTANCE_ROOT="${BASE_DIR}/${S_INSTANCE_ID}"

SERVICE_NAME="postgresql18-${S_INSTANCE_ID}.service"

echo " ${BASE_DIR} $P_INSTANCE_ROOT $S_INSTANCE_ROOT"

if [ ! -d "$P_INSTANCE_ROOT" ]; then
    echo "Primary instance does not exist:  '$P_INSTANCE_ROOT'" >&2
    usage
    exit 1
fi

is_running=`systemctl is-active --quiet $SERVICE_NAME || true`
if [ "$is_running" = "active" ]; then
    echo "stopping  postgresql18-$SERVICE_NAME"
     systemctl stop  "$SERVICE_NAME"
fi

echo "checking target $S_INSTANCE_ROOT"
if [ -d "$S_INSTANCE_ROOT" ]; then
    echo "Removing standby directory:  '/databases/postgresql18/${S_INSTANCE_ID}'"
    sudo rm -rf /databases/postgresql18/${S_INSTANCE_ID}
    echo "Making empty standby directory: '$S_INSTANCE_ROOT'"
    sudo mkdir -p /databases/postgresql18/${S_INSTANCE_ID}/data
    sudo chown -R  "postgres:postgres" "${S_INSTANCE_ROOT}"
    sudo chmod -R 0700 ${S_INSTANCE_ROOT}

    # check if pid is running
    pid=`sudo lsof -t -iTCP:$S_PORT -sTCP:LISTEN || true`
    if [ ! "$pid" = "" ]; then
	echo "Killing process $oid on port $S_PORT"
	kill $pid || true
	sleep 2
	kill -9 $pid || true
    fi

fi

echo "Getting password: grep ^$P_INSTANCE_ID: $BASE_DIR/$P_INSTANCE_ID.repl_password | tail -n 1 | cut -d ':' -f4"
password=`grep ^$P_INSTANCE_ID: $BASE_DIR/$P_INSTANCE_ID.repl_password | tail -n 1 | cut -d ':' -f4` 
if [ "$password" = "" ]; then
    echo "empty primary password, aborting".
    exit
fi    

sudo -u postgres sh -c "echo '127.0.0.1:5432:*:$REPL_USER:$password' > ~/.pgpass"
echo "Check password with :   sudo -u postgres sh -c ' cat ~/.pgpass'"
sudo -u postgres sh -c 'chmod 600 ~/.pgpass'
echo "sudo -u postgres -c 'pg_basebackup -h 127.0.0.1 -p 5432 -U $REPL_USER -D $S_INSTANCE_ROOT -Fp -Xs -P -R -S sub1'"
sudo -u postgres sh -c "pg_basebackup -h 127.0.0.1 -p 5432 -U $REPL_USER -D $S_INSTANCE_ROOT/data -Fp -Xs -P -R -S sub1"
sudo ls -al /databases/postgresql18/${S_INSTANCE_ID}/data | wc -l

backup_file="/databases/postgresql18/backup_${S_INSTANCE_ID}_postgresql.conf"
sudo chmod 666 $backup_file
if [ ! -f "$backup_file" ]; then
    echo "backup config file does not exist : $backup_file"
    exit
fi

cp -f $backup_file $S_INSTANCE_ROOT/data/
#echo "sed -i -e 's|^port|#&|' /databases/postgresql18/$S_INSTANCE_ID/data/postgresql.conf"
sudo sed -i -e "s|^port|#&|" /databases/postgresql18/$S_INSTANCE_ID/data/postgresql.conf
echo "port = $S_PORT " >> /databases/postgresql18/$S_INSTANCE_ID/data/postgresql.conf

SERVICE_NAME="postgresql18-${S_INSTANCE_ID}.service"
echo "starting : sudo systemctl start ${SERVICE_NAME}"

sudo systemctl start "${SERVICE_NAME}"
sleep 10
echo 1

if ! systemctl is-active --quiet "${SERVICE_NAME}"; then
        systemctl --no-pager --full status  "${SERVICE_NAME}" || true
        journalctl -u "${SERVICE_NAME}" --no-pager  -n 100 || true
        echo  "Failed to start ${INSTANCE_NAME}"
	exit
fi

echo "Status of primary and secondary servers"
service "postgresql18-${P_INSTANCE_ID}" status
service "postgresql18-${S_INSTANCE_ID}" status

sql="SELECT * FROM pg_replication_slots;"
sudo -u postgres psql -p $P_PORT -P pager=off -c "$sql;"

# Replication Status
echo "sudo -u postgres psql -tA -p $P_PORT -c \"$sql\" | grep sub1 | wc -l"
echo "sql='SELECT application_name, client_addr, backend_start, state, sync_state FROM pg_stat_replication;'
sudo -u postgres psql -p $P_PORT  -P pager=off -c \"$sql;\"
sql='SELECT pg_is_in_recovery(), pg_last_wal_receive_lsn(), pg_last_wal_replay_lsn();'
sudo -u postgres psql -p $S_PORT  -P pager=off -c \"$sql;\"
"

echo "Primary Replication $P_PORT"
match=0
while [ $match -lt 1 ]; do
    echo "Checking replication on primary"
    sql="SELECT application_name FROM pg_stat_replication;"
    echo $sql
    match=`sudo -u postgres psql -tA -p $P_PORT -c "$sql" | grep ${P_INSTANCE_ID} | wc -l`
    echo "sudo -u postgres psql -tA -p $P_PORT -c '$sql' | grep ${P_INSTANCE_ID} | wc -l"
    sleep 5
done


sql="SELECT application_name, client_addr, backend_start, state, sync_state FROM pg_stat_replication;"
sudo -u postgres psql -p $P_PORT  -P pager=off -c "$sql;"

echo "Standby Replication $S_PORT "
sql="SELECT pg_is_in_recovery(), pg_last_wal_receive_lsn(), pg_last_wal_replay_lsn();"
sudo -u postgres psql -p $S_PORT  -P pager=off -c "$sql;"

