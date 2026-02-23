#!/usr/bin/env bash

set -euo pipefail

APP_DIR=/config/projectsend/www

mkdir -p /config/projectsend /config/php /data/projectsend "${APP_DIR}"

if [[ ! -f /config/php/projectsend.ini ]]; then
    cp /defaults/projectsend.ini /config/php/projectsend.ini
fi

if [[ ! -f "${APP_DIR}/index.php" ]]; then
    cp -a /app/www/public/. "${APP_DIR}/"
fi

if [[ ! -e "${APP_DIR}/upload" ]]; then
    ln -s /data/projectsend "${APP_DIR}/upload"
fi

exec php -S 0.0.0.0:80 -t "${APP_DIR}"
