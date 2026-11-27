#!/usr/bin/env bash
# LANraragi start for ContainerForge. Writable state lives in /config and /tmp; /app is read-only.

# create directory structure
mkdir -p \
    /config/content \
    /config/thumb \
    /config/database \
    /config/plugins/Sideloaded \
    /config/plugins/Managed \
    /tmp/lrr

# Valkey runs in the container and listens on localhost only (as upstream does).
# UNVERIFIED: upstream redis.conf contents and the directory settings for content, thumb and plugins
# (env var or lrr.conf override) are not confirmed; the app may still write under /app.
valkey-server --bind 127.0.0.1 --port 6379 --dir /config/database --daemonize no &
VALKEY_PID=$!

for _ in $(seq 1 30); do
    if [[ "$(valkey-cli -h 127.0.0.1 ping 2>/dev/null)" == "PONG" ]]; then
        break
    fi
    sleep 1
done

# UNVERIFIED: launch command. The upstream s6 run script is not ported, so this is a guess at launcher.pl usage.
cd /app/lanraragi || exit 1
perl ./script/launcher.pl -d ./script/lanraragi &
APP_PID=$!

# forward TERM and INT to both processes
trap 'kill -TERM "${APP_PID}" "${VALKEY_PID}" 2>/dev/null' TERM INT
wait "${APP_PID}"
status=$?
kill -TERM "${VALKEY_PID}" 2>/dev/null
exit "${status}"
