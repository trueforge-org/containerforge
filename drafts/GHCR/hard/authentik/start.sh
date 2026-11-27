#!/usr/bin/env bash
set -euo pipefail

export TMPDIR=/tmp
export HOME=/tmp

# Persistent state under /config. Created only when missing (idempotent).
# /certs, /data and /media are symlinks to these paths in the image.
mkdir -p /config/certs /config/data /config/media

# Secrets come from the environment only. They are never written to files here.
# UNVERIFIED: AUTHENTIK_SECRET_KEY name and the AUTHENTIK_* nesting (__) convention, not checked in lifecycle/ak.
if [ -z "${AUTHENTIK_SECRET_KEY:-}" ]; then
  echo "Error: AUTHENTIK_SECRET_KEY is required." >&2
  exit 1
fi

# UNVERIFIED: default.yml reads the Postgres password from env POSTGRES_PASSWORD.
if [ -z "${POSTGRES_PASSWORD:-}" ]; then
  echo "Error: POSTGRES_PASSWORD is required (PostgreSQL dependency)." >&2
  exit 1
fi

# Final long-running process. UNVERIFIED: the 'server' role argument of lifecycle/ak was not read.
# Single process per container. The worker role is not started here (plan section 10, blocker 2).
exec /lifecycle/ak server "$@"
