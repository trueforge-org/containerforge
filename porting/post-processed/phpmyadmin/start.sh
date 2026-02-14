#!/usr/bin/env bash
# NONROOT_COMPAT
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  shopt -s expand_aliases
  alias apk=':'
  alias apt-get=':'
  alias chown=':'
  alias chmod=':'
  alias usermod=':'
  alias groupadd=':'
  alias adduser=':'
  alias useradd=':'
  alias setcap=':'
  alias mount=':'
  alias sysctl=':'
  alias service=':'
  alias s6-svc=':'
fi

mkdir -p \
    /config/phpmyadmin

if [[ ! -f /config/phpmyadmin/config.secret.inc.php ]]; then
    cat >/config/phpmyadmin/config.secret.inc.php <<EOT
<?php
\$cfg['blowfish_secret'] = '$(tr -dc 'a-zA-Z0-9~!@#$%^&*_()+}{?></";.,[]=-' </dev/urandom | fold -w 32 | head -n 1)';
EOT
fi

if [[ -n "${PMA_CONFIG_BASE64}" ]]; then
    echo "${PMA_CONFIG_BASE64}" | base64 -d > /config/phpmyadmin/config.inc.php
fi

if [[ -n "${PMA_USER_CONFIG_BASE64}" ]]; then
    echo "${PMA_USER_CONFIG_BASE64}" | base64 -d > /config/phpmyadmin/config.user.inc.php
fi

if [[ ! -f /config/phpmyadmin/config.user.inc.php ]]; then
    touch /config/phpmyadmin/config.user.inc.php
fi

if [[ ! -f /config/phpmyadmin/config.inc.php ]]; then
    cp /defaults/config.inc.php /config/phpmyadmin/config.inc.php
fi

if [[ ! -f /config/phpmyadmin/helpers.php ]]; then
    cp /defaults/helpers.php /config/phpmyadmin/helpers.php
fi


    # Set up themes
    if [[ -d "/config/themes" && ! -L "/app/www/public/themes" ]]; then
        cp -R /app/www/public/themes/* /config/themes
        rm -rf "/app/www/public/themes"
    fi
    if [[ ! -d "/config/themes" && ! -L "/app/www/public/themes" ]]; then
        mv "/app/www/public/themes" /config/themes
    fi
    if [[ -d "/config/themes" && ! -L "/app/www/public/themes" ]]; then
        ln -s "/config/themes" "/app/www/public/themes"
    fi

## TODO: find exec
