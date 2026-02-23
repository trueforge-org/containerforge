#!/usr/bin/env bash


mkdir -p /config/storage /config/uploads

if [[ ! -d /config/www ]]; then
    cp -a /app/www /config/www
fi

if [[ ! -f /config/www/.env ]]; then
    cp /app/www/.env /config/www/.env
fi

if [[ ! -f /config/SNIPE_IT_APP_KEY.txt ]]; then
    key="$(php /config/www/artisan key:generate --show)"
    printf '%s' "${key}" > /config/SNIPE_IT_APP_KEY.txt
fi

APP_URL="${APP_URL:-http://localhost}"
APP_KEY="${APP_KEY:-$(cat /config/SNIPE_IT_APP_KEY.txt)}"
sed -i \
    -e "s|^APP_URL=.*|APP_URL=${APP_URL}|" \
    -e "s|^APP_KEY=.*|APP_KEY=${APP_KEY}|" \
    /config/www/.env

ln -snf /config/storage /config/www/storage
ln -snf /config/uploads /config/www/public/uploads

exec php -S 0.0.0.0:80 -t /config/www/public
