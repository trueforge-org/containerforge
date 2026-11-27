#!/usr/bin/env bash
set -euo pipefail

export SSHWIFTY_LISTENINTERFACE="${SSHWIFTY_LISTENINTERFACE:-0.0.0.0}"
export SSHWIFTY_LISTENPORT="${SSHWIFTY_LISTENPORT:-8182}"

# Optional TLS material passed as env (same as the upstream image). Kept in /tmp, mode 0600.
if [ -n "${SSHWIFTY_DOCKER_TLSCERT:-}" ] && [ -n "${SSHWIFTY_DOCKER_TLSCERTKEY:-}" ]; then
  umask 077
  printf '%s\n' "${SSHWIFTY_DOCKER_TLSCERT}" > /tmp/cert
  printf '%s\n' "${SSHWIFTY_DOCKER_TLSCERTKEY}" > /tmp/certkey
  export SSHWIFTY_TLSCERTIFICATEFILE=/tmp/cert
  export SSHWIFTY_TLSCERTIFICATEKEYFILE=/tmp/certkey
fi

# A user-provided config file wins over env, but only when it exists.
if [ -z "${SSHWIFTY_CONFIG:-}" ] && [ -s /config/sshwifty.conf.json ]; then
  export SSHWIFTY_CONFIG=/config/sshwifty.conf.json
fi

cd /config
exec /app/sshwifty
