# UNVERIFIED: the Ubuntu 26.04 base is not on the vendor's supported OS list (up to 20.04).
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION=10.0.9
ARG PATCH=p2
ARG BUILD=10320
ARG TARGETARCH

ENV HOME=/config

USER root

# The vendor package is amd64 only.
RUN [ "$TARGETARCH" = "amd64" ] || { echo "kerio-connect is amd64 only" >&2; exit 1; }

# Vendor installs by .deb. The versioned CDN URL is used on purpose: the unversioned
# link always points at the newest build. No checksum was found; record one here.
RUN \
  echo "**** download Kerio Connect ${VERSION}-${PATCH} ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends ca-certificates curl && \
  curl -fsSL -o /tmp/kerio-connect.deb \
    "https://cdn.kerio.com/dwn/connect/connect-${VERSION}-${BUILD}/kerio-connect-${VERSION}-${BUILD}-${PATCH}-linux-amd64.deb" && \
  echo "**** install (postinst must not start services during build) ****" && \
  printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d && \
  chmod 0755 /usr/sbin/policy-rc.d && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends /tmp/kerio-connect.deb && \
  rm -f /usr/sbin/policy-rc.d /tmp/kerio-connect.deb && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# UNVERIFIED: the upstream data path. Move the installed tree to a template and point
# /opt/kerio at /config, so the data survives a read-only root filesystem.
# UNVERIFIED: /mailserver/data (upstream mail store volume) is not remapped yet.
RUN \
  echo "**** relocate Kerio data to /config ****" && \
  mv /opt/kerio /usr/share/kerio-connect-dist && \
  ln -s /config/kerio /opt/kerio && \
  echo "**** backup mount point ****" && \
  mkdir -p /backup && \
  chown apps:apps /backup && \
  echo "**** license pointer (UNVERIFIED: copy the EULA shipped in the package here) ****" && \
  mkdir -p /usr/share/licenses/kerio-connect && \
  echo "Kerio Connect is proprietary software. Vendor: https://www.kerio.com/" \
    > /usr/share/licenses/kerio-connect/LICENSE-POINTER.txt

USER apps
COPY --chmod=0755 . /

WORKDIR /config
# Ports below 1024 need net.ipv4.ip_unprivileged_port_start=0 (or NET_BIND_SERVICE) for the non-root user.
EXPOSE 4040 25 465 587 110 995 143 993 80 443
VOLUME /config
