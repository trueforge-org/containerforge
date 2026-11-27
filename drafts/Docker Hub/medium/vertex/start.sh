#!/usr/bin/env bash
set -euo pipefail

# UNVERIFIED: upstream docker/start.sh was not read; this is written from the plan and the upstream Dockerfile.
# UNVERIFIED: config_backup contents (sql.db, *.yaml, json seeds) are assumed from the plan; check on first run.
b=/app/vertex/app/config_backup

# data folders the app writes to (mkdir -p is idempotent)
mkdir -p /config/{db,logs,torrents,config} \
  /config/data/{client,server,push,script,irc,race,site,setting,douban/set} \
  /config/data/rss /config/data/rule/{delete,rss,race,raceSet,link} \
  /config/data/watch/set

# seed only when missing, never overwrite user state
[ -f /config/db/sql.db ] || cp "$b/sql.db" /config/db/sql.db
if [ ! -f /config/config/config.yaml ]; then
  cp "$b"/*.yaml /config/config/
  cp /config/config/config.example.yaml /config/config/config.yaml
fi

export PORT="${PORT:-3000}"
export REDISPORT="${REDISPORT:-6379}"

# local redis only, data under /tmp so the rootfs stays read-only
redis-server --bind 127.0.0.1 --port "${REDISPORT}" --dir /tmp --daemonize yes

cd /app/vertex || exit 1
exec node app/app.js
