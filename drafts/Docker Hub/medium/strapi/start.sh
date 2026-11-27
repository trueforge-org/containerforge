#!/usr/bin/env bash

set -e
app=/config/app

# Seed the project from the template on first start only.
if [[ ! -f "${app}/package.json" ]]; then
  mkdir -p "${app}"
  cp -a /app/strapi/. "${app}/"
fi

# Generate secrets once. Later starts reuse them from the persistent .env file.
# UNVERIFIED: openssl availability in this base
env_file="${app}/.env"
if [[ ! -f "${env_file}" ]]; then
  {
    echo "APP_KEYS=$(openssl rand -base64 32),$(openssl rand -base64 32)"
    echo "API_TOKEN_SALT=$(openssl rand -base64 16)"
    echo "ADMIN_JWT_SECRET=$(openssl rand -base64 16)"
    echo "TRANSFER_TOKEN_SALT=$(openssl rand -base64 16)"
    echo "JWT_SECRET=$(openssl rand -base64 16)"
    echo "ENCRYPTION_KEY=$(openssl rand -base64 16)"
  } > "${env_file}"
fi

cd "${app}"
export HOST="${HOST:-0.0.0.0}" PORT="${PORT:-1337}" NODE_ENV="${NODE_ENV:-production}"
# UNVERIFIED: `npm run start` is the upstream script name in the scaffolded package.json
exec npm run start
