#!/usr/bin/env bash
set -euo pipefail

DATA_DIRECTORY="${DATA_DIRECTORY:-/config/data}"
PASSWORD_FILE="${PASSWORD_FILE:-/config/.htpasswd}"
mkdir -p "${DATA_DIRECTORY}" "$(dirname "${PASSWORD_FILE}")"

args=(--path "${DATA_DIRECTORY}" --listen ":8000")
if [ -n "${DISABLE_AUTHENTICATION:-}" ]; then
  args+=(--no-auth)
else
  if [ ! -f "${PASSWORD_FILE}" ]; then
    (umask 027; : > "${PASSWORD_FILE}")
  fi
  if [ ! -s "${PASSWORD_FILE}" ]; then
    echo "WARNING: no users in ${PASSWORD_FILE}; run create_user, or set DISABLE_AUTHENTICATION" >&2
  fi
  args+=(--htpasswd-file "${PASSWORD_FILE}")
fi

# OPTIONS is a flag string and is word-split on purpose, as upstream does.
# read returns non-zero on empty input, so guard it for set -e.
read -r -a extra <<< "${OPTIONS:-}" || true

exec /app/rest-server "${args[@]}" "${extra[@]}"
