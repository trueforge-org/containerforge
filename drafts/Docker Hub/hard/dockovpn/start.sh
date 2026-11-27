#!/usr/bin/env bash
set -euo pipefail

OVPN_DIR=/config/openvpn
export APP_PERSIST_DIR="${APP_PERSIST_DIR:-/config/data}"
export EASYRSA_PKI="${APP_PERSIST_DIR}/pki"
export EASYRSA_BATCH=1

mkdir -p "${APP_PERSIST_DIR}" "${OVPN_DIR}" /tmp/dockovpn

if [ ! -c /dev/net/tun ]; then
  echo "ERROR: /dev/net/tun is missing; start the container with --device /dev/net/tun" >&2
  exit 1
fi

# PKI is generated once (marker file .gen), as upstream does. Generation happens here, not at build time.
if [ ! -f "${APP_PERSIST_DIR}/.gen" ]; then
  echo "*** Generating PKI (first start) ***"
  if [ ! -d "${EASYRSA_PKI}" ]; then
    easyrsa init-pki
    easyrsa gen-dh
  fi
  easyrsa build-ca nopass
  easyrsa gen-req MyReq nopass
  easyrsa sign-req server MyReq
  openvpn --genkey --secret "${APP_PERSIST_DIR}/ta.key"
  easyrsa --days="${CRL_DAYS}" gen-crl
  touch "${APP_PERSIST_DIR}/.gen"
fi

# Copy the server material into /config on every start (upstream copies into /etc/openvpn)
cp "${EASYRSA_PKI}/dh.pem" "${EASYRSA_PKI}/ca.crt" "${EASYRSA_PKI}/crl.pem" \
  "${EASYRSA_PKI}/issued/MyReq.crt" "${EASYRSA_PKI}/private/MyReq.key" \
  "${APP_PERSIST_DIR}/ta.key" "${OVPN_DIR}/"

# Seed the server config once. /etc/openvpn paths are rewritten to the persistent directory (UNVERIFIED)
if [ ! -s "${OVPN_DIR}/server.conf" ]; then
  sed "s#/etc/openvpn/#${OVPN_DIR}/#g" /app/config/server.conf > "${OVPN_DIR}/server.conf"
fi

# Firewall rules need NET_ADMIN; warn instead of failing when they are not permitted
add_rule() {
  iptables "$@" || echo "WARNING: iptables $* failed (NET_ADMIN required)" >&2
}
add_rule -t nat -A POSTROUTING -s 10.8.0.0/24 -o "${NET_ADAPTER}" -j MASQUERADE
add_rule -A FORWARD -i tun0 -o "${NET_ADAPTER}" -s 10.8.0.0/24 -j ACCEPT
add_rule -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
add_rule -A FORWARD -i tun0 -j ACCEPT
add_rule -A INPUT -i "${NET_ADAPTER}" -p udp -m state --state NEW,ESTABLISHED --dport 1194 -j ACCEPT
add_rule -A OUTPUT -o "${NET_ADAPTER}" -p udp -m state --state ESTABLISHED --sport 1194 -j ACCEPT
add_rule -A INPUT -i tun0 -j ACCEPT
add_rule -A OUTPUT -o tun0 -j ACCEPT

# UNVERIFIED: client .ovpn generation (upstream functions.sh generateClientConfig) and the
# HOST_CONF_PORT download server are not ported in this draft.

# OpenVPN listens on the port in server.conf (1194); HOST_TUN_PORT is only the port advertised to clients
exec openvpn --config "${OVPN_DIR}/server.conf"
