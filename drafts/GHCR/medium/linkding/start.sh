#!/usr/bin/env bash

# Mirrors upstream bootstrap.sh, without its chown (the apps user owns /config).
export LD_SERVER_HOST="${LD_SERVER_HOST:-[::]}"
export LD_SERVER_PORT="${LD_SERVER_PORT:-9090}"

mkdir -p /config/data/favicons /config/data/previews /config/data/assets

cd /app/linkding || exit 1

# UNVERIFIED: generate_secret_key must keep the existing key on restart, or sessions break.
python manage.py generate_secret_key
python manage.py migrate
python manage.py enable_wal
# UNVERIFIED: create_initial_superuser exits non-zero when the user exists. The || true also hides other failures.
python manage.py create_initial_superuser || true
python manage.py migrate_tasks

# Background tasks run under supervisord, as in upstream bootstrap.sh.
# UNVERIFIED: supervisord-tasks.conf does not write pid or log files under /app/linkding.
if [[ "${LD_DISABLE_BACKGROUND_TASKS:-False}" != "True" ]]; then
  supervisord -c supervisord-tasks.conf
fi

exec uwsgi --http "${LD_SERVER_HOST}:${LD_SERVER_PORT}" uwsgi.ini
