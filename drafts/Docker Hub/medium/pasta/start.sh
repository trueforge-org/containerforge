#!/usr/bin/env bash

# pasta creates its own state under PASTA_CONFIG_DIR (/config); this guards an empty volume
mkdir -p "${PASTA_CONFIG_DIR:-/config}"

cd /app || exit 1

# UNVERIFIED: the server listens on all interfaces; confirm the listen call in server/src/index.ts
exec node --disable-warning=ExperimentalWarning server/src/index.ts "$@"
