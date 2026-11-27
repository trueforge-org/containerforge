#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/data

# Seed the config only when it is missing. Never overwrite user edits.
# UNVERIFIED: whether templates are resolved relative to config/ or to the working directory.
if [[ ! -f /config/config/config.toml ]]; then
  mkdir -p /config/config
  cp -rn /app/vocechat/config/. /config/config/
fi

cd /config
exec /app/vocechat/vocechat-server config/config.toml "$@"
