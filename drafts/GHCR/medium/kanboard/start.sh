#!/usr/bin/env bash
set -euo pipefail

# Runtime files (nginx and php-fpm pid, temp, sockets, sessions) live in /tmp. The app data lives in /config.
mkdir -p /config/data /config/plugins /tmp/nginx /tmp/php/sessions

# Seed config.php only when it is missing or empty. Never overwrite user state.
if [[ ! -s /config/config.php ]]; then
    cp /defaults/config.php /config/config.php
fi

# php-fpm in the foreground, backgrounded so nginx can be PID 1 via exec.
# UNVERIFIED: a supervisor may be needed if php-fpm dies while nginx keeps running.
php-fpm8.5 -F -y /etc/php/8.5/fpm/kanboard-fpm.conf &

exec nginx -c /etc/nginx/nginx.conf -g 'daemon off;'
