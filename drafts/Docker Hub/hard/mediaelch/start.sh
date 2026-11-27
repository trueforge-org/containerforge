#!/usr/bin/env bash
# MediaElch wrapper for ContainerForge. The web desktop itself is the kasmvnc start script, which is not re-implemented here.

# create directory structure
mkdir -p \
    /config/.config/openbox \
    /config/.config \
    /tmp/.cache

# seed the openbox autostart once, so a user edit survives restarts
if [[ ! -s /config/.config/openbox/autostart ]]; then
    cp /defaults/autostart /config/.config/openbox/autostart
fi

exec /usr/local/bin/kasmvnc-start.sh "$@"
