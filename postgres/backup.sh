su - postgres -c pg_dump deepsouthsounds > /tmp/dss.sql
scp /tmp/dss.sql fergalm@home.bitchmints.com:/srv/dev/
