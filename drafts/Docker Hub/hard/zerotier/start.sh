#!/usr/bin/env bash
set -euo pipefail

export HOME=/config

ZT_HOME=/config

umask 077
mkdir -p "${ZT_HOME}/networks.d"

# Seed identity and API secret from the environment. A file is only written when its variable is set,
# so an empty /config gets a fresh identity from zerotier-one. Values go straight to files, never to logs.
if [ -n "${ZEROTIER_API_SECRET:-}" ]; then
    printf '%s' "${ZEROTIER_API_SECRET}" > "${ZT_HOME}/authtoken.secret"
    chmod 600 "${ZT_HOME}/authtoken.secret"
fi

if [ -n "${ZEROTIER_IDENTITY_PUBLIC:-}" ]; then
    printf '%s' "${ZEROTIER_IDENTITY_PUBLIC}" > "${ZT_HOME}/identity.public"
    chmod 644 "${ZT_HOME}/identity.public"
fi

if [ -n "${ZEROTIER_IDENTITY_SECRET:-}" ]; then
    printf '%s' "${ZEROTIER_IDENTITY_SECRET}" > "${ZT_HOME}/identity.secret"
    chmod 600 "${ZT_HOME}/identity.secret"
fi

# Network ids come from the command arguments and from ZEROTIER_JOIN_NETWORKS (space separated).
read -r -a env_ids <<< "${ZEROTIER_JOIN_NETWORKS:-}"
for id in "$@" "${env_ids[@]:-}"; do
    [ -n "${id}" ] || continue
    if [[ ! "${id}" =~ ^[0-9a-f]{16}$ ]]; then
        echo "Error: invalid ZeroTier network id: ${id}" >&2
        exit 1
    fi
    touch "${ZT_HOME}/networks.d/${id}.conf"
done

printf '%s' 9993 > "${ZT_HOME}/zerotier-one.port"

if [ ! -w /dev/net/tun ]; then
    echo "Warning: /dev/net/tun is not writable. ZeroTier cannot create network interfaces without it and NET_ADMIN." >&2
fi

# /var/lib/zerotier-one is a symlink to /config, so the default home is used.
exec /usr/sbin/zerotier-one -p9993
