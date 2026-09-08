#!/bin/bash
set -e

# --- Configuration & Variables ---
PG_VERSION="18"
BASE_DIR="/databases/postgresql18"
REPL_USER="replication_user"

# run as root
if [ "$EUID" -ne 0 ]; then   echo "Run as root with sudo.";  exit 1; fi

usage() {
  echo "Usage: sudo $0 <primary_instance_name> <primary_port> <logical_instance_name> <secondary_port>"
  echo "Example: sudo $0 pub 5432 rep1 5442"
  echo "All instances are on the same host."
  echo "The directories should exist if given above:
$BASE_DIR/pub_5432
$BASE_DIR/rep1_5442
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

is_running=`systemctl is-active  $SERVICE_NAME || true`
if [ ! "$is_running" = "active" ]; then
    echo "replication instance is not running :   postgresql18-$SERVICE_NAME"
    exit 1
fi

echo "Getting password: grep ^$P_INSTANCE_ID: $BASE_DIR/$P_INSTANCE_ID.repl_password | tail -n 1 | cut -d ':' -f4"
password=`grep ^$P_INSTANCE_ID: $BASE_DIR/$P_INSTANCE_ID.repl_password | tail -n 1 | cut -d ':' -f4` 
if [ "$password" = "" ]; then
    echo "empty primary password, aborting".
    exit
fi    

sql="drop PUBLICATION publication1"
sudo -u postgres psql -p $P_PORT -c "$sql;" -d replication || true
sql="CREATE PUBLICATION publication1 FOR all TABLES;"
sudo -u postgres psql -p $P_PORT -c "$sql;" -d replication

sql="ALTER SUBSCRIPTION subscription1 DISABLE;"
sudo -u postgres psql -p $S_PORT -c "$sql;" -d replication || true

sql="ALTER SUBSCRIPTION subscription1 SET (slot_name = NONE);"
sudo -u postgres psql -p $S_PORT -c "$sql;" -d replication || true

sql="drop   subscription subscription1"
sudo -u postgres psql -p $S_PORT -c "$sql;" -d replication || true


sql="CREATE SUBSCRIPTION subscription1
  CONNECTION 'host=127.0.0.1  port=$P_PORT dbname=replication user=$REPL_USER password=''$password'' '
  PUBLICATION publication1 WITH (failover = true);"
echo $sql
sudo -u postgres psql -p $S_PORT -c "$sql;" -d replication


echo "checking status of logical replication"
sql="SELECT pubname, puballtables FROM pg_publication;"
sudo -u postgres psql -p $P_PORT -c "$sql;" -d replication
sql="SELECT schemaname, tablename
FROM pg_publication_tables WHERE pubname = 'publication1' ORDER BY schemaname, tablename;"
sudo -u postgres psql -p $P_PORT -c "$sql;" -d replication
sql="SELECT pid, usename, application_name, client_addr, state,sent_lsn, write_lsn, flush_lsn, replay_lsn, sync_state
FROM pg_stat_replication;"
sudo -u postgres psql -p $P_PORT -c "$sql;" -d replication
sql="SELECT slot_name,slot_type, database,active, active_pid, restart_lsn, confirmed_flush_lsn
FROM pg_replication_slots where slot_type = 'logical';"
sudo -u postgres psql -p $P_PORT -c "$sql;" -d replication
sql="SELECT application_name, state, sync_state FROM pg_stat_replication;"
sudo -u postgres psql -p $P_PORT -c "$sql;" -d replication

sql="SELECT subname,subenabled,  subconninfo, subslotname, subpublications from pg_subscription;"
sudo -u postgres psql -p $S_PORT -c "$sql;" -d replication
sql="SELECT subname, pid, received_lsn, latest_end_lsn, latest_end_time
FROM pg_stat_subscription;"
sudo -u postgres psql -p $S_PORT -c "$sql;" -d replication

echo "checking contents of table logical1"
sql="SELECT application_name, state, sync_state FROM pg_stat_replication;"
sudo -u postgres psql -p $S_PORT -c "$sql;" -d replication

sql="INSERT INTO logical1 DEFAULT VALUES;"
sudo -u postgres psql -p $P_PORT -c "$sql;" -d replication

sql="select * from logical1;"
sudo -u postgres psql -p $P_PORT -c "$sql;" -d replication
sleep 1
sql="select * from logical1;"
sudo -u postgres psql -p $S_PORT -c "$sql;" -d replication

sql="SELECT application_name, state, sync_state FROM pg_stat_replication;"
sudo -u postgres psql -p $S_PORT -c "$sql;" -d replication
