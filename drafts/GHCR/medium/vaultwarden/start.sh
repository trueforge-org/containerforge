#!/usr/bin/env bash
set -euo pipefail

# Vaultwarden keeps its state in DATA_FOLDER (/config) and creates it on first start.
# Nothing is seeded and nothing is written under /app.
mkdir -p /config

# web-vault is resolved from the working directory, so run from /app.
cd /app
exec /app/vaultwarden
