#!/usr/bin/env bash
set -euo pipefail

export TMPDIR=/tmp

# Cloudreve resolves data/conf.ini, the SQLite database, uploads and temp files relative to the working directory.
# conf.ini is generated on the first start. Database and Redis settings come from CR_CONF_* on every start.
mkdir -p /config/data
cd /config

exec /app/cloudreve
