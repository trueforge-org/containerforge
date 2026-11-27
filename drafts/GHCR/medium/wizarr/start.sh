#!/usr/bin/env bash

# the database is written under /data/database, a symlink to /config/data/database (see Dockerfile)
mkdir -p /config/data/database

cd /app/wizarr || exit 1

# apply migrations on every start; the scheduler is not needed for this step
FLASK_SKIP_SCHEDULER=true /app/wizarr/.venv/bin/flask db upgrade

exec /app/wizarr/.venv/bin/gunicorn \
    --config gunicorn.conf.py \
    --umask 007 \
    run:app
