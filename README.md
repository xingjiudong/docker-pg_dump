xingjiudong/pg_dump
================

Docker image with pg_dump running as a cron task. Find the image, here: https://hub.docker.com/r/xingjiudong/pg_dump

## Usage

## ETCD Config
etcdctl set /postgres-config/${PROJECT_NAME}/postgres1 '{"PGHOST":"192.168.0.1","PGPORT":"5432","PGUSER":"postgres","PGPASSWORD":"password","PGDB":"postgres"}'
etcdctl set /postgres-config/${PROJECT_NAME}/postgres2 '{"PGHOST":"192.168.0.2","PGPORT":"5432","PGUSER":"postgres","PGPASSWORD":"password","PGDB":"postgres"}'
...............


Attach a target postgres container to this container and mount a volume to container's `/dump` folder. Backups will appear in this volume. Optionally set up cron job schedule (default is `0 1 * * *` - runs every day at 1:00 am).

## Environment Variables:
| Variable | Required? | Default | Description |
| -------- |:--------- |:------- |:----------- |
| `PGUSER` | Required | postgres | The user for accessing the database |
| `PGPASSWORD` | Optional | `None` | The password for accessing the database |
| `PGDB` | Optional | postgres | The name of the database |
| `PGHOST` | Optional | db | The hostname of the database |
| `PGPORT` | Optional | `5432` | The port for the database |
| `CRON_SCHEDULE` | Required | 0 1 * * * | The cron schedule at which to run the pg_dump |
| `DELETE_OLDER_THAN` | Optional | `None` | Optionally, delete files older than `DELETE_OLDER_THAN` minutes. Do not include `+` or `-`. |

Example:
```
postgres-backup:
  image: xingjiduong/pg_dump
  container_name: postgres-backup
  links:
    - postgres:db #Maps postgres as "db"
  environment:
    - PGUSER=postgres
    - PGPASSWORD=SumPassw0rdHere
    - CRON_SCHEDULE=* * * * * #Every minute
    - DELETE_OLDER_THAN=1 #Optionally delete files older than $DELETE_OLDER_THAN minutes.
    - ETCD_CLIENT_IP=${ETCD_CLIENT_IP}
    - PROJECT_NAME=${PROJECT_NAME} 

  #  - PGDB=postgres # The name of the database to dump
  #  - PGHOST=db # The hostname of the PostgreSQL database to dump
  volumes:
    - /dump
  command: dump-cron
```

Run backup once without cron job, use "mybackup" as backup file prefix, shell will ask for password:

    docker run -ti --rm \
        -v /path/to/target/folder:/dump \   # where to put db dumps
        -e PREFIX=mybackup \
        --link my-postgres-container:db \   # linked container with running mongo
        -e ETCD_CLIENT_IP=${ETCD_CLIENT_IP} \
        -e PROJECT_NAME=${PROJECT_NAME} \
        xingjiudong/pg_dump dump
