#!/bin/bash

set -e

export COMMAND=${1:-dump}
export CRON_SCHEDULE=${CRON_SCHEDULE:-0 1 * * *}
export PREFIX=${PREFIX:-dump}
export ETCD_CLIENT_IP=${ETCD_CLIENT_IP:-127.0.0.1}
export PROJECT_NAME=${PROJECT_NAME:-dump}

confd -onetime -backend etcd -node http://${ETCD_CLIENT_IP}:2379 --prefix="/postgres-config/${PROJECT_NAME}"
chmod +x /dump.sh

if [[ "$COMMAND" == 'dump' ]]; then
    exec /dump.sh
elif [[ "$COMMAND" == 'dump-cron' ]]; then
    LOGFIFO='/var/log/cron.fifo'
    if [[ ! -e "$LOGFIFO" ]]; then
        mkfifo "$LOGFIFO"
    fi
    CRON_ENV="PREFIX='$PREFIX'"
    
    if [ ! -z "$DELETE_OLDER_THAN" ]; then
    	CRON_ENV="$CRON_ENV\nDELETE_OLDER_THAN='$DELETE_OLDER_THAN'"
    fi
    
    echo -e "$CRON_ENV\n$CRON_SCHEDULE /dump.sh > $LOGFIFO 2>&1" | crontab -
    crontab -l
    crond
    tail -f "$LOGFIFO"
else
    echo "Unknown command $COMMAND"
    echo "Available commands: dump, dump-cron"
    exit 1
fi
