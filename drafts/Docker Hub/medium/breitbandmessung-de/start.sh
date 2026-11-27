#!/usr/bin/env bash

mkdir -p /config/export /tmp/run

# seed config only when missing or empty; never overwrite user state
if [[ ! -s /config/config.cfg ]]; then
    cp /defaults/config.cfg /config/config.cfg
fi

get() { grep -E "^$1=" -m1 /config/config.cfg | cut -d= -f2-; }

RUN_ONCE="$(get run_once)"
RUN_ON_STARTUP="$(get run_on_startup)"
CRON="$(get crontab)"
export TZ="${TZ:-$(get timezone)}"

cd /app || exit 1

if [[ "${RUN_ON_STARTUP}" == "true" ]]; then
    node /app/index.js || echo "measurement failed"
fi

if [[ "${RUN_ONCE}" == "true" ]]; then
    exit 0
fi

echo "${CRON} node /app/index.js" > /tmp/run/crontab

exec supercronic /tmp/run/crontab
