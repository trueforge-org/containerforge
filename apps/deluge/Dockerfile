

FROM ghcr.io/trueforge-org/python:3.14.6@sha256:dc837e172315d2788cac52caaa312815a494090d6630a619d844a1146539d75b
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
COPY --from=ghcr.io/linuxserver/unrar:latest@sha256:5e150efdebbcb4e313b30bd17e40fc386f538a0a9baa4c9b1a5368a9a9a57e39 /usr/bin/unrar-ubuntu /usr/bin/unrar

# Switch to non-root user
USER apps
COPY --chmod=0755 . /

WORKDIR /config
