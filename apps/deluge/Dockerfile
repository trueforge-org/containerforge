# syntax=docker/dockerfile:1

FROM ghcr.io/trueforge-org/python:3.13.7@sha256:eb8c395317bd3e807501ef61f4d16a9582b11db2e28c46e74d1dd6c9762002a4
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
USER nobody:nogroup

WORKDIR /config
