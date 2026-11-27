#!/usr/bin/env bash
set -euo pipefail

# Drupal state lives in /config. PHP and nginx scratch lives in /tmp (read-only rootfs).
mkdir -p /config/sites /config/private /tmp/php/sessions /tmp/php/ini /tmp/nginx

# Seed Drupal's default sites directory without overwriting anything that already exists
cp -rn /app/farmos-sites-default/. /config/sites/

# Drupal's installer must write settings.php and files/ on first run
chmod u+w /config/sites /config/sites/default 2>/dev/null || true
mkdir -p /config/sites/default/files

# Render the PHP ini from the template in /etc/farmos (memory limit from the environment)
PHP_MEMORY_LIMIT="${PHP_MEMORY_LIMIT:-256M}"
sed "s|@PHP_MEMORY_LIMIT@|${PHP_MEMORY_LIMIT}|" /etc/farmos/php/farmOS.ini > /tmp/php/ini/farmOS.ini

# Stop both children when the container is asked to stop
trap 'kill $(jobs -p) 2>/dev/null; exit 0' TERM INT

PHP_INI_SCAN_DIR=":/tmp/php/ini" php-fpm8.5 -y /etc/farmos/php-fpm.conf -F &
nginx -c /etc/farmos/nginx.conf -g 'daemon off;' &

# Exit as soon as either service stops, so the platform can restart the container
wait -n
exit $?
