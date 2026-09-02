#!/usr/bin/env bash

# Setup failure even in pipe. 
set -Eeuo pipefail

# PostgreSQL 18 - Start/Stop All Instances
#
# Usage:
#
#   sudo ./postgresql-services.sh start
#   sudo ./postgresql-services.sh stop
#   sudo ./postgresql-services.sh restart

PG_VERSION="18"
BASE_DIR="/databases/postgresql${PG_VERSION}"
SERVICE_PREFIX="postgresql${PG_VERSION}-"
servicedir=/etc/systemd/system

if [[ "${EUID}" -ne 0 ]]; then
    echo "ERROR: Run this script as root."
    exit 1
fi

# Find the postgresql servcices

get_services()
{
    find $servicedir \
        -maxdepth 1 \
        -type f \
        -name "${SERVICE_PREFIX}*.service" \
        -printf '%f\n' |
        sort
}


# start function

start_all()
{
    local failed=0
    for SERVICE in "${SERVICES[@]}"; do
        echo "Starting ${SERVICE}"
        if systemctl start "${SERVICE}"; then     echo "  OK"
        else                                     echo "  FAILED";    failed=1
        fi
    done

    if (( failed != 0 )); then
        echo "One of instances failed to start."
        exit 1
    fi

    echo "All PostgreSQL ${PG_VERSION} instances started."
}

# stop function


stop_all()
{

    local failed=0
    for SERVICE in "${SERVICES[@]}"; do  echo "Stopping ${SERVICE}"
        if systemctl stop "${SERVICE}"; then   echo "  OK"
        else                                   echo "  FAILED"; failed=1
        fi
    done

    if (( failed != 0 )); then
        echo "One or more PostgreSQL instances failed to stop."
        exit 1
    fi

    echo "All PostgreSQL ${PG_VERSION} instances stopped."
}

# restart function

restart_all()
{
    local failed=0

    for SERVICE in "${SERVICES[@]}"; do
        echo "Restarting ${SERVICE}"
        if systemctl restart "${SERVICE}"; then   echo "  OK"
        else                                      echo "  FAILED" ; failed=1
        fi
    done
    if (( failed != 0 )); then
        echo "One or more PostgreSQL ${PG_VERSION}  instances failed to restart."
        exit 1
    fi
    echo "All PostgreSQL ${PG_VERSION} instances restarted."
}

# Usage

usage()
{
    cat <<EOF

PostgreSQL ${PG_VERSION} Instance stop and start services

Usage:

  sudo $0 start
  sudo $0 stop
  sudo $0 restart

Commands:

  start
      Start all PostgreSQL${PG_VERSION} instance services.

  stop
     Stop all PostgreSQL${PG_VERSION} instance services.

  restart
      Restart all PostgreSQL${PG_VERSION} instance services.

EOF
}

# main function

mapfile -t SERVICES < <(get_services)

if [[ "${#SERVICES[@]}" -eq 0 ]]; then
    usage
    echo 
    echo "No PostgreSQL installations were found."
    echo " Service files should take the format:  /etc/systemd/system/postgresql-<name>_<port>.service"
    exit 1
fi


main()
{
    case "${1:-}" in
        start)
            start_all
            ;;
        stop)
            stop_all
            ;;
        restart)
            restart_all
            ;;
        help|-h|--help)
            usage
            ;;
        *)
            usage
            exit 1
            ;;
    esac
}

main "$@"
