

FROM ghcr.io/trueforge-org/python:3.13.7@sha256:462920f87d68208b7203ce499c21a3848dbf1ff90e726538027b40c414bd7ff9
ARG VERSION

ENV DELUGE_BIN="deluged" \
    XDG_CONFIG_HOME="/config" \
    PYTHON_EGG_CACHE="/config/plugins/.python-eggs" \
    TMPDIR="/tmp"

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        p7zip-full \
        gzip \
    && pip3 install --break-system-packages geoip2 libtorrent "deluge==${VERSION}" \
    && mkdir -p /usr/share/GeoIP \
    && curl -fsSL "https://mailfud.org/geoip-legacy/GeoIP.dat.gz" \
        | gunzip > /usr/share/GeoIP/GeoIP.dat \
    && rm -rf /var/lib/apt/lists/* /tmp/*
COPY . /

# Copy unrar binary from LinuxServer image
COPY --from=ghcr.io/linuxserver/unrar:latest /usr/bin/unrar-alpine /usr/bin/unrar

# Switch to non-root user
USER apps:apps

WORKDIR /config
