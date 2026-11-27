#!/bin/sh
set -eu

mkdir -p /config/ds /config/lib /config/data /config/logs /config/rabbitmq /config/fonts \
  /tmp/nginx /tmp/supervisor /tmp/ds

# Seed local.json only when missing. UNVERIFIED: vendor default file name.
if [ ! -s /config/ds/local.json ]; then
  cp /etc/onlyoffice/documentserver/default.json /config/ds/local.json
fi

# Generate secrets once and keep them in /config (mode 600). Env values win.
gen_secret() {
  [ -s "$1" ] || { umask 077; head -c 48 /dev/urandom | base64 | tr -d '\n' > "$1"; }
}
gen_secret /config/ds/jwt_secret
gen_secret /config/ds/secure_link_secret
if [ -z "${JWT_SECRET:-}" ]; then
  JWT_SECRET="$(cat /config/ds/jwt_secret)"
fi
SECURE_LINK_SECRET="$(cat /config/ds/secure_link_secret)"
export JWT_SECRET SECURE_LINK_SECRET

# Apply env to local.json on every start (secrets are read by jq from the environment, not argv)
/scripts/render-config.sh

DB_HOST_VALUE="${DB_HOST:-postgresql}"
DB_PORT_VALUE="${DB_PORT:-5432}"
REDIS_HOST_VALUE="${REDIS_SERVER_HOST:-valkey}"
REDIS_PORT_VALUE="${REDIS_SERVER_PORT:-6379}"

# Wait up to 120 s for the database and Redis/Valkey. Continue either way, the services report the error.
i=0
until nc -z "${DB_HOST_VALUE}" "${DB_PORT_VALUE}" 2>/dev/null || [ "$i" -ge 60 ]; do
  i=$((i + 1)); sleep 2
done
until nc -z "${REDIS_HOST_VALUE}" "${REDIS_PORT_VALUE}" 2>/dev/null || [ "$i" -ge 60 ]; do
  i=$((i + 1)); sleep 2
done

# Create the schema once. DB must already exist (apps/postgresql creates it).
# UNVERIFIED: createdb.sql path in the vendor package
if nc -z "${DB_HOST_VALUE}" "${DB_PORT_VALUE}" 2>/dev/null; then
  exists="$(PGPASSWORD="${DB_PWD:-}" psql -h "${DB_HOST_VALUE}" -p "${DB_PORT_VALUE}" \
    -U "${DB_USER:-onlyoffice}" -d "${DB_NAME:-onlyoffice}" -tAc "select to_regclass('public.doc_changes')" || true)"
  if [ -z "${exists}" ]; then
    PGPASSWORD="${DB_PWD:-}" psql -h "${DB_HOST_VALUE}" -p "${DB_PORT_VALUE}" \
      -U "${DB_USER:-onlyoffice}" -d "${DB_NAME:-onlyoffice}" -v ON_ERROR_STOP=1 \
      -f /var/www/onlyoffice/documentserver/server/schema/postgresql/createdb.sql
  fi
else
  echo "Database ${DB_HOST_VALUE}:${DB_PORT_VALUE} not reachable, starting anyway" >&2
fi

# supervisord is PID 1 via exec and forwards signals to rabbitmq, docservice, converter and nginx
exec /usr/bin/supervisord -c /etc/onlyoffice-ds/supervisord.conf
