FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

# renovate: datasource=pypi depName=owi2plex versioning=pep440
ARG VERSION=0.1a14
# UNVERIFIED: supercronic version is not pinned yet. Set it from the aptible/supercronic release (with its sha256)
# before building. No default is set on purpose, so the build fails until it is chosen.
ARG SUPERCRONIC_VERSION
ARG TARGETARCH

ENV \
    HOME=/config \
    TZ=Etc/UTC \
    PATH="/app/venv/bin:${PATH}"

USER root

COPY defaults/requirements.txt /tmp/requirements.txt

# Build deps are needed because lxml 4.3.2 has no wheel for this Python (UNVERIFIED). They are purged in the same RUN.
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        libxml2-16 \
        libxml2-dev \
        libxslt1-dev \
        libxslt1.1 \
    && /app/venv/bin/pip install --no-cache-dir \
        --requirement /tmp/requirements.txt \
        "owi2plex==${VERSION}" \
    && apt-get purge -y --auto-remove build-essential libxml2-dev libxslt1-dev \
    && rm -rf /var/lib/apt/lists/* /tmp/*

# Scheduler that runs as a normal user (no root needed, unlike the Debian cron daemon).
# UNVERIFIED: the asset name and the checksum check are not set up yet.
RUN set -eux; \
    curl -fsSL -o /usr/local/bin/supercronic \
        "https://github.com/aptible/supercronic/releases/download/v${SUPERCRONIC_VERSION}/supercronic-linux-${TARGETARCH}"; \
    chmod 0755 /usr/local/bin/supercronic

# License from the installed wheel metadata. UNVERIFIED: the wheel may not ship a LICENSE file.
RUN set -eux; \
    mkdir -p /usr/share/licenses/owi2plex; \
    cp /app/venv/lib/python3*/site-packages/owi2plex-${VERSION}.dist-info/LICENSE* /usr/share/licenses/owi2plex/; \
    chown -R root:root /app && chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

VOLUME /config
WORKDIR /config
