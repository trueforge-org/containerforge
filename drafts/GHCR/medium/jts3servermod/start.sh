#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/logs

# Seed the default instance config only when /config/config is missing or empty.
# Existing user state is never overwritten.
if [ ! -d /config/config ] || [ -z "$(ls -A /config/config 2>/dev/null)" ]; then
    mkdir -p /config/config
    cp -a /defaults/jts3servermod-config/. /config/config/
fi

# JTS3_JAVA_ARGS is intentionally word-split so several JVM flags can be passed in one variable.
# shellcheck disable=SC2086
cd /app/jts3servermod
exec java ${JTS3_JAVA_ARGS:--Xmx256M} -Djava.io.tmpdir=/tmp \
  -jar JTS3ServerMod.jar -log "${JTS3_LOG:-/config/logs/JTS3ServerMod_InstanceManager.cfg}"
