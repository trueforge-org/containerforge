#!/usr/bin/env bash
set -euo pipefail

LOCAL_CONFIG=/config/config/local.config.php

# Persistent state lives in /config, scratch space lives in /tmp (read-only rootfs)
mkdir -p /config/config /config/data \
  /tmp/smarty3 /tmp/proxy /tmp/sessions /tmp/nginx-temp /tmp/php-ini

# Seed the shipped config defaults only when the user has none yet
if [[ -z "$(ls -A /config/config 2>/dev/null)" ]]; then
  cp -a /app/config-dist/. /config/config/
fi

# Write local.config.php from the MYSQL_* and FRIENDICA_* variables on first start only.
# The values are read inside PHP from the environment, so the password never appears on the command line.
# UNVERIFIED: array layout of local.config.php in Friendica 2026.05
if [[ -n "${MYSQL_HOST:-}" && ! -s "${LOCAL_CONFIG}" ]]; then
  php -r '
    $c = [
      "database" => [
        "hostname" => (string) getenv("MYSQL_HOST"),
        "port" => ((int) getenv("MYSQL_PORT")) ?: 3306,
        "username" => (string) getenv("MYSQL_USER"),
        "password" => (string) getenv("MYSQL_PASSWORD"),
        "database" => (string) getenv("MYSQL_DATABASE"),
        "charset" => "utf8mb4",
      ],
      "config" => ["admin_email" => (string) getenv("FRIENDICA_ADMIN_MAIL")],
      "system" => ["url" => (string) getenv("FRIENDICA_URL")],
    ];
    file_put_contents("/config/config/local.config.php", "<?php\nreturn " . var_export($c, true) . ";\n");
  '
  chmod 600 "${LOCAL_CONFIG}"
fi

# Wait up to 30 seconds for the database, then continue either way
if [[ -n "${MYSQL_HOST:-}" ]]; then
  echo "Waiting for database ${MYSQL_HOST}:${MYSQL_PORT:-3306}"
  end=$((SECONDS + 30))
  until (: < /dev/tcp/"${MYSQL_HOST}"/"${MYSQL_PORT:-3306}") 2>/dev/null || [[ ${SECONDS} -ge ${end} ]]; do
    sleep 1
  done
fi

# PHP limits: php-fpm reads extra ini files from PHP_INI_SCAN_DIR (UNVERIFIED that the Ubuntu fpm path is this)
cat > /tmp/php-ini/99-friendica.ini <<EOF
memory_limit = ${PHP_MEMORY_LIMIT:-512M}
upload_max_filesize = ${PHP_UPLOAD_LIMIT:-512M}
post_max_size = ${PHP_UPLOAD_LIMIT:-512M}
EOF
export PHP_INI_SCAN_DIR="/etc/php/8.5/fpm/conf.d:/tmp/php-ini"

if [[ -s "${LOCAL_CONFIG}" ]]; then
  # Create or migrate the database structure. A failure is logged and the container keeps running.
  # UNVERIFIED: console command name in 2026.05
  php /app/www/bin/console.php dbstructure update || echo "WARNING: database structure update failed, see the log"
fi

echo "Starting php-fpm"
php-fpm8.5 -F -y /defaults/php-fpm.conf &

if [[ -s "${LOCAL_CONFIG}" ]]; then
  echo "Starting background worker loop"
  ( while true; do php /app/www/bin/worker.php || true; sleep 60; done ) &
fi

# nginx replaces this shell. php-fpm and the worker are children and rely on tini (the base entrypoint) to stop.
exec nginx -c /defaults/nginx.conf -g 'daemon off;'
