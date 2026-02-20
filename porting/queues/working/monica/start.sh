#!/usr/bin/env bash

set -euo pipefail

MONICADIR=/app/www
CONFIGDIR=/config/www

mkdir -p "${CONFIGDIR}/storage" "${CONFIGDIR}/cache"

if [[ ! -f "${CONFIGDIR}/.env" ]]; then
    cp /defaults/.env.sample "${CONFIGDIR}/.env"
fi

cd "${MONICADIR}"

if ! grep -Eq "^APP_KEY=base64:" "${CONFIGDIR}/.env"; then
    php artisan key:generate --no-interaction || true
fi

exec /usr/bin/php artisan serve --host=0.0.0.0 --port=80
