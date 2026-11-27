#!/usr/bin/env bash
set -euo pipefail

UPSTREAM_DNS="${UPSTREAM_DNS:-8.8.8.8}"
ENABLE_DNSSEC_VALIDATION="${ENABLE_DNSSEC_VALIDATION:-false}"
BIND_DIR=/tmp/bind

mkdir -p "$BIND_DIR/cache" "$BIND_DIR/run"

# Upstream servers may be separated by ';' or spaces.
forwarders=""
# shellcheck disable=SC2086
for ip in ${UPSTREAM_DNS//;/ }; do
  forwarders+="${ip}; "
done

if [[ "$ENABLE_DNSSEC_VALIDATION" == "true" ]]; then
  dnssec="auto"
else
  dnssec="no"
fi

cat > "$BIND_DIR/named.conf" <<EOT
options {
    directory "$BIND_DIR";
    pid-file "$BIND_DIR/run/named.pid";
    session-keyfile "$BIND_DIR/run/session.key";
    managed-keys-directory "$BIND_DIR/cache";
    listen-on { any; };
    listen-on-v6 { any; };
    allow-query { any; };
    allow-recursion { 127.0.0.1; 10.0.0.0/8; 172.16.0.0/12; 192.168.0.0/16; };
    forwarders { ${forwarders}};
    dnssec-validation ${dnssec};
};
EOT

# TODO: the CDN zones from /app/cache-domains (upstream overlay hook 10_generate_config.sh and zone.tmpl,
# not read yet) and the LANCACHE_IP / *CACHE_IP / DISABLE_* variables are not ported. Only forwarding works.

named-checkconf "$BIND_DIR/named.conf"
exec named -g -c "$BIND_DIR/named.conf"
