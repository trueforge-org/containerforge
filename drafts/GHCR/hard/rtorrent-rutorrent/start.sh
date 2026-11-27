#!/usr/bin/env bash
set -euo pipefail

# Persistent state lives in /config. Ephemeral state lives in /tmp (read-only rootfs). Nothing writes to /app.
CONF=/config/rtorrent
WEB=/config/rutorrent
RUN=/tmp/rtorrent-rutorrent

mkdir -p "$CONF/session" "$WEB/share" "$WEB/users" /downloads \
  "$RUN/nginx/client" "$RUN/nginx/proxy" "$RUN/nginx/fastcgi" "$RUN/sessions"

# Seed the rTorrent config only when missing. Never overwrite user state.
# rTorrent reads $HOME/.rtorrent.rc, and HOME is set to $CONF below.
if [ ! -f "$CONF/.rtorrent.rc" ]; then
  cat > "$CONF/.rtorrent.rc" <<'EOF'
directory.default.set = /downloads
session.path.set = /config/rtorrent/session
network.port_range.set = 50000-50000
network.scgi.open_port = 127.0.0.1:5000
EOF
fi

cat > "$RUN/php-fpm.conf" <<'EOF'
[global]
pid = /tmp/rtorrent-rutorrent/php-fpm.pid
error_log = /proc/self/fd/2
daemonize = no

[www]
listen = /tmp/rtorrent-rutorrent/php-fpm.sock
listen.mode = 0660
pm = ondemand
pm.max_children = 5
clear_env = no
catch_workers_output = yes
php_admin_value[session.save_path] = /tmp/rtorrent-rutorrent/sessions
EOF

cat > "$RUN/nginx.conf" <<'EOF'
worker_processes 1;
error_log stderr;
pid /tmp/rtorrent-rutorrent/nginx.pid;

events {
  worker_connections 256;
}

http {
  include /etc/nginx/mime.types;
  access_log /dev/stdout;
  client_body_temp_path /tmp/rtorrent-rutorrent/nginx/client;
  proxy_temp_path /tmp/rtorrent-rutorrent/nginx/proxy;
  fastcgi_temp_path /tmp/rtorrent-rutorrent/nginx/fastcgi;

  server {
    listen 8080;
    root /app;
    index index.php index.html;

    location = / {
      return 301 /rutorrent/;
    }

    location ~ \.php$ {
      include /etc/nginx/fastcgi_params;
      fastcgi_pass unix:/tmp/rtorrent-rutorrent/php-fpm.sock;
      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
  }
}
EOF

# UNVERIFIED: binary name (php-fpm8.x on Ubuntu). Picks the first match.
PHP_FPM="$(ls /usr/sbin/php-fpm* | head -n 1)"

# Supervisor: UNVERIFIED design (plan section 7). Start the three services, then exit when any one stops.
HOME="$CONF" rtorrent -n &
"$PHP_FPM" -y "$RUN/php-fpm.conf" -F &
nginx -c "$RUN/nginx.conf" -g 'daemon off;' &

trap 'kill -TERM $(jobs -p) 2>/dev/null || true' TERM INT
wait -n || true
kill -TERM $(jobs -p) 2>/dev/null || true
wait || true
