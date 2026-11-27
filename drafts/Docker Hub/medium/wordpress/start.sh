#!/usr/bin/env bash
set -euo pipefail

# Defaults match settings.yaml.
DB_HOST="${WORDPRESS_DB_HOST:-mariadb}"
DB_PORT="${WORDPRESS_DB_PORT:-3306}"
DB_NAME="${WORDPRESS_DB_NAME:-MYMARIADBDB}"
DB_USER="${WORDPRESS_DB_USER:-MYMARIADBUSER}"
DB_PASSWORD="${WORDPRESS_DB_PASSWORD:-MYMARIADBPASSWORD}"

# Apache's runtime and log dirs are under /tmp (set in the Dockerfile).
mkdir -p /config/wp-content /tmp/apache2/log

# Seed wp-content from the core defaults only when it is missing or empty.
if [[ -z "$(ls -A /config/wp-content 2>/dev/null)" ]]; then
    cp -a /app/wordpress-default-content/. /config/wp-content/
fi

# Salts are generated once and kept in /config, so sessions survive restarts.
if [[ ! -s /config/wp-salts.php ]]; then
    {
        echo "<?php"
        for key in AUTH_KEY SECURE_AUTH_KEY LOGGED_IN_KEY NONCE_KEY AUTH_SALT SECURE_AUTH_SALT LOGGED_IN_SALT NONCE_SALT; do
            echo "define( '${key}', '$(openssl rand -hex 32)' );"
        done
    } > /config/wp-salts.php.tmp
    mv /config/wp-salts.php.tmp /config/wp-salts.php
fi

# php_escape escapes backslashes and single quotes for a PHP single-quoted string.
php_escape() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\'/\\\'}"
    printf '%s' "$s"
}

# wp-config.php is regenerated on every start, so changed database settings apply.
{
    echo "<?php"
    echo "define( 'DB_NAME', '$(php_escape "${DB_NAME}")' );"
    echo "define( 'DB_USER', '$(php_escape "${DB_USER}")' );"
    echo "define( 'DB_PASSWORD', '$(php_escape "${DB_PASSWORD}")' );"
    echo "define( 'DB_HOST', '$(php_escape "${DB_HOST}:${DB_PORT}")' );"
    echo "define( 'DB_CHARSET', 'utf8mb4' );"
    echo "define( 'DB_COLLATE', '' );"
    echo "\$table_prefix = 'wp_';"
    # /app is read-only at runtime, so core self-updates are disabled.
    echo "define( 'AUTOMATIC_UPDATER_DISABLED', true );"
    echo "if ( ! defined( 'ABSPATH' ) ) { define( 'ABSPATH', '/app/www/' ); }"
    echo "require_once '/config/wp-salts.php';"
    echo "require_once ABSPATH . 'wp-settings.php';"
} > /config/wp-config.php.tmp
mv /config/wp-config.php.tmp /config/wp-config.php

# UNVERIFIED: Apache started as a non-root user (User/Group from APACHE_RUN_* env); confirm no warnings on start.
exec apache2 -DFOREGROUND
