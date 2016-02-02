su postgres -c 'pg_dump -h 127.0.0.1 deepsouthsounds > "/tmp/backup_$(date +"%m%d%Y%H%M%S.sql")"'
