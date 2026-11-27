#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR=/config
# The turnserver config is rewritten from env on every start. It lives in /tmp, so no state is kept there.
CONF=/tmp/turnserver.conf
CERT="${CONFIG_DIR}/cert.pem"
KEY="${CONFIG_DIR}/privkey.pem"
SECRET_FILE="${CONFIG_DIR}/static-auth-secret"

TURN_PORT="${TURN_PORT:-3478}"
TURN_TLS_PORT="${TURN_TLS_PORT:-5349}"
TURN_LISTEN_IP="${TURN_LISTEN_IP:-0.0.0.0}"
TURN_REALM="${TURN_REALM:-example.com}"
TURN_EXTERNAL_IP="${TURN_EXTERNAL_IP:-}"

mkdir -p "${CONFIG_DIR}"

# Self-signed certificate, created only when missing. User-supplied cert.pem and privkey.pem in /config are kept.
if [[ ! -s "${CERT}" || ! -s "${KEY}" ]]; then
    openssl req -x509 -newkey rsa:2048 -nodes -days 3650 \
        -subj "/CN=turn-server" \
        -keyout "${KEY}" -out "${CERT}" >/dev/null 2>&1
fi

# Static auth secret: from env when set, otherwise generated once and kept in /config.
if [[ -n "${TURN_STATIC_AUTH_SECRET:-}" ]]; then
    SECRET="${TURN_STATIC_AUTH_SECRET}"
else
    if [[ ! -s "${SECRET_FILE}" ]]; then
        umask 077
        openssl rand -hex 32 > "${SECRET_FILE}"
    fi
    SECRET="$(cat "${SECRET_FILE}")"
fi

umask 077
{
    echo "listening-ip=${TURN_LISTEN_IP}"
    echo "listening-port=${TURN_PORT}"
    echo "tls-listening-port=${TURN_TLS_PORT}"
    if [[ -n "${TURN_EXTERNAL_IP}" ]]; then
        echo "external-ip=${TURN_EXTERNAL_IP}"
    fi
    echo "realm=${TURN_REALM}"
    echo "fingerprint"
    echo "use-auth-secret"
    echo "static-auth-secret=${SECRET}"
    echo "cert=${CERT}"
    echo "pkey=${KEY}"
    echo "userdb=/tmp/turndb"
    echo "log-file=stdout"
    echo "no-cli"
} > "${CONF}"

# UNVERIFIED: coturn config key names and turnserver flags for the packaged 4.6.1 build. Check `turnserver --help` and the log output in the first run.
# DH file is not set (coturn default). Relay UDP port range is not set (UNVERIFIED).
exec turnserver -c "${CONF}"
