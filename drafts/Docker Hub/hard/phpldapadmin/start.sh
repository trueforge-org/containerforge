#!/usr/bin/env bash
set -euo pipefail

PLA_DIR=/app/www
KEY_FILE=/config/pla/app.key

echo "[phpldapadmin] preparing runtime directories"
mkdir -p /config/pla /tmp/pla/sessions /tmp/pla/cache /tmp/pla/views /tmp/pla/logs /tmp/pla/bootstrap
mkdir -p /tmp/nginx/client /tmp/nginx/proxy /tmp/nginx/fastcgi /tmp/nginx/uwsgi /tmp/nginx/scgi

# APP_KEY: use the value from the environment, otherwise keep one generated on first start in /config
if [ -z "${APP_KEY:-}" ]; then
  if [ ! -s "${KEY_FILE}" ]; then
    echo "[phpldapadmin] generating APP_KEY into ${KEY_FILE}"
    (umask 077 && php "${PLA_DIR}/artisan" key:generate --show > "${KEY_FILE}")
  fi
  APP_KEY="$(cat "${KEY_FILE}")"
  export APP_KEY
fi

if [ -z "${LDAP_HOST:-}" ]; then
  echo "[phpldapadmin] WARNING: LDAP_HOST is not set; no LDAP directory can be reached" >&2
fi

export APP_TIMEZONE="${APP_TIMEZONE:-UTC}"
export LDAP_CACHE="${LDAP_CACHE:-false}"
export CACHE_DRIVER="${CACHE_DRIVER:-file}"

echo "[phpldapadmin] starting php-fpm"
# php-fpm keeps the environment (clear_env = no in etc/phpldapadmin/php-fpm.conf)
php-fpm8.5 -y /etc/phpldapadmin/php-fpm.conf -D

echo "[phpldapadmin] starting nginx on 8080"
exec nginx -c /etc/phpldapadmin/nginx.conf -g 'daemon off;'
