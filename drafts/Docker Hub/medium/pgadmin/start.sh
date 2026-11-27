#!/usr/bin/env bash

mkdir -p /config/data /config/storage /tmp/pgadmin/sessions

# UNVERIFIED: the PGADMIN_CONFIG_* names and the gunicorn config path come from the plan
# and must be checked against the installed pgadmin4 wheel before the first build.
export PGADMIN_CONFIG_DATA_DIR=/config/data
export PGADMIN_CONFIG_SESSION_DIR=/tmp/pgadmin/sessions
export PGADMIN_CONFIG_STORAGE_DIR=/config/storage
export PGADMIN_CONFIG_LOG_FILE=/tmp/pgadmin/pgadmin.log

cd /app/pgadmin || exit 1
exec /app/pgadmin/venv/bin/gunicorn \
  --bind 0.0.0.0:5050 \
  --workers 1 \
  --threads 25 \
  --config /app/pgadmin/venv/lib/python3.15/site-packages/pgadmin4/gunicorn_config.py \
  pgadmin4:app
