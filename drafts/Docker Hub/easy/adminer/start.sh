#!/usr/bin/env bash
set -euo pipefail

# PHP sessions and uploads go to /tmp; nothing is written to /app.
mkdir -p /tmp/php-sessions

cd /app/www
exec php -S 0.0.0.0:8080 -t /app/www \
  -d "memory_limit=${MEMORY_LIMIT:-1G}" \
  -d "upload_max_filesize=${UPLOAD_LIMIT:-128M}" \
  -d "post_max_size=${UPLOAD_LIMIT:-128M}" \
  -d "max_execution_time=${MAX_EXECUTION_TIME:-600}" \
  -d "max_input_vars=5000" \
  -d "session.save_path=/tmp/php-sessions" \
  -d "sys_temp_dir=/tmp" \
  -d "upload_tmp_dir=/tmp"
