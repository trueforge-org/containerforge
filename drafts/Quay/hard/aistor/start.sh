#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export MINIO_ROOT_USER="${MINIO_ROOT_USER:-minio}"

# Refuse to start with no root password. Never fall back to a fixed one.
if [[ -z "${MINIO_ROOT_PASSWORD:-}" ]]; then
  echo "MINIO_ROOT_PASSWORD is not set; refusing to start with no root password" >&2
  exit 1
fi

# Data lives in /config (persistent). The root password is read from the environment on
# every start, so a changed value applies to existing data.
mkdir -p /config/data

# The server reads MINIO_LICENSE and MINIO_BROWSER_REDIRECT_URL from the environment.
# UNVERIFIED: TLS needs --certs-dir /etc/minio/certs when a certificate is mounted (not added here).
exec /app/aistor/minio server --address ":9000" --console-address ":9001" /config/data
