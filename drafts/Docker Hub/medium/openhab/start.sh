#!/usr/bin/env bash
set -eu

# All writable state lives under /config. Nothing is written to /app.
mkdir -p /config/conf /config/userdata/logs /config/userdata/backup /config/addons

# Seed the default conf only when it is empty, never overwrite user state
if [ -z "$(ls -A /config/conf 2>/dev/null)" ]; then
  cp -a /defaults/conf/. /config/conf/
fi

cd /app/openhab

# UNVERIFIED: the distro start.sh runs Karaf in the foreground and reads EXTRA_JAVA_OPTS. Confirm on the first run.
exec ./start.sh
