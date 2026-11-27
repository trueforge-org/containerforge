#!/usr/bin/env bash
set -euo pipefail

export TZ="${TZ:-Etc/UTC}"

# ephemeral runtime dirs
mkdir -p /tmp/nginx/body /tmp/nginx/proxy /tmp/nginx/fastcgi /tmp/nginx/uwsgi /tmp/nginx/scgi /tmp/php

# persistent config and sqlite data, seeded only when missing or empty
mkdir -p /config/config /config/Specific
if [[ -z "$(ls -A /config/config 2>/dev/null)" ]]; then
  cp -rn /defaults/baikal-skel/config/. /config/config/
fi
if [[ -z "$(ls -A /config/Specific 2>/dev/null)" ]]; then
  cp -rn /defaults/baikal-skel/Specific/. /config/Specific/
fi

# render the rootless templates into /tmp
cp /defaults/nginx.conf /tmp/nginx/nginx.conf
cp /defaults/php-fpm.conf /tmp/php-fpm.conf

php-fpm8.5 -y /tmp/php-fpm.conf -F &

exec nginx -c /tmp/nginx/nginx.conf -g 'daemon off;'
