#!/usr/bin/env bash
set -e

# Persistent state lives in /config; rendered configs and scratch live in /tmp (read-only rootfs)
mkdir -p /config/data /tmp/nginx /tmp/nginx-conf.d /tmp/redis /tmp/php

# UNVERIFIED: which config path BarcodeBuddy reads. Seed only when missing, never overwrite.
[ -s /config/config.php ] || cp /app/bbuddy/config-dist.php /config/config.php

cp /defaults/nginx.conf /tmp/nginx-conf.d/bbuddy.conf
cp /defaults/php-fpm.conf /tmp/php-fpm.conf
cp /defaults/redis.conf /tmp/redis/redis.conf

# Stop the children when the container is asked to stop
trap 'kill $(jobs -p) 2>/dev/null; exit 0' TERM INT

redis-server /tmp/redis/redis.conf &
php-fpm8.5 -y /tmp/php-fpm.conf -F &

# Websocket server: restart up to 10 times like upstream, then fail the container
(
  n=0
  until [ "${n}" -ge 10 ]; do
    php8.5 /app/bbuddy/wsserver.php || true
    n=$((n + 1))
    sleep 2
  done
  echo "wsserver failed 10 times, giving up" >&2
  exit 1
) &

nginx -g 'daemon off;' &

# Exit (and let the platform restart) as soon as any service stops
wait -n
exit $?
