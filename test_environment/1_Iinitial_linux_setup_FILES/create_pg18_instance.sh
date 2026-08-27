#!/usr/bin/env bash

set -Eeuo pipefail

# Create:
#
#   sudo ./create_instance.sh <instance-name> <port>
#
# Reinitialize:
#
#   sudo ./create_instance.sh --reinitialize <instance-name> <port>
#
# Examples:
#
#   sudo ./create_instance.sh publisher 5432
#   sudo ./create_instance.sh subscriber 5433
#
#   sudo ./create_instance.sh --reinitialize publisher 5432


SCRIPT_DIR="/databases/postgresql18"
REQUIREMENTS_FILE="${SCRIPT_DIR}/pg18_require.conf"
REPL_USER="repl1"
REPL_PASS=`openssl rand -base64 10 | head -c 16`
REINIT=0

source "${REQUIREMENTS_FILE}"
if [[ "${EUID}" -ne 0 ]]; then  die "Run this script as root." ;fi

make_vars()
{
    INSTANCE_ID="${INSTANCE_NAME}_${PORT}"
    INSTANCE_ROOT="${BASE_DIR}/${INSTANCE_ID}"
    DATA_DIR="${INSTANCE_ROOT}/data"
    SERVICE_NAME="postgresql${PG_VERSION}-${INSTANCE_ID}.service"
    SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}"
    PASSWORD_ENCRYPTION="scram-sha-256"

}

POSTGRESQL_CONF_TEMPLATE='

 # replication settings safe for primary and secondary
hot_standby = on
wal_level = replica
max_wal_senders = 10

listen_addresses = '\''@LISTEN_ADDRESSES@'\''
port = @PORT@
max_connections = @MAX_CONNECTIONS@
password_encryption = '\''@PASSWORD_ENCRYPTION@'\''

shared_buffers = @SHARED_BUFFERS@
work_mem = @WORK_MEM@
maintenance_work_mem = @MAINTENANCE_WORK_MEM@
autovacuum_work_mem = @AUTOVACUUM_WORK_MEM@
hash_mem_multiplier = @HASH_MEM_MULTIPLIER@
logical_decoding_work_mem = @LOGICAL_DECODING_WORK_MEM@

max_replication_slots = @MAX_REPLICATION_SLOTS@
max_worker_processes = @MAX_WORKER_PROCESSES@
max_logical_replication_workers = @MAX_LOGICAL_REPLICATION_WORKERS@
max_sync_workers_per_subscription = @MAX_SYNC_WORKERS_PER_SUBSCRIPTION@
max_parallel_apply_workers_per_subscription = @MAX_PARALLEL_APPLY_WORKERS_PER_SUBSCRIPTION@

logging_collector = @LOGGING_COLLECTOR@
log_directory = '\''@LOG_DIRECTORY@'\''
log_filename = '\''@INSTANCE_NAME@-%Y-%m-%d_%H%M%S.log'\''
log_line_prefix = '\''%m [%p] %u@%d '\''
log_connections = @LOG_CONNECTIONS@
log_disconnections = @LOG_DISCONNECTIONS@
cluster_name = '\''@INSTANCE_NAME@'\''
'

PG_HBA_TEMPLATE='

local   all             all                                 peer
host    all             all             127.0.0.1/32        scram-sha-256
host    replication     all             127.0.0.1/32        scram-sha-256
'


SERVICE_TEMPLATE='
[Unit]
Description=PostgreSQL @PG_VERSION@ - @INSTANCE_NAME@:@PORT@
Documentation=https://www.postgresql.org/docs/@PG_VERSION@/
After=network.target
Wants=network.target

[Service]
Type=@SERVICE_TYPE@

User=@PG_USER@
Group=@PG_GROUP@

ExecStart=@PG_BIN@/postgres -D @DATA_DIR@
ExecReload=/bin/kill -HUP $MAINPID
KillMode=mixed
KillSignal=SIGINT
TimeoutStartSec=@SERVICE_TIMEOUT_START@
TimeoutStopSec=@SERVICE_TIMEOUT_STOP@
OOMScoreAdjust=@OOM_SCORE_ADJUST@
Restart=@SERVICE_RESTART@
RestartSec=@SERVICE_RESTART_SEC@

[Install]
WantedBy=multi-user.target
'

