#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/data

# Seed the JWT secret once. Keep it in /config so restarts reuse it.
secret_file=/config/jwt_secret_key
if [ -z "${JWT_SECRET_KEY:-}" ] || [ "${JWT_SECRET_KEY}" = "PLEASE_CHANGE_ME" ]; then
  if [ ! -s "${secret_file}" ]; then
    head -c 48 /dev/urandom | base64 > "${secret_file}"
    chmod 600 "${secret_file}"
  fi
  JWT_SECRET_KEY="$(cat "${secret_file}")"
fi
export JWT_SECRET_KEY
export STORAGE_PATH="${STORAGE_PATH:-/config/data}"
export DEBUG="${DEBUG:-False}"

# UNVERIFIED: the upstream entrypoint.sh body was not read. It also removes the IPv6 bind from wsgi.ini when IPv6 is
# unavailable. Copy that step if the container has no IPv6.
cd /app/kitchenowl/backend
exec /app/venv/bin/uwsgi wsgi.ini --gevent 200 --max-fd 1048576
