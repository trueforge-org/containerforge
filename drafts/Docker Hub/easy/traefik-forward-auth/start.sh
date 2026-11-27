#!/usr/bin/env bash
set -euo pipefail

SECRET_FILE=/config/secret

# Stable cookie secret. Generated once and reused, so restarts do not sign out every user.
# Multiple replicas must set SECRET explicitly to the same value.
if [ -z "${SECRET:-}" ]; then
  if [ ! -s "${SECRET_FILE}" ]; then
    echo "[traefik-forward-auth] SECRET not set, generating one in ${SECRET_FILE}"
    (umask 077 && head -c 32 /dev/urandom | base64 | tr -d '\n' > "${SECRET_FILE}")
  fi
  SECRET="$(cat "${SECRET_FILE}")"
  export SECRET
fi

# Empty optional values must not reach the app as configured values.
for v in AUTH_HOST COOKIE_DOMAIN LOGOUT_REDIRECT DOMAIN WHITELIST CONFIG "${!PROVIDERS_@}"; do
  if [ -z "${!v-x}" ]; then
    unset "$v"
  fi
done

# UNVERIFIED: how the flag parser treats empty env values. Unsetting them avoids the question.
exec /app/traefik-forward-auth
