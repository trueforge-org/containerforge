#!/usr/bin/env bash


mkdir -p /config/log/npm

cd /app/www/public/backend/build || exit 1

if [[ -x /app/www/public/backend/node_modules/.bin/typeorm ]]; then
    /app/www/public/backend/node_modules/.bin/typeorm migration:run
fi

shopt -s globstar
cd /app/www/public/backend/build
exec npm run start --logs-dir /config/log/npm
