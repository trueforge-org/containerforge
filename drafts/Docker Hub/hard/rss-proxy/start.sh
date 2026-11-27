#!/usr/bin/env bash
set -euo pipefail

SECRETS_FILE=/config/secrets.env
mkdir -p /config /tmp

# Secrets: the upstream image ships the literal value "password". Generate random values once.
# A value set in the environment always wins over the file. Values are never placed on a command line.
touch "$SECRETS_FILE"
chmod 600 "$SECRETS_FILE"
for name in APP_JWT_SECRET APP_ROOT_SECRET_KEY APP_ACTUATOR_PASSWORD; do
  if ! grep -q "^${name}=" "$SECRETS_FILE"; then
    printf '%s=%s\n' "$name" "$(openssl rand -hex 32)" >> "$SECRETS_FILE"
  fi
  stored="$(sed -n "s/^${name}=//p" "$SECRETS_FILE" | head -n 1)"
  export "${name}=${!name:-$stored}"
done

# Defaults only when unset.
export APP_API_GATEWAY_URL="${APP_API_GATEWAY_URL:-http://localhost:8080}"
export APP_HOST_URL="${APP_HOST_URL:-http://localhost:8080}"
export APP_ROOT_EMAIL="${APP_ROOT_EMAIL:-admin@localhost}"

# No writes to /app. Temp files go to /tmp.
# UNVERIFIED: bind address (0.0.0.0) and the exact property names are not confirmed; check with an external probe.
exec java -Djava.io.tmpdir=/tmp -jar /app/rss-proxy.jar "$@"
