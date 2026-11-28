#!/usr/bin/env bash

# State (config.ini, database, logs) lives in /config, /app is read-only.
mkdir -p /config/data

exec python /app/couchpotato/CouchPotato.py \
    --console_log \
    --data_dir=/config/data \
    --config_file=/config/config.ini
