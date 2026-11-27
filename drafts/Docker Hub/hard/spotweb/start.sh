#!/usr/bin/env bash
set -euo pipefail

: "${TZ:=Etc/UTC}"
: "${DB_ENGINE:=pdo_pgsql}"
: "${DB_HOST:=}"
: "${DB_PORT:=5432}"
: "${DB_NAME:=spotweb}"
: "${DB_USER:=spotweb}"
: "${DB_PASS:=}"
: "${SPOTWEB_RETRIEVE_INTERVAL:=3600}"

if [[ ! "${SPOTWEB_RETRIEVE_INTERVAL}" =~ ^[0-9]+$ ]]; then
  echo "SPOTWEB_RETRIEVE_INTERVAL must be a number of seconds" >&2
  exit 1
fi

mkdir -p /config /tmp/spotweb-cache /tmp/nginx /tmp/php

# Seed ownsettings.php only when missing.
if [[ ! -s /config/ownsettings.php ]]; then
  cp /defaults/ownsettings.php /config/ownsettings.php
fi

# Generate dbsettings.inc.php from the environment on every start, so a changed password also applies.
# Values pass through the environment and var_export(), so quotes, $ and backslashes are safe.
# The password never appears in argv. UNVERIFIED: key names match Spotweb's template (check the tarball).
if [[ -n "${DB_HOST}" ]]; then
  php -r '
    $s = [
      "engine" => getenv("DB_ENGINE"),
      "host" => getenv("DB_HOST"),
      "port" => getenv("DB_PORT"),
      "dbname" => getenv("DB_NAME"),
      "user" => getenv("DB_USER"),
      "pass" => getenv("DB_PASS"),
    ];
    $out = "<?php\n";
    foreach ($s as $k => $v) {
      $out .= "\$dbsettings[\x27" . $k . "\x27] = " . var_export($v, true) . ";\n";
    }
    file_put_contents("/config/dbsettings.inc.php", $out);
    chmod("/config/dbsettings.inc.php", 0600);
  '
else
  echo "DB_HOST is not set, skipping dbsettings.inc.php. Use the install wizard at /install.php." >&2
fi

# php-fpm and nginx start before any database wait, so the web server answers while the DB comes up.
php-fpm8.5 -y /defaults/php-fpm.conf -F -d "date.timezone=${TZ}" &

# Retrieval loop. It retries until the database is reachable. Output goes to the container log.
if [[ -n "${DB_HOST}" ]]; then
  (
    while true; do
      php /app/www/retrieve.php || echo "retrieve.php failed, retrying in ${SPOTWEB_RETRIEVE_INTERVAL}s" >&2
      sleep "${SPOTWEB_RETRIEVE_INTERVAL}"
    done
  ) &
fi

# nginx stays in the foreground as the main process. Helpers stop when the container stops.
exec nginx -c /defaults/nginx.conf -g 'daemon off;'
