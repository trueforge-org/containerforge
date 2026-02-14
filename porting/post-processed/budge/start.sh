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

if [[ -d /app/www/public/backend/node_modules-tmp ]]; then
    echo "New container detected. Setting up app folder and fixing permissions."
    mv /app/www/public/backend/node_modules-tmp /app/www/public/backend/node_modules
    mv /app/www/public/frontend/node_modules-tmp /app/www/public/frontend/node_modules
fi

mkdir -p /config/log/npm

cd /app/www/public/backend/build || exit 1

npx typeorm migration:run

touch /app/www/public/backend/budge.sqlite

shopt -s globstar
cd /app/www/public/backend/build
exec /usr/bin/npm run start --logs-dir /config/log/npm

