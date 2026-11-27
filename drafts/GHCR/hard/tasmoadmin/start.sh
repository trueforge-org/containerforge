#!/usr/bin/env bash
# UNVERIFIED draft (plan section 7): the nginx and php-fpm configs are rendered to /tmp at each start.
set -euo pipefail

mkdir -p /config/data /tmp/nginx/client_body /tmp/nginx/proxy /tmp/nginx/fastcgi

# php-fpm: the full config lives in /tmp, so the packaged pool under /etc is not used.
cat > /tmp/php-fpm.conf <<'CONF'
[global]
pid = /tmp/php-fpm.pid
error_log = /proc/self/fd/2
daemonize = yes

[www]
listen = /tmp/php-fpm.sock
listen.mode = 0660
pm = static
pm.max_children = 4
clear_env = no
CONF

cat > /tmp/nginx/nginx.conf <<'CONF'
worker_processes auto;
pid /tmp/nginx/nginx.pid;
error_log /dev/stderr warn;

events {
    worker_connections 512;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    access_log /dev/stdout;
    sendfile on;
    client_body_temp_path /tmp/nginx/client_body;
    proxy_temp_path /tmp/nginx/proxy;
    fastcgi_temp_path /tmp/nginx/fastcgi;

    server {
        listen 8080;
        server_name _;
        root /var/www/tasmoadmin;
        index index.php;

        # Device lists and credentials under data/ must not be served directly (UNVERIFIED path, plan section 1).
        location ~ ^/data/ {
            deny all;
        }

        location / {
            try_files $uri $uri/ /index.php?$args;
        }

        location ~ \.php$ {
            include /etc/nginx/fastcgi_params;
            fastcgi_pass unix:/tmp/php-fpm.sock;
        }
    }
}
CONF

# php-fpm daemonizes itself from the config above. nginx then becomes PID 1 through exec.
php-fpm8.5 -y /tmp/php-fpm.conf

exec nginx -c /tmp/nginx/nginx.conf -g "daemon off;"
