#!/usr/bin/env bash

set -euo pipefail

APP_DIR=/config/projectsend/www

mkdir -p /config/projectsend /config/php /config/projectsend/data "${APP_DIR}"

if [[ ! -f /config/php/projectsend.ini ]]; then
    cp /defaults/projectsend.ini /config/php/projectsend.ini
fi

if [[ ! -f "${APP_DIR}/public/index.php" ]]; then
    cp -a /app/www/public/. "${APP_DIR}/"
fi

if [[ ! -e "${APP_DIR}/upload" ]]; then
    ln -s /config/projectsend/data "${APP_DIR}/upload"
fi

exec php -S 0.0.0.0:80 -t "${APP_DIR}/public"