make_config_file()
{
    local template="$1"
    local output="$2"

    echo "Making config file at $2"
    # Tkae template and submite repeated replaces and output to desitnation.
    printf '%s\n' "${template}" |
        sed \
	    -e "s|@LISTEN_ADDRESSES@|127.0.0.1|g" \
            -e "s|@PG_VERSION@|${PG_VERSION}|g" \
            -e "s|@PG_USER@|${PG_USER}|g" \
            -e "s|@PG_GROUP@|${PG_GROUP}|g" \
            -e "s|@PG_BIN@|${PG_BIN}|g" \
            -e "s|@DATA_DIR@|${DATA_DIR}|g" \
            -e "s|@PORT@|${PORT}|g" \
            -e "s|@INSTANCE_NAME@|${INSTANCE_NAME}-${PORT}|g" \
            -e "s|@LISTEN_ADDRESSES@|${LISTEN_ADDRESSES}|g" \
            -e "s|@PASSWORD_ENCRYPTION@|${PASSWORD_ENCRYPTION}|g" \
            -e "s|@MAX_CONNECTIONS@|${MAX_CONNECTIONS}|g" \
            -e "s|@SHARED_BUFFERS@|${SHARED_BUFFERS}|g" \
            -e "s|@WORK_MEM@|${WORK_MEM}|g" \
            -e "s|@MAINTENANCE_WORK_MEM@|${MAINTENANCE_WORK_MEM}|g" \
            -e "s|@AUTOVACUUM_WORK_MEM@|${AUTOVACUUM_WORK_MEM}|g" \
            -e "s|@HASH_MEM_MULTIPLIER@|${HASH_MEM_MULTIPLIER}|g" \
            -e "s|@LOGICAL_DECODING_WORK_MEM@|${LOGICAL_DECODING_WORK_MEM}|g" \
            -e "s|@MAX_REPLICATION_SLOTS@|${MAX_REPLICATION_SLOTS}|g" \
            -e "s|@MAX_WORKER_PROCESSES@|${MAX_WORKER_PROCESSES}|g" \
            -e "s|@MAX_LOGICAL_REPLICATION_WORKERS@|${MAX_LOGICAL_REPLICATION_WORKERS}|g" \
            -e "s|@MAX_SYNC_WORKERS_PER_SUBSCRIPTION@|${MAX_SYNC_WORKERS_PER_SUBSCRIPTION}|g" \
            -e "s|@MAX_PARALLEL_APPLY_WORKERS_PER_SUBSCRIPTION@|${MAX_PARALLEL_APPLY_WORKERS_PER_SUBSCRIPTION}|g" \
            -e "s|@LOGGING_COLLECTOR@|${LOGGING_COLLECTOR}|g" \
            -e "s|@LOG_DIRECTORY@|/var/log/postgresql|g" \
            -e "s|@LOG_CONNECTIONS@|${LOG_CONNECTIONS}|g" \
            -e "s|@LOG_DISCONNECTIONS@|${LOG_DISCONNECTIONS}|g" \
            -e "s|@SERVICE_TYPE@|${SERVICE_TYPE}|g" \
            -e "s|@SERVICE_TIMEOUT_START@|${SERVICE_TIMEOUT_START}|g" \
            -e "s|@SERVICE_TIMEOUT_STOP@|${SERVICE_TIMEOUT_STOP}|g" \
            -e "s|@OOM_SCORE_ADJUST@|${OOM_SCORE_ADJUST}|g" \
            -e "s|@SERVICE_RESTART@|${SERVICE_RESTART}|g" \
            -e "s|@SERVICE_RESTART_SEC@|${SERVICE_RESTART_SEC}|g" \
            > "${output}"
}


start()
{
    echo "Starting $INSTANCE_ID"
    echo "    systemctl enable '${SERVICE_NAME}'
    systemctl start '${SERVICE_NAME}'"

    systemctl enable "${SERVICE_NAME}"
    systemctl start "${SERVICE_NAME}"
    sleep 2

    if ! systemctl is-active --quiet "${SERVICE_NAME}"; then
        systemctl --no-pager --full status  "${SERVICE_NAME}" || true
        journalctl -u "${SERVICE_NAME}" --no-pager  -n 100 || true
        die "Failed to start ${INSTANCE_NAME}"
    fi
}


