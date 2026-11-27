#!/usr/bin/env bash
set -euo pipefail

# UNVERIFIED: whether the bot idles or exits without DISCORD_TOKEN (plan section 10). Only the presence is logged, never the value.
if [[ -z "${DISCORD_TOKEN:-}" ]]; then
    echo "[promcord] DISCORD_TOKEN is not set; the bot cannot connect to Discord." >&2
fi

# /app is read-only at runtime, so JVM temp files go to /tmp.
exec java -Djava.io.tmpdir=/tmp -jar /app/promcord/promcord.jar
