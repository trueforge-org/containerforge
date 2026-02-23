#!/usr/bin/env bash

set -euo pipefail

KEYFILE="/config/.fernetkey"

# generate fernet key for ldap if it doesn't exist
if [[ ! -f "${KEYFILE}" ]]; then
    if [[ -z "${FERNETKEY:-}" ]]; then
        KEY=$(/app/venv/bin/python /app/fernet-key.py)
        echo "generated fernet key"
    elif ! /app/venv/bin/python -c "from cryptography.fernet import Fernet; Fernet(b'${FERNETKEY}').encrypt(b'my deep dark secret')" 2>/dev/null; then
        echo "FERNETKEY env var is not set to a base64 encoded 32-byte key"
        KEY=$(/app/venv/bin/python /app/fernet-key.py)
        echo "generated fernet key"
    else
        KEY="${FERNETKEY}"
        echo "using FERNETKEY from env variable"
    fi
    echo "${KEY}" > "${KEYFILE}"
fi

export FERNET_KEY
FERNET_KEY=$(cat "${KEYFILE}")

/app/venv/bin/python /app/ldap-backend-app.py \
    --host 127.0.0.1 --port 9000 &

exec /app/venv/bin/python /app/nginx-ldap-auth-daemon.py \
    --host 0.0.0.0 --port 8888
