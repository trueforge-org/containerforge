#!/usr/bin/env bash


# make our folders
mkdir -p \
    /config/www/freshrss/data \
    /config/www/freshrss/extensions

# seed persistent state on first run only
if [[ -z "$(ls -A /config/www/freshrss/data)" ]]; then
    cp -a /app/www/data.bak/. /config/www/freshrss/data/
fi

if [[ -z "$(ls -A /config/www/freshrss/extensions)" ]]; then
    cp -a /app/www/extensions.bak/. /config/www/freshrss/extensions/
fi

# backwards compatibility
if [[ -f /config/nginx/site-confs/default.conf ]] && grep -q 'root /config/www/freshrss/p;' /config/nginx/site-confs/default.conf; then
    cp /defaults/nginx/site-confs/default.conf.sample /config/nginx/site-confs/default.conf
fi

# disable updates
if [[ -f /config/www/freshrss/data/config.php ]]; then
    sed -i "s|'disable_update' => false,|'disable_update' => true,|g" /config/www/freshrss/data/config.php
fi

exec php8.5 -S 0.0.0.0:80 -t /app/www/p
