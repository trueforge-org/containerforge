#!/usr/bin/env bash
# UNVERIFIED draft (plan section 7). Only FTL is started here. The lighttpd and PHP web UI start is NOT written yet,
# so the web UI will not serve until that is decided (plan section 10, multi-process).
set -euo pipefail

mkdir -p /config/pihole /config/dnsmasq.d /tmp/pihole

# API password: use the env value if set. Otherwise generate one once, keep it in /config, and never print it.
if [ -z "${FTLCONF_webserver_api_password:-}" ]; then
  if [ ! -s /config/pihole/.api_password ]; then
    head -c 24 /dev/urandom | base64 > /config/pihole/.api_password
    chmod 600 /config/pihole/.api_password
  fi
  FTLCONF_webserver_api_password="$(cat /config/pihole/.api_password)"
  export FTLCONF_webserver_api_password
fi

export FTLCONF_dns_listeningMode="${FTLCONF_dns_listeningMode:-ALL}"
export FTLCONF_misc_etc_dnsmasq_d="${FTLCONF_misc_etc_dnsmasq_d:-false}"

# UNVERIFIED: whether FTL creates pihole.toml on first start. The plan's defaults/pihole.toml seed is not written,
# because the upstream file was not read.
exec /usr/local/bin/pihole-FTL no-daemon
