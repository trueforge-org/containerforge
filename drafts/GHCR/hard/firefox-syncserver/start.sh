#!/usr/bin/env bash
set -euo pipefail

# Config is generated in /tmp (ephemeral). State (SQLite DB, generated secret) lives in /config.
INI=/tmp/syncserver.ini

FF_SYNCSERVER_ACCESSLOG="${FF_SYNCSERVER_ACCESSLOG:-false}"
FF_SYNCSERVER_LOGLEVEL="${FF_SYNCSERVER_LOGLEVEL:-info}"
FF_SYNCSERVER_PUBLIC_URL="${FF_SYNCSERVER_PUBLIC_URL:-http://localhost:5000/}"
FF_SYNCSERVER_ALLOW_NEW_USERS="${FF_SYNCSERVER_ALLOW_NEW_USERS:-true}"
FF_SYNCSERVER_FORCE_WSGI_ENVIRON="${FF_SYNCSERVER_FORCE_WSGI_ENVIRON:-false}"
FF_SYNCSERVER_SQLURI="${FF_SYNCSERVER_SQLURI:-sqlite:////config/syncserver.db}"

# Secret: from env, else persisted in /config (generated on first start).
if [ -z "${FF_SYNCSERVER_SECRET:-}" ]; then
    if [ ! -s /config/secret ]; then
        umask 077
        head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n' > /config/secret
    fi
    FF_SYNCSERVER_SECRET="$(< /config/secret)"
fi

GU_ACCESSLOG=""
if [ "${FF_SYNCSERVER_ACCESSLOG}" = "true" ]; then
    GU_ACCESSLOG="accesslog = -"
fi

umask 077
{
    cat <<EOL
[server:main]
use = egg:gunicorn
host = 0.0.0.0
port = 5000
workers = 1
timeout = 30
loglevel = ${FF_SYNCSERVER_LOGLEVEL}
${GU_ACCESSLOG}

[app:main]
use = egg:syncserver

[syncserver]
public_url = ${FF_SYNCSERVER_PUBLIC_URL}
sqluri = ${FF_SYNCSERVER_SQLURI}
secret = ${FF_SYNCSERVER_SECRET}
allow_new_users = ${FF_SYNCSERVER_ALLOW_NEW_USERS}
force_wsgi_environ = ${FF_SYNCSERVER_FORCE_WSGI_ENVIRON}
EOL
    if [ -n "${FF_SYNCSERVER_FORWARDED_ALLOW_IPS:-}" ]; then
        echo "forwarded_allow_ips = ${FF_SYNCSERVER_FORWARDED_ALLOW_IPS}"
    fi
} > "${INI}"

exec /usr/local/bin/gunicorn --paste "${INI}"
