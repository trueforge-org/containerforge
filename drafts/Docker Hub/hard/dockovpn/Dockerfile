FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
USER root

ENV \
  HOME=/config \
  APP_INSTALL_PATH=/app \
  APP_PERSIST_DIR=/config/data \
  NET_ADAPTER=eth0 \
  HOST_TUN_PORT=1194 \
  HOST_CONF_PORT=8080 \
  CRL_DAYS=3650

# UNVERIFIED: check which of these the ubuntu base already ships before adding
RUN echo "*** Installing OpenVPN and tools ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    openvpn easy-rsa iptables netcat-openbsd zip libcap2-bin iproute2 && \
  rm -rf /var/lib/apt/lists/*

# No checksum is published for the tag archive; pinned by tag only
RUN echo "*** Installing Dockovpn scripts ${VERSION} ***" && \
  curl -fsSL -o /tmp/dockovpn.tar.gz \
    "https://github.com/dockovpn/dockovpn/archive/refs/tags/v${VERSION}.tar.gz" && \
  mkdir -p /tmp/dockovpn-src /app && \
  tar xzf /tmp/dockovpn.tar.gz -C /tmp/dockovpn-src --strip-components=1 && \
  cp -r /tmp/dockovpn-src/scripts /tmp/dockovpn-src/config /app/ && \
  install -Dm0644 /tmp/dockovpn-src/LICENSE /usr/share/licenses/dockovpn/LICENSE && \
  if [ ! -e /usr/bin/easyrsa ]; then ln -s /usr/share/easy-rsa/easyrsa /usr/bin/easyrsa; fi && \
  # Non-root OpenVPN needs file capabilities to manage the tun device and firewall rules
  # UNVERIFIED: the runtime must allow file capabilities (no_new_privs can block them)
  setcap cap_net_admin,cap_net_raw+ep /usr/sbin/openvpn && \
  # UNVERIFIED: iptables binary path on Ubuntu 26.04
  setcap cap_net_admin,cap_net_raw+ep /usr/sbin/xtables-nft-multi && \
  echo "*** Cleaning Up ***" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf /tmp/dockovpn-src /tmp/dockovpn.tar.gz

USER apps
COPY --chmod=0755 . /

WORKDIR /config

EXPOSE 1194/udp
EXPOSE 8080/tcp

VOLUME /config
