#!/usr/bin/env bash
set -euo pipefail

export TZ="${TZ:-Etc/UTC}"
: "${PHOENIX_HTTP_PORT:=13000}"
: "${EXTERNAL_URL:=http://localhost:${PHOENIX_HTTP_PORT}}"
: "${DATABASE_HOST:=postgres}"
: "${DATABASE_PORT:=5432}"
: "${RESET_ADMIN_ON_BOOT:=false}"
export EXTERNAL_URL DATABASE_HOST DATABASE_PORT PHOENIX_HTTP_PORT

# persistent state (wireguard key, saml cert, telemetry id) and ephemeral release dir
mkdir -p /config/firezone /tmp/release

# generated secrets are created once and reused on every start, user-provided env wins
secrets=/config/firezone/secrets.env
if [[ ! -s "${secrets}" ]]; then
  (
    umask 077
    {
      printf 'SECRET_KEY_BASE=%s\n' "$(openssl rand -base64 48 | tr -d '\n')"
      printf 'GUARDIAN_SECRET_KEY=%s\n' "$(openssl rand -base64 48 | tr -d '\n')"
      printf 'DATABASE_ENCRYPTION_KEY=%s\n' "$(openssl rand -base64 32 | tr -d '\n')"
      printf 'LIVE_VIEW_SIGNING_SALT=%s\n' "$(openssl rand -base64 24 | tr -d '\n')"
      printf 'COOKIE_SIGNING_SALT=%s\n' "$(openssl rand -base64 24 | tr -d '\n')"
      printf 'COOKIE_ENCRYPTION_SALT=%s\n' "$(openssl rand -base64 24 | tr -d '\n')"
    } > "${secrets}"
  )
fi
# only fill in values that are not already set in the environment
while IFS='=' read -r key value; do
  [[ -n "${key}" ]] || continue
  [[ -n "${!key:-}" ]] || export "${key}=${value}"
done < "${secrets}"

# WireGuard data plane needs CAP_NET_ADMIN. Without it the portal still runs,
# but no tunnels can be created. The upstream bootstrap is not run here.
if ip link add cf-nettest0 type wireguard >/dev/null 2>&1; then
  ip link del cf-nettest0 >/dev/null 2>&1 || true
else
  echo "WireGuard interface setup skipped: missing NET_ADMIN"
fi

# wait for postgresql, keep the process alive while it is unavailable
until timeout 2 bash -c "</dev/tcp/${DATABASE_HOST}/${DATABASE_PORT}" >/dev/null 2>&1; do
  echo "waiting for database ${DATABASE_HOST}:${DATABASE_PORT}"
  sleep 5
done

/app/bin/firezone eval FzHttp.Release.migrate

if [[ "${RESET_ADMIN_ON_BOOT}" == "true" ]]; then
  /app/bin/firezone eval FzHttp.Release.create_admin_user
fi

exec /app/bin/firezone start
