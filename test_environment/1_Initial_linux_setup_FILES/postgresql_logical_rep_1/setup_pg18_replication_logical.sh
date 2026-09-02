#!/bin/bash
set -e

# --- Configuration & Variables ---
PG_VERSION="18"
BASE_DIR="/databases/postgresql18"
REPL_USER="repl1"

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
	pid=`sudo lsof -t -iTCP:$S_PORT -sTCP:LISTEN || true`
	if [ ! "$pid" = "" ]; then
	    kill -9 $pid || true
	fi
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

sql="CREATE SUBSCRIPTION subscription1
  CONNECTION 'host=127.0.0.1  port=$P_PORT dbname=replication user=rep1 password=''$password'''
  PUBLICATION logical_rep WITH (failover = true);"
echo $sql
sudo -u postgres psql -p $S_PORT -c "$sql;"

