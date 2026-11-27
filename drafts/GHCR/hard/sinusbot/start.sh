#!/usr/bin/env bash
# UNVERIFIED: config.ini.dist is assumed to be in the vendor tarball (upstream install.sh uses it).
# UNVERIFIED: whether the bot listens on 0.0.0.0 by default. Check config.ini ListenAddress/Port at runtime.
# Upstream runs yt-dlp -U on every start. It is not run here, because it writes and needs network.
set -eu

mkdir -p /config/data /config/scripts /tmp/home

# Seed the config only when missing. Never overwrite it.
if [ ! -f /config/config.ini ] && [ -f /app/sinusbot/config.ini.dist ]; then
    cp /app/sinusbot/config.ini.dist /config/config.ini
fi

# Seed the default scripts only into an empty scripts directory.
if [ -z "$(ls -A /config/scripts)" ] && [ -d /app/sinusbot/default_scripts ]; then
    cp -a /app/sinusbot/default_scripts/. /config/scripts/
fi

cd /app/sinusbot

# UNVERIFIED: the password is passed as an argument, so it is visible in the process list (upstream does the same).
if [ -n "${OVERRIDE_PASSWORD:-}" ]; then
    exec ./sinusbot "--override-password=${OVERRIDE_PASSWORD}"
fi

exec ./sinusbot
