#!/usr/bin/env bash

# /app/www/assets is a symlink to /config/assets; seed the example config and assets only when missing
mkdir -p /config/assets

if [[ ! -f /config/assets/config.yml ]]; then
    cp -n /app/www/default-assets/config.yml.dist /config/assets/config.yml
fi

cp -Rn /app/www/default-assets/. /config/assets/

# hand over to the base CMD (nginx) so signals reach it as PID 1
exec "$@"
