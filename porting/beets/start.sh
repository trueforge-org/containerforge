#!/usr/bin/env bash

# check if /config is writable
if [[ -w /config ]]; then
    # copy config
    cp -n /defaults/beets.sh /config/beets.sh
    cp -n /defaults/config.yaml /config/config.yaml
    chmod +x /config/beets.sh
else
    # use /tmp fallback when /config is readonly
    echo "Warning: /config is read-only, using /tmp for runtime config"
    mkdir -p /tmp/beets
    [ -f /defaults/beets.sh ] && cp /defaults/beets.sh /tmp/beets/beets.sh
    [ -f /defaults/config.yaml ] && cp /defaults/config.yaml /tmp/beets/config.yaml
    chmod +x /tmp/beets/beets.sh 2>/dev/null || true
    export HOME=/tmp/beets
fi

exec beet web
