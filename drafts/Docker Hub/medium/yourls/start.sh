#!/usr/bin/env bash

# Persistent state lives in /config. Seed only what is missing; never overwrite.
mkdir -p \
  /config/yourls/user/plugins \
  /config/yourls/user/pages \
  /config/yourls/user/languages \
  /tmp/nginx

cp -rn /app/yourls-user-default/. /config/yourls/user/
cp -n /defaults/user/config.php /config/yourls/user/config.php

# php-fpm daemonizes (see defaults/php-fpm.conf); nginx stays in the foreground as PID 1.
/usr/sbin/php-fpm8.5 -y /defaults/php-fpm.conf
exec nginx -g 'daemon off;' -c /defaults/nginx.conf
