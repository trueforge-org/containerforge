#!/usr/bin/env bash
# UNVERIFIED: Lemur CLI forms (`lemur db upgrade`, `lemur start -b`), the LEMUR_CONF variable
# and the Lemur config key names must be checked against Lemur 1.9.3 during the build test.
# CFSSL serve flags are taken from the CFSSL docs and are also UNVERIFIED here.
set -euo pipefail

SECRETS_FILE=/config/lemur.secrets
CFSSL_DIR=/config/cfssl
export LEMUR_CONF="${LEMUR_CONF:-/config/lemur.conf.py}"

umask 077

mkdir -p /config "${CFSSL_DIR}"

# Seed defaults only when missing or empty. Existing user state is never overwritten.
if [ ! -s "${LEMUR_CONF}" ]; then
  cp /defaults/lemur.conf.py "${LEMUR_CONF}"
fi
for file in ca-config.json ca-csr.json; do
  if [ ! -s "${CFSSL_DIR}/${file}" ]; then
    cp "/defaults/cfssl/${file}" "${CFSSL_DIR}/${file}"
  fi
done

# Generate secrets once. Values are never logged.
gen_secret() { openssl rand -base64 48 | tr -d '\n'; }
if [ ! -s "${SECRETS_FILE}" ]; then
  {
    echo "LEMUR_SECRET_KEY=$(gen_secret)"
    echo "LEMUR_TOKEN_SECRET=$(gen_secret)"
    echo "LEMUR_ENCRYPTION_KEYS=$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '\n')"
  } > "${SECRETS_FILE}"
  echo "Generated Lemur secrets in ${SECRETS_FILE}"
fi

# Environment values win over the stored secrets. Stored values fill the gaps.
for name in LEMUR_SECRET_KEY LEMUR_TOKEN_SECRET LEMUR_ENCRYPTION_KEYS; do
  if [ -z "${!name:-}" ]; then
    value="$(grep -m1 "^${name}=" "${SECRETS_FILE}" | cut -d= -f2-)"
    export "${name}=${value}"
  fi
done

# Create the CFSSL root CA once. The key stays in /config with mode 0600.
if [ ! -s "${CFSSL_DIR}/ca.pem" ]; then
  echo "Generating CFSSL root CA in ${CFSSL_DIR}"
  (cd "${CFSSL_DIR}" && cfssl genkey -initca ca-csr.json | cfssljson -bare ca)
  chmod 600 "${CFSSL_DIR}/ca-key.pem"
fi

# CFSSL runs in the background. Keep the working directory off /config.
cd /tmp
cfssl serve -address 0.0.0.0 -port 8888 \
  -ca "${CFSSL_DIR}/ca.pem" \
  -ca-key "${CFSSL_DIR}/ca-key.pem" \
  -config "${CFSSL_DIR}/ca-config.json" &
CFSSL_PID=$!

LEMUR_PID=""
shutdown() {
  if [ -n "${LEMUR_PID}" ]; then
    kill -TERM "${LEMUR_PID}" 2>/dev/null || true
  fi
  kill -TERM "${CFSSL_PID}" 2>/dev/null || true
}
trap shutdown TERM INT

if [ -z "${LEMUR_DATABASE_URI:-}" ]; then
  echo "WARNING: LEMUR_DATABASE_URI is not set. Only CFSSL is running. Set it to start Lemur." >&2
  wait "${CFSSL_PID}" || true
  exit 0
fi

# Wait for PostgreSQL with a bounded retry. Only host and port are read from the URI.
read -r db_host db_port <<< "$(/app/venv/bin/python -I -c '
import os
from urllib.parse import urlsplit
u = urlsplit(os.environ["LEMUR_DATABASE_URI"])
print(u.hostname or "", u.port or 5432)
')"

db_ready=0
for attempt in $(seq 1 60); do
  if (exec 3<>"/dev/tcp/${db_host}/${db_port}") 2>/dev/null; then
    db_ready=1
    break
  fi
  echo "Waiting for database at ${db_host}:${db_port} (attempt ${attempt}/60)"
  sleep 2
done
if [ "${db_ready}" -ne 1 ]; then
  echo "ERROR: database at ${db_host}:${db_port} is not reachable" >&2
  shutdown
  exit 1
fi

# Migrations are idempotent and run on every start.
/app/venv/bin/lemur db upgrade

# Lemur runs in the background as well, because CFSSL shares this container.
# A single exec is not possible here, so the script waits for either process to exit.
/app/venv/bin/lemur start -b 0.0.0.0:8000 &
LEMUR_PID=$!

set +e
wait -n
status=$?
set -e
shutdown
wait 2>/dev/null || true
exit "${status}"
