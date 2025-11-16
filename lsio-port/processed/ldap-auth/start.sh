# ===== From ./processed/ldap-auth/root/etc/s6-overlay//s6-rc.d/init-ldap-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

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

# ===== From ./processed/ldap-auth/root/etc/s6-overlay//s6-rc.d/svc-ldap-app/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

export FERNET_KEY=$(cat /run/.fernetkey)

if [[ -z ${LSIO_NON_ROOT_USER} ]]; then
    exec \
        s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 9000" \
            s6-setuidgid abc python3 /app/ldap-backend-app.py \
                --host 0.0.0.0 --port 9000
else
    exec \
        s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 9000" \
            python3 /app/ldap-backend-app.py \
                --host 0.0.0.0 --port 9000
fi

# ===== From ./processed/ldap-auth/root/etc/s6-overlay//s6-rc.d/svc-ldap-daemon/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

export FERNET_KEY=$(cat /run/.fernetkey)

if [[ -z ${LSIO_NON_ROOT_USER} ]]; then
    exec \
        s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 8888" \
            s6-setuidgid abc python3 /app/nginx-ldap-auth-daemon.py \
                --host 0.0.0.0 --port 8888
else
    exec \
        s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 8888" \
            python3 /app/nginx-ldap-auth-daemon.py \
                --host 0.0.0.0 --port 8888
fi

