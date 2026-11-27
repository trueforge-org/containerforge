#!/usr/bin/env bash
set -euo pipefail

# Persistent state under /config: mirror data, apt-mirror var and skel, and the config files.
mkdir -p /config/mirror /config/skel /config/var

# Seed the config files only when they are missing or empty. Existing user state is never overwritten.
if [ ! -s /config/mirror.list ]; then
    cp /defaults/mirror.list /config/mirror.list
fi
if [ ! -s /config/nginx.conf ]; then
    cp /defaults/apt-mirror-nginx.conf /config/nginx.conf
fi

if [ "${SYNC_ENABLED:-false}" = "true" ]; then
    # Background sync loop. A failed run is logged and retried at the next interval.
    (
        while true; do
            echo "[apt-mirror] sync started"
            if apt-mirror /config/mirror.list; then
                echo "[apt-mirror] sync finished"
            else
                echo "[apt-mirror] sync failed" >&2
            fi
            sleep "${SYNC_INTERVAL:-86400}"
        done
    ) &
else
    echo "[apt-mirror] SYNC_ENABLED is not true, so mirror sync is off"
fi

# nginx runs in the foreground and gets the signals, so exec it.
exec nginx -c /config/nginx.conf -g 'daemon off;'