create()
{
    # Make the variables needed for config files. 
    make_vars

    # If option to reinit is given blow it away. 
    if [ $REINIT -gt 0 ]; then
      # Stop, disable, and remove previous install service file.  
      systemctl stop  "${SERVICE_NAME}" 2>/dev/null || true
      systemctl disable  "${SERVICE_NAME}" 2>/dev/null || true
      rm -f "${SERVICE_FILE}"
      systemctl daemon-reload
      
      if [ -d "/databases/postgresql18/$INSTANCE_ID" ]; then
	  echo "removing ${INSTANCE_ROOT}"
	  rm -rf /databases/postgresql18/$INSTANCE_ID
      fi	  
    fi

    # DO not delete data, abort if data exists.
    if [[ -d "${INSTANCE_ROOT}" ]]; then
	if [[ $# -ne 3 ]]; then
	    usage
	    echo "Instance already exists"
	    exit 1
        fi
      else    rm -rf --one-file-system  "${INSTANCE_ROOT}"
    fi

 # Make data directory and set permissions.    
    mkdir -p "${INSTANCE_ROOT}" "${DATA_DIR}"
    chown  "${PG_USER}:${PG_GROUP}" "${INSTANCE_ROOT}" "${DATA_DIR}"
    chmod 700  "${INSTANCE_ROOT}" "${DATA_DIR}"

# Intialize the database.
    runuser -u "${PG_USER}" -- "${PG_BIN}/initdb"  --pgdata="${DATA_DIR}"  --encoding="${PG_ENCODING}" --locale="${PG_LOCALE}"

# Make config files.     
    make_config_file  "${POSTGRESQL_CONF_TEMPLATE}" "${DATA_DIR}/postgresql.conf"
    make_config_file  "${POSTGRESQL_CONF_TEMPLATE}" "$SCRIPT_DIR/backup_${INSTANCE_ID}_postgresql.conf"
    
    make_config_file  "${PG_HBA_TEMPLATE}"  "${DATA_DIR}/pg_hba.conf"
    chown   "${PG_USER}:${PG_GROUP}"  "${DATA_DIR}/postgresql.conf" "${DATA_DIR}/pg_hba.conf"
    chmod 600  "${DATA_DIR}/postgresql.conf" "${DATA_DIR}/pg_hba.conf"

    make_config_file  "${SERVICE_TEMPLATE}" "${SERVICE_FILE}"
    chmod 644 "${SERVICE_FILE}"
    systemctl daemon-reload

    start

    echo "Setting up replication account: port $PORT"
    echo "saving password at /databases/postgresql18/$INSTANCE_ID.repl_password"
    echo "delete this file once replication works and save the password in secure location."
# Always add user. Id subscriber, its data will be erased when setup as a subscriber. 
    echo "$INSTANCE_ID:repl_password:$REPL_USER:$REPL_PASS:" >> /databases/postgresql18/$INSTANCE_ID.repl_password

    sql="CREATE ROLE $REPL_USER WITH REPLICATION LOGIN PASSWORD '$REPL_PASS'"
    sudo -u postgres psql -p $PORT -c "$sql;"

    sql="SELECT rolname, rolsuper, rolcreaterole,rolcreatedb, rolreplication,rolcanlogin
   FROM pg_roles   where rolname not like 'pg_%'  ORDER BY rolname;"
    sudo -u postgres psql -p $PORT -c "$sql;"

    sql="SELECT pg_create_physical_replication_slot('sub1');"
    sudo -u postgres psql -p $PORT -c "$sql;"

    sql="SELECT * FROM pg_replication_slots;"
    sudo -u postgres psql -p $PORT -P pager=off -c "$sql;"

    echo "done"
}


# usage

usage()
{
    cat <<EOF
PostgreSQL ${PG_VERSION} 

Create:
  sudo $0 <instance-name> <port>

Reinitialize:
  sudo $0 --reinitialize <instance-name> <port>

Examples:
  sudo $0 pub 5432
  sudo $0 sub 5433
  sudo $0 --reinitialize pub 5432

EOF
}

# main function

main()
{
    case "${1:-}" in

        --reinitialize)
            INSTANCE_NAME="$2"
            PORT="$3"
	    REINIT=1
            create
            ;;

	    # If help is the first option, print usage
        --help|-h)
            usage
            ;;

        "")
            # If no arguement given print usage. 
            usage
            exit 1
            ;;
        *)

            # Attempt to create the instance. 
            INSTANCE_NAME="$1"
            PORT="$2"

            create
            ;;
    esac
}

main "$@"
