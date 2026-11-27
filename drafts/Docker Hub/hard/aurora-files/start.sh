#!/usr/bin/env bash
set -euo pipefail

# Persistent data lives in /config/data (symlinked from /app/www/data at build time).
# Scratch, nginx and php-fpm runtime files live in /tmp (rootfs is read-only).
mkdir -p /config/data /tmp/nginx /tmp/php/sessions /tmp/php/uploads

# First run only: seed DB settings from the environment, never overwrite an existing config.
if [[ ! -f /config/data/settings/config.json && -n "${DB_HOST:-}" ]]; then
  php /defaults/afterlogic-init.php
fi

# nginx: the template is a full standalone config with every temp and pid path under /tmp.
cp /etc/nginx/aurora-files.conf.template /tmp/nginx/nginx.conf

# php-fpm: own pool config under /tmp, clear_env = no so the environment reaches the app.
cat > /tmp/php/php-fpm.conf <<'EOF'
[global]
pid = /tmp/php/php-fpm.pid
error_log = /proc/self/fd/2
daemonize = no

[www]
listen = /tmp/php/fpm.sock
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
clear_env = no
catch_workers_output = yes
EOF

# No supervisor: two long-running processes. Stop both when either one exits or on TERM/INT.
php-fpm8.5 -y /tmp/php/php-fpm.conf -F &
FPM_PID=$!
nginx -c /tmp/nginx/nginx.conf -g 'daemon off;' &
NGINX_PID=$!
trap 'kill -TERM "${FPM_PID}" "${NGINX_PID}" 2>/dev/null || true' TERM INT

wait -n || true
kill -TERM "${FPM_PID}" "${NGINX_PID}" 2>/dev/null || true
wait || true
