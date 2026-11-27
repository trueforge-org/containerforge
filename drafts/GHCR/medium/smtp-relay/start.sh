#!/usr/bin/env bash
set -eu

# Persistent state: the mail queue and logs must survive restarts.
mkdir -p /config/spool /config/log
# Ephemeral runtime state. Regenerated on every start. Passwords are written here with mode 0600 and never printed.
RUN_DIR=/tmp/smtp-relay
mkdir -p "${RUN_DIR}/run"
chmod 0700 "${RUN_DIR}"

BIND_IP="${BIND_IP:-0.0.0.0}"
BIND_IP6="${BIND_IP6:-::0}"
PORT="${PORT:-2525}"
NET_DEV="${NET_DEV:-eth0}"

# Relay networks: detected interface networks plus RELAY_NETWORKS (must start with ':'), as the upstream entrypoint does.
# An empty RELAY_NETWORKS keeps the server closed to relaying from other networks.
RELAY_NETS=$(ip -o -4 addr show dev "${NET_DEV}" 2>/dev/null | awk '{print $4}' | paste -sd ':' - || true)
if [ -n "${RELAY_NETWORKS:-}" ]; then
  RELAY_NETS="${RELAY_NETS}:${RELAY_NETWORKS}"
fi

CONF="${RUN_DIR}/exim4.conf"
MACROS="${RUN_DIR}/exim4.conf.localmacros"

# UNVERIFIED: the base config source and the macro names read from the Debian template. PoC required (plan section 9).
{
  echo "MAIN_LOCAL_INTERFACES = [${BIND_IP}]:${PORT} ; [${BIND_IP6}]:${PORT}"
  echo "SPOOL_DIRECTORY = /config/spool"
  echo "LOG_FILE_PATH = /config/log/%slog"
  echo "PID_FILE_PATH = ${RUN_DIR}/run/exim.pid"
  if [ -n "${MAILNAME:-}" ]; then
    echo "MAIN_HARDCODE_PRIMARY_HOSTNAME = ${MAILNAME}"
  fi
  if [ -n "${RELAY_NETS}" ]; then
    echo "hostlist relay_from_hosts = ${RELAY_NETS}"
  fi
  if [ -n "${RELAY_DOMAINS:-}" ]; then
    echo "domainlist relay_to_domains = ${RELAY_DOMAINS}"
  fi
  if [ -n "${OTHER_HOSTNAMES:-}" ]; then
    echo "MAIN_OTHER_HOSTNAMES = ${OTHER_HOSTNAMES}"
  fi
} > "${MACROS}"

# UNVERIFIED: the Debian template at this path must exist in the image (build stage, plan section 4 step 5).
if [ ! -r /etc/exim4/exim4.conf.template ]; then
  echo "smtp-relay: /etc/exim4/exim4.conf.template is missing from the image" >&2
  exit 1
fi
cp /etc/exim4/exim4.conf.template "${CONF}"

# Run the Exim daemon as PID 1 so signals reach it. -bd -q15m -v matches the upstream CMD.
exec exim4 -C "${CONF}" -bd -q15m -v
