#!/bin/bash
su - postgres
psql -h 127.0.0.1 -c "CREATE USER deepsouthsounds WITH PASSWORD 'deepsouthsounds'"
psql -h 127.0.0.1 -c "CREATE DATABASE deepsouthsounds OWNER deepsouthsounds"
psql -h 127.0.0.1 deepsouthsounds < /tmp/20151025-203518.sql  
