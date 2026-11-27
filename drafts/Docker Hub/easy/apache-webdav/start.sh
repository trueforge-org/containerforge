#!/usr/bin/env bash
set -euo pipefail

umask "${PUMASK:-0022}"

TEMPLATE=/etc/apache-webdav/httpd.conf.template
RUNDIR=/tmp/apache2
CONF="${RUNDIR}/httpd.conf"

LOCATION="${LOCATION:-/}"
REALM="${REALM:-WebDAV}"
AUTH_TYPE="${AUTH_TYPE:-Basic}"

# Only the first server name is used as ServerName. Input is checked so it cannot break the config.
SERVER_NAME="${SERVER_NAMES:-localhost}"
SERVER_NAME="${SERVER_NAME//,/ }"
SERVER_NAME="${SERVER_NAME%% *}"
re_name='^[A-Za-z0-9.-]+$'
re_location='^/[A-Za-z0-9_./-]*$'
re_realm='^[A-Za-z0-9._ -]+$'
[[ "${SERVER_NAME}" =~ $re_name ]] || { echo "[apache-webdav] invalid SERVER_NAMES" >&2; exit 1; }
[[ "${LOCATION}" =~ $re_location ]] || { echo "[apache-webdav] invalid LOCATION" >&2; exit 1; }
[[ "${REALM}" =~ $re_realm ]] || { echo "[apache-webdav] invalid REALM" >&2; exit 1; }
case "${AUTH_TYPE}" in
    Basic|Digest) ;;
    *) echo "[apache-webdav] AUTH_TYPE must be Basic or Digest" >&2; exit 1 ;;
esac

mkdir -p /config/dav /data "${RUNDIR}/empty"

# Users: a user file in /config wins, else one is generated from env on every start
if [[ -f /config/user.passwd ]]; then
    AUTH_FILE=/config/user.passwd
    echo "[apache-webdav] Using /config/user.passwd"
else
    AUTH_FILE="${RUNDIR}/user.passwd"
    : > "${AUTH_FILE}"
    if [[ -n "${USERNAME:-}" && -n "${PASSWORD:-}" ]]; then
        if [[ "${USERNAME}" == *:* ]]; then
            echo "[apache-webdav] USERNAME must not contain ':'" >&2
            exit 1
        fi
        if [[ "${AUTH_TYPE}" == "Digest" ]]; then
            hash="$(printf '%s' "${USERNAME}:${REALM}:${PASSWORD}" | md5sum | cut -d' ' -f1)"
            printf '%s:%s:%s\n' "${USERNAME}" "${REALM}" "${hash}" > "${AUTH_FILE}"
        else
            # password on stdin, so it is not in the process list
            printf '%s' "${PASSWORD}" | htpasswd -B -i -c "${AUTH_FILE}" "${USERNAME}" >/dev/null
        fi
    else
        echo "[apache-webdav] No USERNAME/PASSWORD and no /config/user.passwd, every request gets 401"
    fi
fi

# ANONYMOUS_METHODS: ALL disables auth, a list allows those methods without a login
REQUIRE_LINES="Require valid-user"
if [[ -n "${ANONYMOUS_METHODS:-}" ]]; then
    re='^[A-Z, ]+$'
    if [[ "${ANONYMOUS_METHODS}" == "ALL" ]]; then
        REQUIRE_LINES="Require all granted"
    elif [[ "${ANONYMOUS_METHODS}" =~ $re ]]; then
        REQUIRE_LINES="Require valid-user"$'\n'"Require method ${ANONYMOUS_METHODS//,/ }"
    else
        echo "[apache-webdav] invalid ANONYMOUS_METHODS" >&2
        exit 1
    fi
fi

export SERVER_NAME LOCATION REALM AUTH_TYPE AUTH_FILE REQUIRE_LINES
# envsubst needs the literal variable list, so single quotes are intended here
# shellcheck disable=SC2016
envsubst '${SERVER_NAME} ${LOCATION} ${REALM} ${AUTH_TYPE} ${AUTH_FILE} ${REQUIRE_LINES}' \
    < "${TEMPLATE}" > "${CONF}"

exec /usr/sbin/apache2 -f "${CONF}" -DFOREGROUND
