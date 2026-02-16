

FROM ghcr.io/trueforge-org/python:3.14.3@sha256:ce429d498a8b592f7495c3cd2ac98d31c56d4ffaf00cacbb49e418494e25c626
ARG VERSION

ENV DELUGE_BIN="deluged" \
    XDG_CONFIG_HOME="/config" \
    PYTHON_EGG_CACHE="/config/plugins/.python-eggs"

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
COPY --from=ghcr.io/linuxserver/unrar:latest@sha256:92b4d32099ca9c9290bed83b4ba7cad5b0f563fd3e3bc63ca6a924b6f8a9245b /usr/bin/unrar-ubuntu /usr/bin/unrar

# Switch to non-root user
USER apps:apps

WORKDIR /config
