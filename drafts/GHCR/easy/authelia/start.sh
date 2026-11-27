#!/usr/bin/env bash
set -euo pipefail

export X_AUTHELIA_CONFIG="${X_AUTHELIA_CONFIG:-/config/configuration.yml}"
config_dir="$(dirname "${X_AUTHELIA_CONFIG}")"

mkdir -p "${config_dir}"

# Random hex secret from the kernel RNG. od and tr are coreutils-level tools, so no extra package is needed.
generate_secret() {
    od -An -tx1 -N64 /dev/urandom | tr -d ' \n'
}

# Seed the config and the user database only when they are missing or empty, so user state is never overwritten.
# Secrets are generated once, when the config is seeded, and are never printed.
if [ ! -s "${X_AUTHELIA_CONFIG}" ]; then
    echo "Seeding ${X_AUTHELIA_CONFIG} from /defaults/configuration.yml"
    tmp_config="${X_AUTHELIA_CONFIG}.tmp"
    sed \
        -e "s|AUTHELIA_GENERATED_JWT_SECRET|$(generate_secret)|" \
        -e "s|AUTHELIA_GENERATED_SESSION_SECRET|$(generate_secret)|" \
        -e "s|AUTHELIA_GENERATED_STORAGE_KEY|$(generate_secret)|" \
        /defaults/configuration.yml > "${tmp_config}"
    chmod 0600 "${tmp_config}"
    mv "${tmp_config}" "${X_AUTHELIA_CONFIG}"
fi

# The template's authentication backend points at /config/users_database.yml.
if [ ! -s /config/users_database.yml ]; then
    cp /defaults/users_database.yml /config/users_database.yml
fi

# UNVERIFIED: the --config flag name. Confirm with `authelia --help` on the built image.
exec /app/authelia/authelia --config "${X_AUTHELIA_CONFIG}"
