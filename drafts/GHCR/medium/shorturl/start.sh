#!/usr/bin/env bash

set -euo pipefail

# The database lives under /config. The -dbpath flag is documented on the upstream repo page.
mkdir -p /config/db

# UNVERIFIED: the flag that sets the listen address to 0.0.0.0:8000. The docs give a localhost default, so this
# draft is not reachable from other containers until that flag is added. Blocker until confirmed.
exec /app/shorturl/shorturl -dbpath /config/db/
