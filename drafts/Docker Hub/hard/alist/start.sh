#!/usr/bin/env bash
set -e

# State lives in /config. Scratch and aria2 files live in /tmp (read-only rootfs).
mkdir -p /config/downloads /tmp/alist /tmp/aria2
export ALIST_TEMP_DIR="${ALIST_TEMP_DIR:-/tmp/alist}"
# An empty ALIST_SITE_URL would override the config file, so drop it when blank
if [[ -z "${ALIST_SITE_URL:-}" ]]; then
  unset ALIST_SITE_URL
fi

if [[ "${ENABLE_ARIA2:-false}" == "true" ]]; then
  touch /config/aria2.session
  if [[ -z "${ARIA2_RPC_SECRET:-}" ]]; then
    ARIA2_RPC_SECRET="$(head -c 24 /dev/urandom | base64 | tr -d '\n')"
    echo "ARIA2_RPC_SECRET not set: generated a random RPC secret for this start"
  fi
  # Subshell keeps the restrictive umask away from alist. The file is mode 600 so the secret
  # stays out of other users' reach and out of the process list (aria2 reads it from the file).
  (
    umask 077
    cat > /tmp/aria2/aria2.conf <<EOF
enable-rpc=true
rpc-listen-all=true
rpc-listen-port=6800
rpc-secret=${ARIA2_RPC_SECRET}
dir=/config/downloads
input-file=/config/aria2.session
save-session=/config/aria2.session
continue=true
EOF
  )
  aria2c --conf-path=/tmp/aria2/aria2.conf &
fi

# alist creates /config/config.json on first start and never overwrites it.
# --no-prefix is not passed, so ALIST_* environment variables apply.
cd /app
exec /app/alist server --data /config
