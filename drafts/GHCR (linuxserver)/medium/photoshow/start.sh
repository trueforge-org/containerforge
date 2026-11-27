#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR=/config/photoshow
mkdir -p "${CONFIG_DIR}/generated" /tmp/photoshow

# Seed user data only when missing (never overwrite user state).
if [ ! -d "${CONFIG_DIR}/user" ]; then
  cp -a /defaults/photoshow/user "${CONFIG_DIR}/user"
fi

# php-fpm pool goes to /tmp (/app and /etc are read-only at runtime).
# No user/group is set, so php-fpm runs as apps.
cat > /tmp/photoshow/php-fpm.conf <<EOF
[global]
daemonize = no
error_log = /proc/self/fd/2
pid = /tmp/photoshow/php-fpm.pid

[www]
listen = 127.0.0.1:9000
pm = ondemand
pm.max_children = 5
clear_env = no
php_admin_value[upload_max_filesize] = 10M
php_admin_value[post_max_size] = 10M
php_admin_value[memory_limit] = 64M
php_admin_value[max_execution_time] = 15
php_admin_value[date.timezone] = ${TZ:-Etc/UTC}
EOF

# UNVERIFIED: the TZ handling and the php-fpm options must be checked on the first run.
exec supervisord -n -c /etc/photoshow/supervisord.conf
