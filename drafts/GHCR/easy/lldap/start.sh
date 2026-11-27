#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export TMPDIR=/tmp

mkdir -p /config

# Seed the config only on an empty /config. Never overwrite an existing config.
if [ ! -s /config/lldap_config.toml ]; then
  cp /defaults/lldap_config.toml /config/lldap_config.toml
fi

# Secrets are generated once and kept in /config/.secrets (mode 600), not in the process list.
secrets_dir=/config/.secrets
mkdir -p "${secrets_dir}"
chmod 700 "${secrets_dir}"

gen_secret() {
  # `|| true`: tr gets SIGPIPE once head is done, which must not fail the script under pipefail.
  LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 40 || true
}

if [ -z "${LLDAP_JWT_SECRET:-}" ]; then
  if [ ! -s "${secrets_dir}/jwt_secret" ]; then
    (umask 077; gen_secret > "${secrets_dir}/jwt_secret")
  fi
  export LLDAP_JWT_SECRET_FILE="${secrets_dir}/jwt_secret"
fi

if [ -z "${LLDAP_LDAP_USER_PASS:-}" ]; then
  if [ ! -s "${secrets_dir}/admin_password" ]; then
    (umask 077; gen_secret > "${secrets_dir}/admin_password")
  fi
  export LLDAP_LDAP_USER_PASS_FILE="${secrets_dir}/admin_password"
fi

# lldap loads its web assets relative to the working directory, so start from /app (read-only).
# UNVERIFIED: the `run` subcommand and --config-file flag, taken from the chart command (`/app/lldap run`).
cd /app
exec /app/lldap run --config-file /config/lldap_config.toml
