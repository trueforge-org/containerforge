#!/usr/bin/env bash
set -euo pipefail

# Persistent state lives in /config. Ephemeral state lives in /tmp (read-only rootfs). Nothing writes to /app.
RUN=/tmp/wallos
mkdir -p /config/db /config/uploads/logos \
  "$RUN/nginx/client" "$RUN/nginx/proxy" "$RUN/nginx/fastcgi" "$RUN/sessions" "$RUN/uploads"

# One-time database setup, run before the web servers start.
# UNVERIFIED: script paths (upstream startup.sh was read only partly). Existing data is not overwritten.
php8.5 /app/wallos/db/createdatabase.php
php8.5 /app/wallos/db/migrate.php

# UNVERIFIED: cron jobs (endpoints/cronjobs) are not run. cron needs root, so v1 drops it (plan section 7).
cat > "$RUN/php-fpm.conf" <<'EOF'
[global]
pid = /tmp/wallos/php-fpm.pid
error_log = /proc/self/fd/2
daemonize = no

[www]
listen = /tmp/wallos/php-fpm.sock
listen.mode = 0660
pm = dynamic
pm.max_children = 15
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
pm.max_requests = 500
clear_env = no
catch_workers_output = yes
php_admin_value[upload_max_filesize] = 256M
php_admin_value[post_max_size] = 256M
php_admin_value[session.save_path] = /tmp/wallos/sessions
php_admin_value[upload_tmp_dir] = /tmp/wallos/uploads
EOF

cat > "$RUN/nginx.conf" <<'EOF'
worker_processes 1;
error_log stderr;
pid /tmp/wallos/nginx.pid;

events {
  worker_connections 1024;
}

http {
  include /etc/nginx/mime.types;
  access_log /dev/stdout;
  client_body_temp_path /tmp/wallos/nginx/client;
  proxy_temp_path /tmp/wallos/nginx/proxy;
  fastcgi_temp_path /tmp/wallos/nginx/fastcgi;
  client_max_body_size 256M;

  server {
    listen 8080;
    root /app/wallos;
    index index.php index.html;

    location / {
      try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
      include /etc/nginx/fastcgi_params;
      fastcgi_pass unix:/tmp/wallos/php-fpm.sock;
      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
  }
}
EOF

/usr/sbin/php-fpm8.5 -y "$RUN/php-fpm.conf" -F &
nginx -c "$RUN/nginx.conf" -g 'daemon off;' &

trap 'kill -TERM $(jobs -p) 2>/dev/null || true' TERM INT
wait -n || true
kill -TERM $(jobs -p) 2>/dev/null || true
wait || true
