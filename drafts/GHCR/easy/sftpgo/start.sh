#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/data /config/backups

# Seed the config only when missing or empty. Relative paths (sqlite db, backups)
# resolve against the working directory, which is /config below.
if [ ! -s /config/sftpgo.json ]; then
  sed 's|"users_base_dir": ""|"users_base_dir": "/config/data"|' /defaults/sftpgo.json > /config/sftpgo.json
fi

# UNVERIFIED: config discovery from the working directory; `-c` not confirmed, so not passed.
cd /config
exec sftpgo serve
