#!/usr/bin/env bash


mkdir -p /config/www

if [[ ! -d /config/www/public ]]; then
    cp -a /app/www/public /config/www/public
fi

mkdir -p /config/www/public/{storage,logs,resources/database,static}

exec php -S 0.0.0.0:80 -t /config/www/public
