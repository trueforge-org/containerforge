#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
umask 022

mkdir -p /config/data/backups \
  /tmp/php \
  /tmp/nginx-temp/client /tmp/nginx-temp/proxy /tmp/nginx-temp/fastcgi \
  /tmp/nginx-temp/uwsgi /tmp/nginx-temp/scgi /tmp/nginx-cache

# Seed config files only when missing, so user edits are kept.
[[ -f /config/nginx.conf ]] || cp /defaults/nginx.conf /config/nginx.conf
[[ -f /config/php-fpm.conf ]] || cp /defaults/php-fpm.conf /config/php-fpm.conf
[[ -f /config/data/config.inc.php ]] || cp /app/www/config.inc.php.example /config/data/config.inc.php

# Apply DB settings from the environment on every start. PHP does the rewrite, so special characters in passwords are safe.
# UNVERIFIED: the variable names in config.inc.php.example ($DBType, $DBServer, $DBUser, $DBPassword, $DBName).
cat > /tmp/apply-config.php <<'EOF'
<?php
$file = '/config/data/config.inc.php';
$src = file_get_contents($file);
$values = [
    'DBType'     => getenv('DBTYPE') ?: 'sqlite',
    'DBServer'   => getenv('MYSQL_SERVER') ?: '',
    'DBUser'     => getenv('MYSQL_USERNAME') ?: '',
    'DBPassword' => getenv('MYSQL_PASSWORD') ?: '',
    'DBName'     => getenv('DBNAME') ?: 'data/tasmobackup',
];
foreach ($values as $name => $value) {
    $src = preg_replace_callback(
        '/^\$' . $name . '\s*=.*;/m',
        fn($m) => '$' . $name . ' = ' . var_export($value, true) . ';',
        $src,
        1
    );
}
file_put_contents($file, $src);
EOF
php /tmp/apply-config.php
rm -f /tmp/apply-config.php

# Upgrade the schema on every start. A failure is logged but does not stop the container.
cd /app/www
php /app/www/upgrade.php > /tmp/upgrade.log 2>&1 || {
  cat /tmp/upgrade.log >&2
  echo "upgrade.php failed" >&2
}

# php-fpm listens on a unix socket in /tmp (see defaults/nginx.conf). The timezone comes from TZ.
php-fpm8.5 -F -y /config/php-fpm.conf -d "date.timezone=${TZ:-Etc/UTC}" &

# Replaces the upstream cron entry "8 * * * *" (backupall.php once an hour at minute 8).
backup_loop() {
  while true; do
    local mins secs elapsed delay
    mins=$((10#$(date +%M)))
    secs=$((10#$(date +%S)))
    elapsed=$((mins * 60 + secs))
    delay=$(( (480 - elapsed + 3600) % 3600 ))
    if (( delay == 0 )); then delay=3600; fi
    sleep "$delay"
    curl -fsS "http://127.0.0.1:8080/backupall.php?docker=true" > /dev/null || echo "backupall run failed" >&2
  done
}
backup_loop &

# Forward TERM to the children, and exit as soon as one of them stops.
trap 'kill -TERM $(jobs -p) 2>/dev/null || true' TERM INT
nginx -c /config/nginx.conf -g 'daemon off;' &

wait -n
status=$?
kill -TERM $(jobs -p) 2>/dev/null || true
exit "$status"
