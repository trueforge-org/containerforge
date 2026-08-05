

FROM ghcr.io/trueforge-org/python:3.14.6@sha256:7126ada2ea0c2086b0f078af562c413bbbbb44b946aeb70c3175386647e434fe
ARG VERSION

ENV DELUGE_BIN="deluged" \
    XDG_CONFIG_HOME="/config" \
    PYTHON_EGG_CACHE="/config/plugins/.python-eggs"

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        geoip-database \
        p7zip-full \
    # Deluge currently imports pkg_resources, removed in setuptools 81+.
    && pip3 install --break-system-packages geoip2 libtorrent "setuptools<81" "deluge==${VERSION}" \
    && rm -rf /var/lib/apt/lists/* /tmp/*

# Copy unrar binary from LinuxServer image
COPY --from=ghcr.io/linuxserver/unrar:latest@sha256:22e6e76f2f2372a7cd6e046b10025e8bde8a04a2b2b2c6072fca6821da5747f7 /usr/bin/unrar-ubuntu /usr/bin/unrar

# Switch to non-root user
USER apps
COPY --chmod=0755 . /

WORKDIR /config
