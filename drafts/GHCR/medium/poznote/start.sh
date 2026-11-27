#!/usr/bin/env bash

# runtime scratch (nginx, php-fpm, supervisord) lives in /tmp because the rootfs is read-only
mkdir -p \
    /tmp/nginx/client_body /tmp/nginx/proxy /tmp/nginx/fastcgi /tmp/nginx/uwsgi /tmp/nginx/scgi \
    /tmp/php/sessions /tmp/php/uploads \
    /tmp/supervisor

# persistent state (SQLite database, uploads) lives in /config
mkdir -p /config/data

# UNVERIFIED: upstream init.sh (not fetched) also writes version.php and may create the database.
# Port that logic here once read; only create state that is missing, never overwrite /config/data.

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
