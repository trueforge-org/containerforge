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

# state paths: the 0.7.x defaults are under /var/firezone (not writable here), env names are the upper-cased config keys
export WIREGUARD_PRIVATE_KEY_PATH="${WIREGUARD_PRIVATE_KEY_PATH:-/config/firezone/private_key}"
export SAML_KEYFILE_PATH="${SAML_KEYFILE_PATH:-/config/firezone/saml.key}"
export SAML_CERTFILE_PATH="${SAML_CERTFILE_PATH:-/config/firezone/saml.crt}"
export TELEMETRY_ENABLED="${TELEMETRY_ENABLED:-false}"

# self-signed SAML cert, only created when missing (as upstream bootstrap does)
if [[ ! -f "${SAML_KEYFILE_PATH}" || ! -f "${SAML_CERTFILE_PATH}" ]]; then
  openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 \
    -keyout "${SAML_KEYFILE_PATH}" -out "${SAML_CERTFILE_PATH}" \
    -subj "/C=US/ST=Denial/L=Firezone/O=Dis/CN=www.example.com" >/dev/null 2>&1
fi

# WireGuard data plane needs CAP_NET_ADMIN. Without it the portal still runs,
# but no tunnels can be created. The upstream bootstrap is not run here.
if ip link add cf-nettest0 type wireguard >/dev/null 2>&1; then
  ip link del cf-nettest0 >/dev/null 2>&1 || true
  # same steps as the upstream bootstrap script (interface, addresses, mtu, routes)
  : "${WIREGUARD_INTERFACE_NAME:=wg-firezone}" "${WIREGUARD_MTU:=1280}"
  : "${WIREGUARD_IPV4_ENABLED:=true}" "${WIREGUARD_IPV4_ADDRESS:=10.3.2.1}" "${WIREGUARD_IPV4_NETWORK:=10.3.2.0/24}"
  : "${WIREGUARD_IPV6_ENABLED:=true}" "${WIREGUARD_IPV6_ADDRESS:=fd00::3:2:1}" "${WIREGUARD_IPV6_NETWORK:=fd00::3:2:0/120}"
  ip link show "${WIREGUARD_INTERFACE_NAME}" >/dev/null 2>&1 || ip link add "${WIREGUARD_INTERFACE_NAME}" type wireguard
  [[ "${WIREGUARD_IPV4_ENABLED}" != "true" ]] || ip address replace "${WIREGUARD_IPV4_ADDRESS}" dev "${WIREGUARD_INTERFACE_NAME}"
  [[ "${WIREGUARD_IPV6_ENABLED}" != "true" ]] || ip -6 address replace "${WIREGUARD_IPV6_ADDRESS}" dev "${WIREGUARD_INTERFACE_NAME}"
  ip link set mtu "${WIREGUARD_MTU}" up dev "${WIREGUARD_INTERFACE_NAME}"
  [[ "${WIREGUARD_IPV4_ENABLED}" != "true" ]] || ip route replace "${WIREGUARD_IPV4_NETWORK}" dev "${WIREGUARD_INTERFACE_NAME}"
  [[ "${WIREGUARD_IPV6_ENABLED}" != "true" ]] || ip -6 route replace "${WIREGUARD_IPV6_NETWORK}" dev "${WIREGUARD_INTERFACE_NAME}"
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
