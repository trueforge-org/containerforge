#!/usr/bin/env bash


# generate fernet key for ldap if it doesn't exist
if [[ ! -f "/run/.fernetkey" ]]; then
    if [[ -z "${FERNETKEY}" ]]; then
        KEY=$(python3 /app/fernet-key.py)
        echo "generated fernet key"
    elif ! python3 -c "from cryptography.fernet import Fernet; Fernet(b'${FERNETKEY}').encrypt(b'my deep dark secret')" 2>/dev/null; then
        echo "FERNETKEY env var is not set to a base64 encoded 32-byte key"
        KEY=$(python3 /app/fernet-key.py)
        echo "generated fernet key"
    else
        KEY="${FERNETKEY}"
        echo "using FERNETKEY from env variable"
    fi
    echo "${KEY}" > /run/.fernetkey
fi

export FERNET_KEY=$(cat /run/.fernetkey)

## TODO deal with multiexec
exec  python3 /app/ldap-backend-app.py \
                --host 0.0.0.0 --port 9000

exec /app/venv/bin/python /app/nginx-ldap-auth-daemon.py \
                --host 0.0.0.0 --port 8888
