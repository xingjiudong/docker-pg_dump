#!/bin/bash

set -e

export COMMAND=${1:-dump}
export CRON_SCHEDULE=${CRON_SCHEDULE:-0 1 * * *}
export PREFIX=${PREFIX:-dump}
export PGUSER=${PGUSER:-postgres}
export PGDB=${PGDB:-postgres}
export PGHOST=${PGHOST:-db}
export PGPORT=${PGPORT:-5432}

if [[ "$COMMAND" == 'dump' ]]; then
    exec /dump.sh
elif [[ "$COMMAND" == 'dump-cron' ]]; then
    LOGFIFO='/var/log/cron.fifo'
    if [[ ! -e "$LOGFIFO" ]]; then
        mkfifo "$LOGFIFO"
    fi
    CRON_ENV="PREFIX='$PREFIX'\nPGUSER='$PGUSER'\nPGDB='$PGDB'\nPGHOST='$PGHOST'\nPGPORT='$PGPORT'"
    if [ -n "$PGPASSWORD" ]; then
        CRON_ENV="$CRON_ENV\nPGPASSWORD='$PGPASSWORD'"
    fi
    
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
