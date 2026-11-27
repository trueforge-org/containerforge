#!/usr/bin/env bash
# Initial draft. UNVERIFIED: the PHP build's ini scan path, and which CHEVERETO_* names the app reads (plan sections 7 and 10).

# Data directories live in /config and are created only when missing. Never overwrite existing files.
mkdir -p /config/content /config/images /tmp/apache/log /tmp/php

# PHP limits from the environment, written under /tmp (never /app).
cat > /tmp/php/chevereto.ini <<EOF
upload_max_filesize = ${CHEVERETO_UPLOAD_MAX_FILESIZE:-64M}
post_max_size = ${CHEVERETO_POST_MAX_SIZE:-64M}
max_execution_time = ${CHEVERETO_MAX_EXECUTION_TIME:-30}
memory_limit = ${CHEVERETO_MEMORY_LIMIT:-512M}
log_errors = On
error_log = /dev/stderr
EOF
export PHP_INI_SCAN_DIR=/tmp/php

# Defaults for the settings.yaml env names. Passwords are applied from the environment on every start.
export CHEVERETO_DB_HOST="${CHEVERETO_DB_HOST:-mariadb}"
export CHEVERETO_DB_PORT="${CHEVERETO_DB_PORT:-3306}"
export CHEVERETO_DB_NAME="${CHEVERETO_DB_NAME:-chevereto}"
export CHEVERETO_HOSTNAME="${CHEVERETO_HOSTNAME:-localhost}"
export CHEVERETO_HTTPS="${CHEVERETO_HTTPS:-1}"
export CHEVERETO_SESSION_SAVE_PATH="${CHEVERETO_SESSION_SAVE_PATH:-/tmp}"

# Apache paths and user come from the packaged envvars file (patched in the Dockerfile to use /tmp).
. /etc/apache2/envvars

cd /app/chevereto || exit 1
exec apache2 -D FOREGROUND
