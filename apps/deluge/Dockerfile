

FROM ghcr.io/trueforge-org/python:3.13.7@sha256:8a2c1da075925eac6d7e3a405035b60a68e1f82cf61b7807a7e87d9ca4f8c999
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
COPY --from=ghcr.io/linuxserver/unrar:latest@sha256:92b4d32099ca9c9290bed83b4ba7cad5b0f563fd3e3bc63ca6a924b6f8a9245b /usr/bin/unrar-alpine /usr/bin/unrar

# Switch to non-root user
USER apps:apps

WORKDIR /config
