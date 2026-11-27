#!/bin/bash
set -euo pipefail

mkdir -p /config/bwapp/passwords /config/bwapp/images /config/bwapp/documents /config/bwapp/logs /tmp/apache/log

DB_HOST="${DB_HOST:-mariadb}"
DB_PORT="${DB_PORT:-3306}"

# Wait up to 120 s for the database. Apache starts regardless, the app reports the DB error.
i=0
until (exec 3<>"/dev/tcp/${DB_HOST}/${DB_PORT}") 2>/dev/null || [ "$i" -ge 60 ]; do
  i=$((i + 1)); sleep 2
done

# Apache in the background so the one-time install can run against it. Signals are forwarded below.
apache2 -f /defaults/apache2.conf -DFOREGROUND &
APACHE_PID=$!
trap 'kill -TERM "$APACHE_PID" 2>/dev/null' TERM INT

# UNVERIFIED: bWAPP install.php is browser-driven; the query string below is an assumption.
# Runs once, marked by /config/bwapp/.installed. The DB password is read from the environment by the PHP prepend file.
if [ ! -e /config/bwapp/.installed ]; then
  for _ in $(seq 1 30); do
    curl -fsS -o /dev/null "http://127.0.0.1:8080/" 2>/dev/null && break
    sleep 1
  done
  if curl -fsS -o /dev/null "http://127.0.0.1:8080/install.php?install=yes" 2>/dev/null; then
    touch /config/bwapp/.installed
  else
    echo "bWAPP install did not complete, will retry on next start" >&2
  fi
fi

wait "$APACHE_PID"
